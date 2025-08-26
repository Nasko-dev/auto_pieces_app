import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'shared_widgets.dart';

class PlateStepPage extends StatefulWidget {
  final VoidCallback onNext;

  const PlateStepPage({
    super.key,
    required this.onNext,
  });

  @override
  State<PlateStepPage> createState() => _PlateStepPageState();
}

class _PlateStepPageState extends State<PlateStepPage> {
  bool _manual = false;
  final TextEditingController _plateController = TextEditingController();

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Dernière étape avant de\ndéposer votre annonce',
            style: TextStyle(
              fontSize: 28,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: AppTheme.darkBlue,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Merci de renseigner la plaque\nd'immatriculation de votre véhicule afin que\nnous puissions prendre en compte sa\nmotorisation. Si vous n'avez pas la plaque\nd'immatriculation, vous pouvez renseigner\nmanuellement la motorisation de votre\nvéhicule.",
            style: TextStyle(
              fontSize: 16,
              height: 1.35,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 24),
          if (!_manual) BecomeSellerSharedWidgets.buildPlateField(_plateController),
          if (_manual) BecomeSellerSharedWidgets.buildManualBox(),
          const SizedBox(height: 12),
          BecomeSellerSharedWidgets.buildGhostButton(
            label: _manual ? 'Utiliser la plaque' : 'Remplir manuellement',
            onPressed: () => setState(() => _manual = !_manual),
          ),
          const Spacer(),
          BecomeSellerSharedWidgets.buildPrimaryButton(
            label: 'Suivant',
            enabled: true,
            onPressed: widget.onNext,
          ),
        ],
      ),
    );
  }
}