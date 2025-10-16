import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/theme/app_colors.dart';

class SubTypeStepPage extends StatefulWidget {
  final String selectedCategory;
  final Function(String subType) onSubTypeSelected;

  const SubTypeStepPage({
    super.key,
    required this.selectedCategory,
    required this.onSubTypeSelected,
  });

  @override
  State<SubTypeStepPage> createState() => _SubTypeStepPageState();
}

class _SubTypeStepPageState extends State<SubTypeStepPage> {
  String _selectedSubType = '';
  final Set<String> _selectedSubTypes = {};

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
              const Text(
                'Quel type de pièce\nprécisémen ?',
                style: TextStyle(
                  fontSize: 32,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkBlue,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _getDescription(),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: _buildSubTypeCards(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isValidSelection()
                      ? () {
                          if (widget.selectedCategory == 'lesdeux') {
                            // Mapper intelligemment les sélections multiples
                            final selected = _selectedSubTypes.toList()..sort();
                            String result;

                            // Créer un code unique pour chaque combinaison
                            if (selected.length == 3) {
                              // Les 3 sélectionnés
                              result = 'all_three';
                            } else if (selected.contains('engine_parts') &&
                                selected.contains('transmission_parts')) {
                              // Moteur + Boîte
                              result = 'both';
                            } else if (selected.contains('engine_parts') &&
                                selected.contains('body_parts')) {
                              // Moteur + Carrosserie
                              result = 'engine_body';
                            } else if (selected
                                    .contains('transmission_parts') &&
                                selected.contains('body_parts')) {
                              // Boîte + Carrosserie
                              result = 'transmission_body';
                            } else {
                              // Fallback (ne devrait pas arriver avec validation >= 2)
                              result = selected.first;
                            }

                            widget.onSubTypeSelected(result);
                          } else {
                            widget.onSubTypeSelected(_selectedSubType);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
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

  String _getDescription() {
    if (widget.selectedCategory == 'moteur') {
      return 'Sélectionnez le type de pièces que vous souhaitez vendre';
    } else if (widget.selectedCategory == 'lesdeux') {
      return 'Sélectionnez au moins 2 types de pièces que vous souhaitez vendre';
    } else {
      return 'Sélectionnez le type de pièces que vous souhaitez vendre';
    }
  }

  bool _isValidSelection() {
    if (widget.selectedCategory == 'lesdeux') {
      // Pour 'lesdeux' : au moins 2 sélections requises
      return _selectedSubTypes.length >= 2;
    } else {
      // Pour les autres : au moins 1 sélection
      return _selectedSubType.isNotEmpty;
    }
  }

  List<Widget> _buildSubTypeCards() {
    if (widget.selectedCategory == 'moteur') {
      return [
        _buildSubTypeCard(
          subType: 'engine_parts',
          title: 'Pièces moteur',
          subtitle: 'Culasse, turbo, injecteurs, pompe...',
          icon: Icons.settings,
          color: const Color(0xFF2196F3),
        ),
        const SizedBox(height: 16),
        _buildSubTypeCard(
          subType: 'transmission_parts',
          title: 'Pièces boîte/transmission',
          subtitle: 'Boîte de vitesses, embrayage, différentiel...',
          icon: Icons.settings_input_component,
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 16),
        _buildSubTypeCard(
          subType: 'both',
          title: 'Les deux',
          subtitle: 'Moteur et boîte/transmission',
          icon: Icons.category,
          color: const Color(0xFFFF9800),
        ),
      ];
    } else if (widget.selectedCategory == 'lesdeux') {
      return [
        _buildSubTypeCard(
          subType: 'engine_parts',
          title: 'Pièces moteur',
          subtitle: 'Culasse, turbo, injecteurs, pompe...',
          icon: Icons.settings,
          color: const Color(0xFF2196F3),
        ),
        const SizedBox(height: 16),
        _buildSubTypeCard(
          subType: 'transmission_parts',
          title: 'Pièces boîte/transmission',
          subtitle: 'Boîte de vitesses, embrayage, différentiel...',
          icon: Icons.settings_input_component,
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 16),
        _buildSubTypeCard(
          subType: 'body_parts',
          title: 'Pièces carrosserie',
          subtitle: 'Portière, pare-choc, phare, capot...',
          icon: Icons.directions_car,
          color: const Color(0xFFFF9800),
        ),
      ];
    } else {
      // Si carrosserie, pas de sub-type nécessaire
      return [];
    }
  }

  Widget _buildSubTypeCard({
    required String subType,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    // Pour 'lesdeux', mode multi-sélection, sinon single
    final isMultiSelect = widget.selectedCategory == 'lesdeux';
    final isSelected = isMultiSelect
        ? _selectedSubTypes.contains(subType)
        : _selectedSubType == subType;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isMultiSelect) {
            // Mode multi-sélection : toggle
            if (_selectedSubTypes.contains(subType)) {
              _selectedSubTypes.remove(subType);
            } else {
              _selectedSubTypes.add(subType);
            }
          } else {
            // Mode single : remplacer
            _selectedSubType = subType;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.grey200,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icône avec fond coloré
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : AppTheme.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.darkGray.withValues(alpha: 0.8),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            // Indicateur de sélection
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : AppTheme.gray,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
