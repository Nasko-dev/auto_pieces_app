import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import 'shared_widgets.dart';

class CongratsStepPage extends StatelessWidget {
  final VoidCallback onFinish;

  const CongratsStepPage({
    super.key,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1763FF), width: 6),
            ),
            child: const Center(
              child: Icon(Icons.check, size: 64, color: Color(0xFF1763FF)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Félicitations!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.darkBlue,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Votre annonce a bien été déposée.\nElle sera bientôt visible sur notre site.',
            style: TextStyle(
              fontSize: 16,
              height: 1.35,
              color: AppTheme.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          BecomeSellerSharedWidgets.buildPrimaryButton(
            label: 'Terminer',
            onPressed: onFinish,
            enabled: true,
          ),
        ],
      ),
    );
  }
}