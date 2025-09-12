import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import 'become_seller/choice_step_page.dart';
import 'become_seller/sell_part_step_page.dart';
import 'become_seller/plate_step_page.dart';
import 'become_seller/congrats_step_page.dart';
import '../../../../../shared/presentation/widgets/app_menu.dart';
import '../controllers/part_advertisement_controller.dart';
import '../../data/models/part_advertisement_model.dart';

class BecomeSellerPage extends ConsumerStatefulWidget {
  const BecomeSellerPage({super.key});

  @override
  ConsumerState<BecomeSellerPage> createState() => _BecomeSellerPageState();
}

class _BecomeSellerPageState extends ConsumerState<BecomeSellerPage> {
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

    try {
      // Créer l'annonce en base de données
      await _createAdvertisement();
      
      // Succès : passer à l'étape suivante
      setState(() {
        _isSubmitting = false;
        _currentStep = 3;
      });
    } catch (e) {
      // Erreur : afficher un message et rester sur la même page
      setState(() {
        _isSubmitting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création de l\'annonce: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _createAdvertisement() async {
    try {
      print('🚀 [BecomeSellerPage] Création annonce:');
      print('   Type: $_selectedChoice');
      print('   Pièce: $_partName');
      print('   Plaque: $_vehiclePlate');
      
      // Créer les paramètres pour l'annonce
      final params = CreatePartAdvertisementParams(
        partType: _selectedChoice, // 'engine' ou 'body' du front-end
        partName: _partName,
        vehiclePlate: _vehiclePlate.isNotEmpty ? _vehiclePlate : null,
        description: 'Pièce mise en vente par un particulier',
      );
      
      // Appeler le controller pour créer l'annonce
      final controller = ref.read(partAdvertisementControllerProvider.notifier);
      final success = await controller.createPartAdvertisement(params);
      
      if (success) {
        print('✅ [BecomeSellerPage] Annonce créée avec succès');
      } else {
        final state = ref.read(partAdvertisementControllerProvider);
        print('❌ [BecomeSellerPage] Erreur création annonce: ${state.error}');
        throw Exception(state.error ?? 'Erreur inconnue');
      }
    } catch (e) {
      print('❌ [BecomeSellerPage] Erreur création annonce: $e');
      rethrow; // Propager l'erreur pour la gestion dans l'UI
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
