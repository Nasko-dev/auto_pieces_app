import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/providers/immatriculation_providers.dart';
import 'become_seller/choice_step_page.dart';
import 'become_seller/sell_part_step_page.dart';
import 'become_seller/plate_step_page.dart';
import 'become_seller/congrats_step_page.dart';
import '../../../../../shared/presentation/widgets/app_menu.dart';
import '../../../../../shared/presentation/widgets/seller_menu.dart';
import '../../controllers/part_advertisement_controller.dart';
import '../../../data/models/part_advertisement_model.dart';

enum SellerMode { particulier, vendeur }

class BecomeSellerPage extends ConsumerStatefulWidget {
  final SellerMode mode;
  
  const BecomeSellerPage({
    super.key,
    this.mode = SellerMode.particulier,
  });

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

  @override
  void initState() {
    super.initState();
    
    // Si c'est un vendeur, forcer la re-vérification des limitations
    if (widget.mode == SellerMode.vendeur) {
      print('🔄 [BecomeSellerPage] Mode vendeur détecté - force refresh des limitations...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier = ref.read(vehicleSearchProvider.notifier);
        notifier.forceRefreshActiveRequestCheck();
      });
    }
  }

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
      
      // Récupérer les informations du véhicule depuis le provider
      final vehicleState = ref.read(vehicleSearchProvider);
      String description = 'Pièce mise en vente par un particulier';
      
      // Enrichir la description avec les infos du véhicule si disponibles
      if (vehicleState.vehicleInfo != null) {
        final info = vehicleState.vehicleInfo!;
        final vehicleDetails = <String>[];
        
        if (info.make != null) vehicleDetails.add(info.make!);
        if (info.model != null) vehicleDetails.add(info.model!);
        if (info.engineSize != null) vehicleDetails.add(info.engineSize!);
        if (info.fuelType != null) vehicleDetails.add(info.fuelType!);
        
        if (vehicleDetails.isNotEmpty) {
          description += ' - Véhicule: ${vehicleDetails.join(' ')}';
        }
      }
      
      // Mapper les valeurs du frontend vers la base de données
      String dbPartType;
      switch (_selectedChoice) {
        case 'engine':
        case 'moteur':
          dbPartType = 'engine';
          break;
        case 'body':
        case 'carrosserie':
        case 'lesdeux':
        default:
          dbPartType = 'body'; // Par défaut, tout ce qui n'est pas moteur est carrosserie
          break;
      }
      
      // Extraire les informations du véhicule
      String? vehicleBrand, vehicleModel, vehicleEngine;
      int? vehicleYear;
      
      if (vehicleState.vehicleInfo != null) {
        final info = vehicleState.vehicleInfo!;
        vehicleBrand = info.make;
        vehicleModel = info.model;
        vehicleYear = info.year;
        vehicleEngine = info.engineSize ?? info.fuelType;
      }
      
      // Créer les paramètres pour l'annonce
      final params = CreatePartAdvertisementParams(
        partType: dbPartType, // Valeur mappée pour la base de données
        partName: _partName,
        vehiclePlate: _vehiclePlate.isNotEmpty ? _vehiclePlate : null,
        vehicleBrand: vehicleBrand,
        vehicleModel: vehicleModel,
        vehicleYear: vehicleYear,
        vehicleEngine: vehicleEngine,
        description: description,
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
    if (widget.mode == SellerMode.particulier) {
      context.go('/home');
    } else {
      context.go('/seller');
    }
  }

  // Méthode de debug temporaire
  void _debugRefresh() async {
    print('🔧 [DEBUG] Force refresh demandé manuellement...');
    final notifier = ref.read(vehicleSearchProvider.notifier);
    await notifier.forceRefreshActiveRequestCheck();
    print('🔧 [DEBUG] Force refresh terminé');
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
        actions: [
          // Bouton debug temporaire pour vendeurs
          if (widget.mode == SellerMode.vendeur)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.blue),
              onPressed: _debugRefresh,
              tooltip: 'Debug: Refresh limitations',
            ),
          widget.mode == SellerMode.particulier 
              ? const AppMenu() 
              : const SellerMenu(),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Container(
            key: ValueKey(_currentStep),
            child: switch (_currentStep) {
              0 => ChoiceStepPage(
                  onChoiceSelected: _onChoiceSelected,
                ),
              1 => SellPartStepPage(
                  selectedCategory: _selectedChoice,
                  onPartSubmitted: _onPartSubmitted,
                ),
              2 => PlateStepPage(
                  onPlateSubmitted: _onPlateSubmitted,
                  isLoading: _isSubmitting,
                ),
              _ => CongratsStepPage(
                  onFinish: _finishFlow,
                ),
            },
          ),
        ),
      ),
    );
  }
}
