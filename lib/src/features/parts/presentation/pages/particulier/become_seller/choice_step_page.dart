import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import 'shared_widgets.dart';

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
                  const Text(
                    'Déposez votre annonce\nen 1 minute',
                    style: TextStyle(
                      fontSize: 32,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkBlue,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Vendez-vous des pièces concernant le\nmoteur seulement, ou avez-vous aussi\ndes pièces concernant la carrosserie\nou l\'intérieur du véhicule ?',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.35,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 24),
                  BecomeSellerSharedWidgets.buildOptionCard(
                    label: 'Pièces moteur',
                    selected: _choice == 'moteur',
                    icon: BecomeSellerSharedWidgets.buildIcon(Icons.settings),
                    onTap: () => setState(() => _choice = 'moteur'),
                  ),
                  const SizedBox(height: 12),
                  BecomeSellerSharedWidgets.buildOptionCard(
                    label: 'Carrosserie / Intérieur',
                    selected: _choice == 'carrosserie',
                    icon: BecomeSellerSharedWidgets.buildIcon(Icons.directions_car),
                    onTap: () => setState(() => _choice = 'carrosserie'),
                  ),
                  const SizedBox(height: 12),
                  BecomeSellerSharedWidgets.buildOptionCard(
                    label: 'Les deux',
                    selected: _choice == 'lesdeux',
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.settings, size: 16, color: AppTheme.darkBlue),
                        const SizedBox(width: 4),
                        Icon(Icons.directions_car, size: 16, color: AppTheme.darkBlue),
                      ],
                    ),
                    onTap: () => setState(() => _choice = 'lesdeux'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          BecomeSellerSharedWidgets.buildPrimaryButton(
            label: 'Suivant',
            enabled: _choice.isNotEmpty,
            onPressed:
                _choice.isNotEmpty
                    ? () => widget.onChoiceSelected(_choice)
                    : null,
          ),
        ],
      ),
    );
  }
}
