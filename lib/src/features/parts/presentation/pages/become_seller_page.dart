import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../../features/parts/presentation/pages/particulier/become_seller/choice_step_page.dart';
import '../../../../features/parts/presentation/pages/particulier/become_seller/sell_part_step_page.dart';
import '../../../../features/parts/presentation/pages/particulier/become_seller/plate_step_page.dart';
import '../../../../features/parts/presentation/pages/particulier/become_seller/congrats_step_page.dart';
import '../../../../shared/presentation/widgets/app_menu.dart';

class BecomeSellerPage extends StatefulWidget {
  const BecomeSellerPage({super.key});

  @override
  State<BecomeSellerPage> createState() => _BecomeSellerPageState();
}

class _BecomeSellerPageState extends State<BecomeSellerPage> {
  int _currentStep = 0;
  String selectedChoice = '';
  String partName = '';
  bool hasMultipleParts = false;

  void _onChoiceSelected(String choice) {
    setState(() {
      selectedChoice = choice;
      _currentStep = 1;
    });
  }

  void _onPartSubmitted(String partName, bool hasMultiple) {
    setState(() {
      partName = partName;
      hasMultipleParts = hasMultiple;
      _currentStep = 2;
    });
  }

  void _goToNextStep() {
    setState(() => _currentStep = 3);
  }

  void _goToPreviousStep() {
    setState(() => _currentStep--);
  }

  void _finishFlow() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        foregroundColor: AppTheme.black,
        centerTitle: false,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  HapticHelper.light();
                  _goToPreviousStep();
                },
              )
            : null,
        actions: const [
          AppMenu(),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: switch (_currentStep) {
            0 => ChoiceStepPage(
                key: const ValueKey(0),
                onChoiceSelected: _onChoiceSelected,
              ),
            1 => SellPartStepPage(
                key: const ValueKey(1),
                onPartSubmitted: _onPartSubmitted,
                selectedCategory: selectedChoice,
              ),
            2 => PlateStepPage(
                key: const ValueKey(2),
                onNext: _goToNextStep,
              ),
            _ => CongratsStepPage(
                key: const ValueKey(3),
                onFinish: _finishFlow,
              ),
          },
        ),
      ),
    );
  }
}
