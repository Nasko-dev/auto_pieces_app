import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/theme/app_colors.dart';

class ChoiceStepPage extends StatefulWidget {
  final Function(String choice) onChoiceSelected;

  const ChoiceStepPage({super.key, required this.onChoiceSelected});

  @override
  State<ChoiceStepPage> createState() => _ChoiceStepPageState();
}

class _ChoiceStepPageState extends State<ChoiceStepPage> {
  String _choice = '';

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
                'Que vendez-vous ?',
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
                'Sélectionnez le type de pièces que vous souhaitez vendre',
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
                    children: [
                      _buildCategoryCard(
                        title: 'Pièces moteur',
                        subtitle:
                            'Moteur, turbo, boîte de vitesses, embrayage...',
                        icon: Icons.settings,
                        color: const Color(0xFF2196F3),
                        isSelected: _choice == 'moteur',
                        onTap: () => setState(() => _choice = 'moteur'),
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryCard(
                        title: 'Carrosserie / Habitacle',
                        subtitle:
                            'Portière, pare-choc, siège, tableau de bord...',
                        icon: Icons.directions_car,
                        color: const Color(0xFF4CAF50),
                        isSelected: _choice == 'carrosserie',
                        onTap: () => setState(() => _choice = 'carrosserie'),
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryCard(
                        title: 'Les deux',
                        subtitle:
                            'Meilleur choix si vous avez un véhicule complet, vendu uniquement pour pièces détachées.\nChaque pièce vendue séparément.',
                        icon: Icons.dashboard_customize,
                        color: const Color(0xFFFF9800),
                        isSelected: _choice == 'lesdeux',
                        onTap: () => setState(() => _choice = 'lesdeux'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _choice.isNotEmpty
                      ? () => widget.onChoiceSelected(_choice)
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

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
