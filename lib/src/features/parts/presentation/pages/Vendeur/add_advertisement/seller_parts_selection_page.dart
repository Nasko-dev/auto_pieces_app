import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/providers/providers.dart';
import 'seller_shared_widgets.dart';

class SellerPartsSelectionPage extends ConsumerStatefulWidget {
  final String
      selectedCategory; // 'engine_parts', 'transmission_parts', 'body_parts', 'both'
  final bool hasMultipleParts; // true = +5 pièces, false = -5 pièces
  final Function(List<String> selectedParts, String completeOption) onSubmit;

  const SellerPartsSelectionPage({
    super.key,
    required this.selectedCategory,
    required this.hasMultipleParts,
    required this.onSubmit,
  });

  @override
  ConsumerState<SellerPartsSelectionPage> createState() =>
      _SellerPartsSelectionPageState();
}

class _SellerPartsSelectionPageState
    extends ConsumerState<SellerPartsSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _selectedParts = [];
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  String _completeOption =
      ''; // 'moteur_complet', 'carrosserie_complete', 'vehicule_complet' ou vide

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() async {
    final query = _searchController.text;

    setState(() {});

    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    try {
      String? categoryFilter;

      if (widget.selectedCategory == 'engine_parts') {
        categoryFilter = 'moteur';
      } else if (widget.selectedCategory == 'transmission_parts') {
        categoryFilter = 'transmission';
      } else if (widget.selectedCategory == 'body_parts') {
        categoryFilter = 'NOT_MOTEUR';
      } else if (widget.selectedCategory == 'both') {
        categoryFilter = null;
      }

      final actualCategoryFilter =
          categoryFilter == 'NOT_MOTEUR' ? null : categoryFilter;

      final response = await ref.read(supabaseClientProvider).rpc(
        'search_parts',
        params: {
          'search_query': query,
          'filter_category': actualCategoryFilter,
          'limit_results': categoryFilter == 'NOT_MOTEUR' ? 20 : 8,
        },
      );

      if (response != null && mounted) {
        List<Map<String, dynamic>> filteredData =
            (response as List).cast<Map<String, dynamic>>();

        if (categoryFilter == 'NOT_MOTEUR') {
          filteredData = filteredData
              .where((data) => data['category'] != 'moteur')
              .toList();
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
          _showSuggestions = parts.isNotEmpty && _focusNode.hasFocus;
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
      _showSuggestions = _suggestions.isNotEmpty && _focusNode.hasFocus;
    });
  }

  void _selectSuggestion(String suggestion) {
    if (!_selectedParts.contains(suggestion)) {
      setState(() {
        _selectedParts.add(suggestion);
        _searchController.clear();
        _showSuggestions = false;
      });
    }
    _focusNode.requestFocus();
  }

  void _removePart(String part) {
    setState(() {
      _selectedParts.remove(part);
    });
  }

  bool _isFormValid() {
    // Si une option complète est sélectionnée, toujours valide
    if (_completeOption.isNotEmpty) {
      return true;
    }
    // Sinon, il faut au moins une pièce sélectionnée
    return _selectedParts.isNotEmpty;
  }

  void _handleSubmit() {
    widget.onSubmit(_selectedParts, _completeOption);
  }

  String _getSubtitleText() {
    if (widget.hasMultipleParts) {
      if (widget.selectedCategory == 'engine_parts') {
        return 'Sélectionnez les pièces manquantes ou choisissez "Moteur complet"';
      } else if (widget.selectedCategory == 'transmission_parts') {
        return 'Sélectionnez les pièces manquantes ou choisissez "Boîte complète"';
      } else if (widget.selectedCategory == 'body_parts') {
        return 'Sélectionnez les pièces manquantes ou choisissez "Carrosserie complète"';
      } else {
        return 'Sélectionnez les pièces manquantes ou choisissez "Véhicule complet"';
      }
    } else {
      return 'Sélectionnez les pièces que vous possédez';
    }
  }

  Color _getCategoryColor() {
    if (widget.selectedCategory == 'engine_parts') {
      return const Color(0xFF2196F3); // Bleu
    } else if (widget.selectedCategory == 'transmission_parts') {
      return const Color(0xFF4CAF50); // Vert
    } else if (widget.selectedCategory == 'body_parts') {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFFFF9800); // Orange (pour "both")
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Text(
                widget.hasMultipleParts
                    ? 'Quelles pièces n\'avez-vous PAS ?'
                    : 'Quelles pièces avez-vous ?',
                style: const TextStyle(
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkBlue,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _getSubtitleText(),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(height: 28),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Options complètes pour +5 pièces
                      if (widget.hasMultipleParts) ...[
                        _buildCompleteOptions(),
                        const SizedBox(height: 24),
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OU',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.gray,
                                ),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Champ de recherche
                      if (_completeOption.isEmpty) ...[
                        _buildSearchField(),
                        if (_selectedParts.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildSelectedPartsTags(),
                        ],
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bouton Continuer
              SellerSharedWidgets.buildPrimaryButton(
                label: 'Continuer',
                onPressed: _isFormValid() ? _handleSubmit : null,
                backgroundColor: _getCategoryColor(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteOptions() {
    // Déterminer quelle option afficher selon le sous-type
    if (widget.selectedCategory == 'engine_parts') {
      return _buildCompleteOption(
        optionKey: 'moteur_complet',
        title: 'Moteur complet',
        description: 'Toutes les pièces moteur sont disponibles',
        icon: Icons.engineering_outlined,
      );
    } else if (widget.selectedCategory == 'transmission_parts') {
      return _buildCompleteOption(
        optionKey: 'boite_complete',
        title: 'Boîte complète',
        description: 'Toutes les pièces de transmission sont disponibles',
        icon: Icons.settings_input_component_outlined,
      );
    } else if (widget.selectedCategory == 'body_parts') {
      return _buildCompleteOption(
        optionKey: 'carrosserie_complete',
        title: 'Carrosserie complète',
        description: 'Toutes les pièces de carrosserie sont disponibles',
        icon: Icons.car_repair_outlined,
      );
    } else {
      return _buildCompleteOption(
        optionKey: 'vehicule_complet',
        title: 'Véhicule complet',
        description: 'Toutes les pièces du véhicule sont disponibles',
        icon: Icons.directions_car_outlined,
      );
    }
  }

  Widget _buildCompleteOption({
    required String optionKey,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _completeOption == optionKey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _completeOption = isSelected ? '' : optionKey;
          if (_completeOption.isNotEmpty) {
            _selectedParts.clear();
            _searchController.clear();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? _getCategoryColor().withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _getCategoryColor() : AppColors.grey200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? _getCategoryColor().withValues(alpha: 0.15)
                    : AppTheme.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? _getCategoryColor() : AppTheme.gray,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color:
                          isSelected ? _getCategoryColor() : AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
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
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    _completeOption = (value ?? false) ? optionKey : '';
                    if (_completeOption.isNotEmpty) {
                      _selectedParts.clear();
                      _searchController.clear();
                    }
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
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

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rechercher une pièce',
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
            controller: _searchController,
            focusNode: _focusNode,
            textInputAction: TextInputAction.done,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.darkGray,
            ),
            decoration: InputDecoration(
              hintText: 'Ex: Turbo, Alternateur, Démarreur...',
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
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: AppColors.grey200),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
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
