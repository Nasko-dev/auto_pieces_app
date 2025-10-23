import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/theme/app_colors.dart';

class QuantityStepPage extends StatefulWidget {
  final String selectedCategory;
  final String selectedSubType;
  final Function(String quantityType) onQuantitySelected;

  const QuantityStepPage({
    super.key,
    required this.selectedCategory,
    required this.selectedSubType,
    required this.onQuantitySelected,
  });

  @override
  State<QuantityStepPage> createState() => _QuantityStepPageState();
}

class _QuantityStepPageState extends State<QuantityStepPage> {
  String?
      _selectedQuantityType; // 'multiple', 'few', 'complete_engine', 'complete_transmission'

  Color _getCategoryColor() {
    switch (widget.selectedSubType) {
      case 'engine_parts':
        return const Color(0xFF2196F3); // Bleu
      case 'transmission_parts':
        return const Color(0xFF4CAF50); // Vert
      case 'body_parts':
        return const Color(0xFFFF9800); // Orange
      case 'both': // Moteur + Boîte
      case 'engine_body': // Moteur + Carrosserie
      case 'transmission_body': // Boîte + Carrosserie
      case 'all_three': // Les 3
        return const Color(0xFFFF9800); // Orange pour combinaisons
      default:
        return const Color(0xFFFF9800); // Orange par défaut
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
              const Text(
                'Combien de pièces\navez-vous ?',
                style: TextStyle(
                  fontSize: 32,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkBlue,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sélectionnez l\'option qui correspond à votre situation',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: _buildQuantityCards(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedQuantityType != null
                      ? () => widget.onQuantitySelected(_selectedQuantityType!)
                      : null,
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

  List<Widget> _buildQuantityCards() {
    return [
      _buildQuantityCard(
        quantityType: 'multiple',
        title: 'J\'ai toutes les pièces ou presque',
        subtitle: 'Vous avez plusieurs pièces à vendre',
        icon: Icons.inventory_outlined,
      ),
      const SizedBox(height: 16),
      _buildQuantityCard(
        quantityType: 'few',
        title: 'J\'ai peu de pièces',
        subtitle: 'Vous avez quelques pièces à vendre',
        icon: Icons.settings_outlined,
      ),
    ];
  }

  Widget _buildQuantityCard({
    required String quantityType,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedQuantityType == quantityType;
    final color = _getCategoryColor();

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedQuantityType = quantityType;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? color.withValues(alpha: 0.3) : AppColors.grey200,
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
