import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/presentation/widgets/seller_menu.dart';
import '../particulier/become_seller/choice_step_page.dart';
import '../particulier/become_seller/sell_part_step_page.dart';
import '../particulier/become_seller/plate_step_page.dart';
import '../particulier/become_seller/congrats_step_page.dart';

class AddAdPage extends StatefulWidget {
  const AddAdPage({super.key});

  @override
  State<AddAdPage> createState() => _AddAdPageState();
}

class _AddAdPageState extends State<AddAdPage> {
  int _currentStep = 0;
  String _selectedChoice = '';
  String _partName = '';
  bool _hasMultipleParts = false;

  void _onChoiceSelected(String choice) {
    setState(() {
      _selectedChoice = choice;
      _currentStep = 1;
    });
  }

  void _onPartSubmitted(String partName, bool hasMultiple) {
    setState(() {
      _partName = partName;
      _hasMultipleParts = hasMultiple;
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
    const blue = Color(0xFF1976D2);
    
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: blue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Déposer une annonce',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [blue, blue.withOpacity(0.8)],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goToPreviousStep,
              )
            : null,
        actions: _currentStep == 0 ? const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: SellerMenu(),
          ),
        ] : null,
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
                selectedCategory: _selectedChoice,
                onPartSubmitted: _onPartSubmitted,
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