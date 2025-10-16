import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../../features/parts/presentation/pages/particulier/become_seller/choice_step_page.dart';
import '../../../../features/parts/presentation/pages/particulier/become_seller/sub_type_step_page.dart';
import '../../../../features/parts/presentation/pages/particulier/become_seller/quantity_step_page.dart';
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
  String selectedSubType = ''; // engine_parts, transmission_parts, body_parts
  bool hasMultipleParts = false;
  String partName = '';

  void _onChoiceSelected(String choice) {
    setState(() {
      selectedChoice = choice;
      // Si moteur ou lesdeux, aller au sub-type (step 1)
      // Sinon, aller directement au quantité (step 2)
      if (choice == 'moteur' || choice == 'lesdeux') {
        _currentStep = 1;
      } else {
        selectedSubType = 'body_parts';
        _currentStep = 2;
      }
    });
  }

  void _onSubTypeSelected(String subType) {
    setState(() {
      selectedSubType = subType;
      _currentStep = 2;
    });
  }

  void _onQuantitySelected(bool hasMultiple) {
    setState(() {
      hasMultipleParts = hasMultiple;
      _currentStep = 3;
    });
  }

  void _onPartSubmitted(String name) {
    setState(() {
      partName = name;
      _currentStep = 4;
    });
  }

  void _goToNextStep() {
    setState(() => _currentStep++);
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
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
            1 => SubTypeStepPage(
                key: const ValueKey(1),
                selectedCategory: selectedChoice,
                onSubTypeSelected: _onSubTypeSelected,
              ),
            2 => QuantityStepPage(
                key: const ValueKey(2),
                selectedCategory: selectedChoice,
                onQuantitySelected: _onQuantitySelected,
              ),
            3 => SellPartStepPage(
                key: const ValueKey(3),
                selectedCategory: selectedChoice,
                hasMultiple: hasMultipleParts,
                onPartSubmitted: _onPartSubmitted,
              ),
            4 => PlateStepPage(
                key: const ValueKey(4),
                selectedChoice: selectedChoice,
                selectedSubType: selectedSubType,
                onNext: _goToNextStep,
              ),
            _ => CongratsStepPage(
                key: const ValueKey(5),
                onFinish: _finishFlow,
              ),
          },
        ),
      ),
    );
  }
}
