import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import 'become_seller/choice_step_page.dart';
import 'become_seller/sell_part_step_page.dart';
import 'become_seller/plate_step_page.dart';
import 'become_seller/congrats_step_page.dart';
import '../../../../../shared/presentation/widgets/app_menu.dart';

class BecomeSellerPage extends StatefulWidget {
  const BecomeSellerPage({super.key});

  @override
  State<BecomeSellerPage> createState() => _BecomeSellerPageState();
}

class _BecomeSellerPageState extends State<BecomeSellerPage> {
  int _currentStep = 0;
  String _selectedChoice = '';
  String _partName = '';
  bool _hasMultipleParts = false;
  String _vehiclePlate = '';
  bool _isSubmitting = false;

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

  void _onPlateSubmitted(String plate) async {
    setState(() {
      _vehiclePlate = plate;
      _isSubmitting = true;
    });

    // TODO: Sauvegarder l'annonce en base de données
    await _createAdvertisement();
    
    setState(() {
      _isSubmitting = false;
      _currentStep = 3;
    });
  }

  Future<void> _createAdvertisement() async {
    try {
      print('🚀 [BecomeSellerPage] Création annonce:');
      print('   Type: $_selectedChoice');
      print('   Pièce: $_partName');
      print('   Plaque: $_vehiclePlate');
      
      // TODO: Implémenter l'appel à l'API
      await Future.delayed(const Duration(seconds: 1)); // Simulation
      
      print('✅ [BecomeSellerPage] Annonce créée avec succès');
    } catch (e) {
      print('❌ [BecomeSellerPage] Erreur création annonce: $e');
      // TODO: Gérer l'erreur
    }
  }

  void _goToPreviousStep() {
    setState(() => _currentStep--);
  }

  void _finishFlow() {
    context.go('/home');
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
                icon: const Icon(Icons.arrow_back),
                onPressed: _goToPreviousStep,
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
              ),
            2 => PlateStepPage(
                key: const ValueKey(2),
                onPlateSubmitted: _onPlateSubmitted,
                isLoading: _isSubmitting,
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
