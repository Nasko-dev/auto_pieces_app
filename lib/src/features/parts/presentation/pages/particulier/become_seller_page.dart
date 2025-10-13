import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/providers/immatriculation_providers.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/utils/haptic_helper.dart';
import 'become_seller/choice_step_page.dart';
import 'become_seller/sell_part_step_page.dart';
import 'become_seller/plate_step_page.dart';
import 'become_seller/congrats_step_page.dart';
// Pages vendeur
import '../Vendeur/add_advertisement/seller_choice_step_page.dart';
import '../Vendeur/add_advertisement/seller_parts_step_page.dart';
import '../Vendeur/add_advertisement/seller_plate_step_page.dart';
import '../Vendeur/add_advertisement/seller_congrats_step_page.dart';
import '../../../../../shared/presentation/widgets/app_header.dart';
import '../../../../../shared/presentation/widgets/app_menu.dart';
import '../../../../../shared/presentation/widgets/seller_header.dart';
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
  double _price = 0.0;
  bool hasMultipleParts = false;
  String _vehiclePlate = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    
    // Si c'est un vendeur, forcer la re-vérification des limitations
    if (widget.mode == SellerMode.vendeur) {
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
      hasMultipleParts = hasMultiple;
      _currentStep = 2;
    });
  }

  void _onSellerPartSubmitted(String partName, double price, bool hasMultiple) {
    setState(() {
      _partName = partName;
      _price = price;
      hasMultipleParts = hasMultiple;
      _currentStep = 2;
    });
  }

  void _onPlateSubmitted(String plate) async {
    setState(() {
      _vehiclePlate = plate;
      _isSubmitting = true;
    });

    try {
      await _createAdvertisement();

      setState(() {
        _isSubmitting = false;
        _currentStep = 3;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        notificationService.error(
          context,
          'Erreur lors de la création de l\'annonce',
          subtitle: e.toString(),
        );
      }
    }
  }

  Future<void> _createAdvertisement() async {
    try {
      final vehicleState = ref.read(vehicleSearchProvider);
      String description = 'Pièce mise en vente par un particulier';

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
          dbPartType = 'body';
          break;
      }

      String? vehicleBrand, vehicleModel, vehicleEngine;
      int? vehicleYear;

      if (vehicleState.vehicleInfo != null) {
        final info = vehicleState.vehicleInfo!;
        vehicleBrand = info.make;
        vehicleModel = info.model;
        vehicleYear = info.year;
        vehicleEngine = info.engineSize ?? info.fuelType;
      }

      final params = CreatePartAdvertisementParams(
        partType: dbPartType,
        partName: _partName,
        vehiclePlate: _vehiclePlate.isNotEmpty ? _vehiclePlate : null,
        vehicleBrand: vehicleBrand,
        vehicleModel: vehicleModel,
        vehicleYear: vehicleYear,
        vehicleEngine: vehicleEngine,
        description: description,
      );

      final controller = ref.read(partAdvertisementControllerProvider.notifier);
      final success = await controller.createPartAdvertisement(params);

      if (!success) {
        final state = ref.read(partAdvertisementControllerProvider);
        throw Exception(state.error ?? 'Erreur inconnue');
      }
    } catch (e) {
      rethrow;
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

  // Méthode de debug temporaire - Désactivée en production
  // void _debugRefresh() async {
  //   final notifier = ref.read(vehicleSearchProvider.notifier);
  //   await notifier.forceRefreshActiveRequestCheck();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Column(
        children: [
          widget.mode == SellerMode.particulier
              ? AppHeader(
                  title: 'Devenir vendeur',
                  actions: [
                    if (_currentStep > 0)
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: AppTheme.darkGray),
                        onPressed: () {
                          HapticHelper.light();
                          _goToPreviousStep();
                        },
                        tooltip: 'Retour',
                      ),
                    const AppMenu(),
                  ],
                )
              : SellerHeader(
                  title: 'Déposer une annonce',
                  showBackButton: true,
                  onBackPressed: _currentStep > 0
                    ? _goToPreviousStep
                    : () => context.go('/seller/add'),
                ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // Utiliser les pages vendeur si mode = vendeur
    if (widget.mode == SellerMode.vendeur) {
      return SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Container(
            key: ValueKey(_currentStep),
            child: switch (_currentStep) {
              0 => SellerChoiceStepPage(
                  onChoiceSelected: _onChoiceSelected,
                ),
              1 => SellerPartsStepPage(
                  selectedChoice: _selectedChoice,
                  onPartSubmitted: _onSellerPartSubmitted,
                ),
              2 => SellerPlateStepPage(
                  partName: _partName,
                  price: _price,
                  onPlateSubmitted: _onPlateSubmitted,
                  isSubmitting: _isSubmitting,
                ),
              _ => SellerCongratsStepPage(
                  partName: _partName,
                  price: _price,
                  isRequest: false,
                  onFinish: _finishFlow,
                ),
            },
          ),
        ),
      );
    }

    // Pages particuliers (flux original)
    return SafeArea(
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
    );
  }
}
