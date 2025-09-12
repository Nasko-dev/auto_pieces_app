import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'become_seller/sell_part_step_page.dart';

class SellOnePartCardScreen extends StatelessWidget {
  const SellOnePartCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SellPartStepPage(
      selectedCategory: 'lesdeux', // Pas de filtre sur cette page générique
      onClose: () => Navigator.of(context).maybePop(),
      onPartSubmitted: (partName, hasMultiple) {
        // TODO: brancher avec l'étape suivante ou fermer selon les besoins
        Navigator.of(context).maybePop();
      },
    );
  }
}