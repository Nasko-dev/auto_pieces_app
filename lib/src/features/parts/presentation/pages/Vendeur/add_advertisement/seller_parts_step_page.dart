import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/providers/providers.dart';
import 'seller_shared_widgets.dart';

class SellerPartsStepPage extends ConsumerStatefulWidget {
  final String selectedChoice;
  final Function(String partName, double price, bool hasMultiple) onPartSubmitted;

  const SellerPartsStepPage({
    super.key,
    required this.selectedChoice,
    required this.onPartSubmitted,
  });

  @override
  ConsumerState<SellerPartsStepPage> createState() => _SellerPartsStepPageState();
}

class _SellerPartsStepPageState extends ConsumerState<SellerPartsStepPage> {
  final TextEditingController _partController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FocusNode _partFocusNode = FocusNode();
  bool _hasMultiple = false; // Mode plusieurs pièces (+ de 5)
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  final List<String> _selectedParts = [];

  @override
  void initState() {
    super.initState();
    _partController.addListener(_onPartTextChanged);
    _partFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _partController.removeListener(_onPartTextChanged);
    _partController.dispose();
    _priceController.dispose();
    _partFocusNode.dispose();
    super.dispose();
  }

  void _onPartTextChanged() async {
    final query = _partController.text;

    // Toujours appeler setState pour mettre à jour la validation du bouton
    setState(() {});

    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    try {
      // Déterminer la catégorie selon le type sélectionné
      String? categoryFilter;

      if (widget.selectedChoice == 'moteur') {
        categoryFilter = 'moteur';
      } else if (widget.selectedChoice == 'carrosserie') {
        categoryFilter = 'NOT_MOTEUR';
      } else if (widget.selectedChoice == 'lesdeux') {
        categoryFilter = null;
      }

      // Appeler la fonction sans filtre si on veut exclure moteur
      final actualCategoryFilter = categoryFilter == 'NOT_MOTEUR' ? null : categoryFilter;

      final response = await ref.read(supabaseClientProvider).rpc(
        'search_parts',
        params: {
          'search_query': query,
          'filter_category': actualCategoryFilter,
          'limit_results': categoryFilter == 'NOT_MOTEUR' ? 20 : 8,
        },
      );

      if (response != null && mounted) {
        // Filtrer côté client si nécessaire
        List<Map<String, dynamic>> filteredData = (response as List).cast<Map<String, dynamic>>();

        if (categoryFilter == 'NOT_MOTEUR') {
          // Exclure les pièces moteur
          filteredData = filteredData.where((data) => data['category'] != 'moteur').toList();
        }

        final parts = filteredData
            .map((data) {
              final name = data['name'] as String?;
              return name ?? '';
            })
            .where((name) => name.isNotEmpty)
            .take(8)
            .toList();

        setState(() {
          _suggestions = parts;
          _showSuggestions = parts.isNotEmpty && _partFocusNode.hasFocus;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
      }
    }
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _suggestions.isNotEmpty && _partFocusNode.hasFocus;
    });
  }

  void _selectSuggestion(String suggestion) {
    if (_hasMultiple) {
      // Mode multiple : ajouter à la liste des tags
      if (!_selectedParts.contains(suggestion)) {
        setState(() {
          _selectedParts.add(suggestion);
          _partController.clear();
          _showSuggestions = false;
        });
      }
      _partFocusNode.requestFocus();
    } else {
      // Mode simple : remplacer le texte
      _partController.text = suggestion;
      setState(() {
        _showSuggestions = false;
      });
      _partFocusNode.unfocus();
    }
  }

  void _removePart(String part) {
    setState(() {
      _selectedParts.remove(part);
    });
  }

  bool _isFormValid() {
    final hasPartText = _partController.text.trim().isNotEmpty;
    final hasParts = _selectedParts.isNotEmpty;
    final hasPrice = _priceController.text.trim().isNotEmpty;

    if (_hasMultiple) {
      // Mode multiple : valide si au moins une pièce + prix
      return (hasParts || hasPartText) && hasPrice;
    } else {
      // Mode simple : valide si pièce + prix
      return hasPartText && hasPrice;
    }
  }

  void _handleSubmit() {
    final price = double.tryParse(_priceController.text) ?? 0.0;

    if (_hasMultiple) {
      // En mode multiple, envoyer la liste des parts comme une chaîne séparée par des virgules
      final allParts = _selectedParts.toList();
      if (_partController.text.isNotEmpty && !allParts.contains(_partController.text)) {
        allParts.add(_partController.text);
      }
      final partsString = allParts.join(', ');
      widget.onPartSubmitted(partsString, price, _hasMultiple);
    } else {
      widget.onPartSubmitted(_partController.text, price, _hasMultiple);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Badge de catégorie
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor().withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getCategoryColor().withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(),
                          size: 16,
                          color: _getCategoryColor(),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getCategoryLabel(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _getCategoryColor(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Détails de votre\nannonce',
                    style: TextStyle(
                      fontSize: 32,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkBlue,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    _getCategoryDescription(),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.35,
                      color: AppTheme.darkGray,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Options plus/moins de 5 pièces
                  _buildOptionsSection(),

                  const SizedBox(height: 24),

                  // Champ nom de la pièce
                  _buildPartSearchField(),

                  if (_hasMultiple && _selectedParts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSelectedPartsTags(),
                  ],

                  const SizedBox(height: 24),

                  // Champ prix
                  _buildPriceField(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          SellerSharedWidgets.buildPrimaryButton(
            label: 'Continuer',
            enabled: _isFormValid(),
            onPressed: _isFormValid() ? _handleSubmit : null,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    if (widget.selectedChoice == 'moteur') {
      return const Color(0xFF2196F3); // Bleu
    } else if (widget.selectedChoice == 'carrosserie') {
      return const Color(0xFF4CAF50); // Vert
    } else {
      return const Color(0xFFFF9800); // Orange
    }
  }

  IconData _getCategoryIcon() {
    if (widget.selectedChoice == 'moteur') {
      return Icons.settings;
    } else if (widget.selectedChoice == 'carrosserie') {
      return Icons.directions_car;
    } else {
      return Icons.dashboard_customize;
    }
  }

  String _getCategoryLabel() {
    if (widget.selectedChoice == 'moteur') {
      return 'Pièces moteur';
    } else if (widget.selectedChoice == 'carrosserie') {
      return 'Carrosserie / Intérieur';
    } else {
      return 'Les deux';
    }
  }

  String _getCategoryDescription() {
    if (widget.selectedChoice == 'moteur') {
      return 'Moteur, turbo, boîte de vitesses, embrayage, démarreur...';
    } else if (widget.selectedChoice == 'carrosserie') {
      return 'Portière, pare-choc, capot, siège, volant, tableau de bord...';
    } else {
      return 'Vous pouvez vendre des pièces moteur et carrosserie';
    }
  }

  Widget _buildOptionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quantité',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          _buildOptionCheckbox(
            value: _hasMultiple,
            label: 'J\'ai plus de 5 pièces',
            description: 'Vous avez plusieurs pièces à vendre (plus de 5)',
            icon: Icons.inventory_outlined,
            onChanged: (value) {
              setState(() {
                _hasMultiple = value ?? false;
                if (!_hasMultiple) {
                  _selectedParts.clear();
                }
              });
            },
          ),
          const SizedBox(height: 12),
          _buildOptionCheckbox(
            value: !_hasMultiple,
            label: 'J\'ai moins de 5 pièces',
            description: 'Vous avez quelques pièces à vendre (moins de 5)',
            icon: Icons.settings_outlined,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _hasMultiple = false;
                  _selectedParts.clear();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCheckbox({
    required bool value,
    required String label,
    required String description,
    required IconData icon,
    required Function(bool?) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value ? _getCategoryColor().withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? _getCategoryColor().withValues(alpha: 0.3) : AppColors.grey200,
            width: value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: value ? _getCategoryColor().withValues(alpha: 0.15) : AppTheme.lightGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: value ? _getCategoryColor() : AppTheme.gray,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: value ? _getCategoryColor() : AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.gray.withValues(alpha: 0.8),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                side: BorderSide(
                  color: value ? _getCategoryColor() : AppTheme.gray,
                  width: 2,
                ),
                activeColor: _getCategoryColor(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nom de la pièce',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _partController,
            focusNode: _partFocusNode,
            textInputAction: TextInputAction.next,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.darkGray,
            ),
            decoration: InputDecoration(
              hintText: 'Ex: Moteur, Pare-choc avant, Phare...',
              hintStyle: TextStyle(
                color: AppTheme.gray.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: _getCategoryColor(),
                size: 22,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _getCategoryColor(),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        if (_showSuggestions) _buildSuggestionsList(),
      ],
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prix de vente',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.darkGray,
            ),
            decoration: InputDecoration(
              hintText: 'Ex: 150',
              hintStyle: TextStyle(
                color: AppTheme.gray.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(
                Icons.euro,
                color: AppTheme.success,
                size: 22,
              ),
              suffixText: '€',
              suffixStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppTheme.success,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0B1220),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _suggestions.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.grey200),
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return ListTile(
            dense: true,
            title: Text(
              suggestion,
              style: const TextStyle(fontSize: 14, color: AppTheme.darkGray),
            ),
            onTap: () => _selectSuggestion(suggestion),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedPartsTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _selectedParts.map((part) => _buildPartTag(part)).toList(),
    );
  }

  Widget _buildPartTag(String part) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getCategoryColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getCategoryColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            part,
            style: TextStyle(
              fontSize: 14,
              color: _getCategoryColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removePart(part),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: _getCategoryColor().withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 12,
                color: _getCategoryColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
