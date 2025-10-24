import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/providers/providers.dart';
import '../../../../../../core/utils/haptic_helper.dart';

class SellPartStepPage extends ConsumerStatefulWidget {
  final String selectedCategory;
  final bool hasMultiple;
  final Function(String partName) onPartSubmitted;
  final VoidCallback? onClose;

  const SellPartStepPage({
    super.key,
    required this.selectedCategory,
    required this.hasMultiple,
    required this.onPartSubmitted,
    this.onClose,
  });

  @override
  ConsumerState<SellPartStepPage> createState() => _SellPartStepPageState();
}

class _SellPartStepPageState extends ConsumerState<SellPartStepPage> {
  final TextEditingController _partController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  final List<String> _selectedParts = [];

  @override
  void initState() {
    super.initState();
    _partController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _partController.removeListener(_onTextChanged);
    _partController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() async {
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

      if (widget.selectedCategory == 'engine' ||
          widget.selectedCategory == 'moteur') {
        categoryFilter = 'moteur';
      } else if (widget.selectedCategory == 'body' ||
          widget.selectedCategory == 'carrosserie') {
        categoryFilter = 'NOT_MOTEUR';
      } else if (widget.selectedCategory == 'lesdeux') {
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
    if (widget.hasMultiple) {
      // Mode multiple : ajouter à la liste des tags
      if (!_selectedParts.contains(suggestion)) {
        setState(() {
          _selectedParts.add(suggestion);
          _partController.clear();
          _showSuggestions = false;
        });
      }
      _focusNode.requestFocus();
    } else {
      // Mode simple : remplacer le texte
      _partController.text = suggestion;
      setState(() {
        _showSuggestions = false;
      });
      _focusNode.unfocus();
    }
  }

  void _removePart(String part) {
    setState(() {
      _selectedParts.remove(part);
    });
  }

  bool _isFormValid() {
    // Toujours valide, on peut passer avec ou sans pièces saisies
    return true;
  }

  void _handleSubmit() {
    final hasText = _partController.text.trim().isNotEmpty;
    final hasParts = _selectedParts.isNotEmpty;

    if (widget.hasMultiple) {
      // Mode multiple (+5 pièces)
      if (hasParts || hasText) {
        final allParts = _selectedParts.toList();
        if (_partController.text.isNotEmpty &&
            !allParts.contains(_partController.text)) {
          allParts.add(_partController.text);
        }
        final partsString = allParts.join(', ');
        widget.onPartSubmitted(partsString);
      } else {
        // Aucune pièce saisie, passer à la page suivante
        widget.onPartSubmitted('');
      }
    } else {
      // Mode simple (-5 pièces)
      if (hasText) {
        widget.onPartSubmitted(_partController.text);
      } else {
        widget.onPartSubmitted('');
      }
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
              // Badge avec info quantité
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      widget.hasMultiple
                          ? Icons.inventory_outlined
                          : Icons.settings_outlined,
                      size: 16,
                      color: _getCategoryColor(),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.hasMultiple ? '+5 pièces' : '-5 pièces',
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
              Text(
                widget.hasMultiple
                    ? 'Quelles pièces\nvendez-vous ?'
                    : 'Quelle pièce\nvendez-vous ?',
                style: const TextStyle(
                  fontSize: 32,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkBlue,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.hasMultiple
                    ? 'Vous pouvez ajouter plusieurs pièces. Laissez vide pour sélectionner à l\'étape suivante.'
                    : 'Entrez le nom de la pièce que vous souhaitez vendre',
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
                      _buildPartSearchField(),
                      if (widget.hasMultiple && _selectedParts.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildSelectedPartsTags(),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isFormValid() ? _handleSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getCategoryColor(),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppTheme.gray.withValues(alpha: 0.3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    if (widget.selectedCategory == 'moteur' ||
        widget.selectedCategory == 'engine') {
      return const Color(0xFF2196F3);
    } else if (widget.selectedCategory == 'carrosserie' ||
        widget.selectedCategory == 'body') {
      return const Color(0xFF4CAF50);
    } else {
      return const Color(0xFFFF9800);
    }
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
            focusNode: _focusNode,
            textInputAction: TextInputAction.done,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.darkGray,
            ),
            decoration: InputDecoration(
              hintText: 'Entrez vos pièces',
              hintStyle: TextStyle(
                color: AppTheme.gray.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: _getCategoryColor(),
                size: 22,
              ),
              suffixIcon: widget.hasMultiple && _partController.text.isNotEmpty
                  ? IconButton(
                      icon: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '+',
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (_partController.text.isNotEmpty &&
                            !_selectedParts.contains(_partController.text)) {
                          HapticHelper.light();
                          setState(() {
                            _selectedParts.add(_partController.text);
                            _partController.clear();
                            _showSuggestions = false;
                          });
                        }
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _getCategoryColor(),
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.grey200.withValues(alpha: 0.5),
                ),
              ),
            ),
            onSubmitted: (value) {
              if (widget.hasMultiple &&
                  value.isNotEmpty &&
                  !_selectedParts.contains(value)) {
                HapticHelper.light();
                setState(() {
                  _selectedParts.add(value);
                  _partController.clear();
                  _showSuggestions = false;
                });
              }
            },
          ),
        ),
        if (_showSuggestions) _buildSuggestionsList(),
        if (widget.hasMultiple && _selectedParts.isEmpty && !_showSuggestions)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppTheme.gray.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Aucune pièce sélectionnée - tapez puis ajoutez avec + ou Entrée',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.gray.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
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
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: AppColors.grey200),
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
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            part,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.primaryBlue,
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
                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 12,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
