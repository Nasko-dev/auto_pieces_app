import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/providers/immatriculation_providers.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/utils/haptic_helper.dart';
import 'become_seller/choice_step_page.dart';
import 'become_seller/sub_type_step_page.dart';
import 'become_seller/quantity_step_page.dart';
import '../Vendeur/add_advertisement/seller_parts_selection_page.dart';
import 'become_seller/plate_step_page.dart';
import 'become_seller/congrats_step_page.dart';
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
  String _selectedSubType =
      ''; // engine_parts, transmission_parts, body_parts, both
  String _quantityType =
      ''; // multiple, few, complete_engine, complete_transmission
  String _partName = '';
  String _vehiclePlate = '';
  bool _isSubmitting = false;
  String? _createdAdvertisementId;

  @override
  void initState() {
    super.initState();

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
      // Si moteur ou lesdeux, aller au sous-type (step 1)
      // Sinon, aller direct à la quantité (step 2)
      if (choice == 'moteur' || choice == 'lesdeux') {
        _currentStep = 1; // SubTypeStepPage
      } else {
        _selectedSubType = 'body_parts'; // Par défaut pour carrosserie
        _currentStep = 2; // QuantityStepPage
      }
    });
  }

  void _onSubTypeSelected(String subType) {
    setState(() {
      _selectedSubType = subType;
      _currentStep = 2; // QuantityStepPage
    });
  }

  void _onQuantitySelected(String quantity) {
    setState(() {
      _quantityType = quantity;
      // Toujours aller à la page de sélection des pièces
      _currentStep = 3; // SellerPartsSelectionPage
    });
  }

  void _onPartsSelected(List<String> parts, String completeOption) {
    setState(() {
      // Construire le nom de la pièce selon la sélection
      final partNames = <String>[];

      // Traiter les options complètes (peuvent être multiples, séparées par virgule)
      if (completeOption.isNotEmpty) {
        final completeOptions = completeOption.split(',');
        for (final option in completeOptions) {
          switch (option) {
            case 'moteur_complet':
              partNames.add('Moteur complet');
              break;
            case 'boite_complete':
              partNames.add('Boîte complète');
              break;
            case 'carrosserie_complete':
              partNames.add('Carrosserie complète');
              break;
            case 'vehicule_complet':
              partNames.add('Véhicule complet');
              break;
          }
        }
      }

      // Traiter les pièces manquantes/présentes
      if (parts.isNotEmpty) {
        if (_quantityType == 'multiple') {
          // +5 pièces : les pièces listées sont celles qu'on N'A PAS
          partNames.add('Pièces manquantes: ${parts.join(', ')}');
        } else {
          // -5 pièces : les pièces listées sont celles qu'on A
          partNames.add(parts.join(', '));
        }
      }

      // Combiner tous les noms
      _partName = partNames.isNotEmpty ? partNames.join(' + ') : 'Pièces auto';

      _currentStep = 4; // PlateStepPage
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
        _currentStep = 5; // CongratsStepPage
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
    debugPrint('📝 [BecomeSellerPage] Début _createAdvertisement');
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

      debugPrint('📝 [BecomeSellerPage] Paramètres annonce:');
      debugPrint('   - Type: $dbPartType');
      debugPrint('   - Nom: $_partName');
      debugPrint('   - Véhicule: $vehicleBrand $vehicleModel $vehicleYear');

      final controller = ref.read(partAdvertisementControllerProvider.notifier);
      debugPrint('📡 [BecomeSellerPage] Appel createPartAdvertisement...');
      final success = await controller.createPartAdvertisement(params);
      debugPrint('📡 [BecomeSellerPage] Résultat création: $success');

      if (!success) {
        final state = ref.read(partAdvertisementControllerProvider);
        throw Exception(state.error ?? 'Erreur inconnue');
      }

      // Récupérer l'ID de l'annonce créée
      final state = ref.read(partAdvertisementControllerProvider);
      debugPrint('📝 [BecomeSellerPage] Récupération ID annonce...');
      if (state.currentAdvertisement != null) {
        _createdAdvertisementId = state.currentAdvertisement!.id;
        debugPrint(
            '✅ [BecomeSellerPage] ID récupéré: $_createdAdvertisementId');
      } else {
        debugPrint('❌ [BecomeSellerPage] Aucune annonce dans le state');
      }
    } catch (e) {
      debugPrint('❌ [BecomeSellerPage] Erreur création: $e');
      rethrow;
    }
    debugPrint('📝 [BecomeSellerPage] Fin _createAdvertisement');
  }

  void _goToPreviousStep() {
    setState(() {
      // Gérer le retour selon le flow
      if (_currentStep == 1) {
        // Depuis SubTypeStep, retour à Choice
        _currentStep = 0;
      } else if (_currentStep == 2) {
        // Depuis QuantityStep, retour selon le flow
        if (_selectedChoice == 'moteur' || _selectedChoice == 'lesdeux') {
          _currentStep = 1; // Retour à SubType
        } else {
          _currentStep = 0; // Retour à Choice
        }
      } else if (_currentStep == 3) {
        // Depuis SellerPartsSelectionPage, retour à QuantityStep
        _currentStep = 2;
      } else if (_currentStep == 4) {
        // Depuis PlateStep, retour à SellerPartsSelectionPage
        _currentStep = 3;
      } else {
        _currentStep--;
      }
    });
  }

  void _finishFlow() {
    if (widget.mode == SellerMode.particulier) {
      context.go('/home');
    } else {
      context.go('/seller/home');
    }
  }

  void _onNameAdvertisement() async {
    debugPrint('🏷️ [BecomeSellerPage] Début _onNameAdvertisement');
    debugPrint(
        '🏷️ [BecomeSellerPage] ID annonce créée: $_createdAdvertisementId');
    debugPrint('🏷️ [BecomeSellerPage] Nom actuel: $_partName');

    if (_createdAdvertisementId == null) {
      debugPrint('❌ [BecomeSellerPage] Pas d\'ID d\'annonce, annulation');
      return;
    }

    final controller = TextEditingController(text: _partName);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Nommer l\'annonce',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.darkBlue,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Donnez un nom personnalisé à votre annonce',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Ex: Moteur 2.0 TDI excellent état',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryBlue,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppTheme.gray),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      debugPrint('✅ [BecomeSellerPage] Nouveau nom saisi: "$result"');
      debugPrint('🔄 [BecomeSellerPage] Début mise à jour de l\'annonce');

      // Mettre à jour le nom de l'annonce
      setState(() {
        _isSubmitting = true;
      });

      try {
        debugPrint(
            '📡 [BecomeSellerPage] Appel updateAdvertisement avec ID: $_createdAdvertisementId');
        final success = await ref
            .read(partAdvertisementControllerProvider.notifier)
            .updateAdvertisement(_createdAdvertisementId!, {
          'part_name': result,
        });
        debugPrint(
            '📡 [BecomeSellerPage] Résultat updateAdvertisement: $success');

        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          if (success) {
            debugPrint('✅ [BecomeSellerPage] Mise à jour réussie !');
            _partName = result;
            debugPrint(
                '✅ [BecomeSellerPage] Nouveau nom local enregistré: $_partName');
            notificationService.success(
              context,
              'Nom de l\'annonce mis à jour',
              subtitle: 'Votre annonce a bien été renommée',
            );
          } else {
            final state = ref.read(partAdvertisementControllerProvider);
            debugPrint('❌ [BecomeSellerPage] Échec de la mise à jour');
            debugPrint('❌ [BecomeSellerPage] Erreur: ${state.error}');
            notificationService.error(
              context,
              'Erreur',
              subtitle: state.error ?? 'Impossible de mettre à jour le nom',
            );
          }
        }
      } catch (e) {
        debugPrint('❌ [BecomeSellerPage] Exception lors de la mise à jour: $e');
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          notificationService.error(
            context,
            'Erreur',
            subtitle: e.toString(),
          );
        }
      }
    } else {
      debugPrint('❌ [BecomeSellerPage] Dialogue annulé ou nom vide');
      debugPrint('❌ [BecomeSellerPage] Result: $result, mounted: $mounted');
    }

    debugPrint('🏷️ [BecomeSellerPage] Fin _onNameAdvertisement');
  }

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
                        icon: const Icon(Icons.chevron_left,
                            color: AppTheme.darkGray),
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
    return SafeArea(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Container(
          key: ValueKey(_currentStep),
          child: switch (_currentStep) {
            0 => ChoiceStepPage(
                onChoiceSelected: _onChoiceSelected,
              ),
            1 => SubTypeStepPage(
                selectedCategory: _selectedChoice,
                onSubTypeSelected: _onSubTypeSelected,
              ),
            2 => QuantityStepPage(
                selectedCategory: _selectedChoice,
                selectedSubType: _selectedSubType,
                onQuantitySelected: _onQuantitySelected,
              ),
            3 => SellerPartsSelectionPage(
                selectedCategory: _selectedSubType,
                hasMultipleParts: _quantityType == 'multiple',
                onSubmit: _onPartsSelected,
              ),
            4 => PlateStepPage(
                selectedChoice: _selectedChoice,
                selectedSubType: _selectedSubType,
                onPlateSubmitted: _onPlateSubmitted,
                isLoading: _isSubmitting,
              ),
            _ => CongratsStepPage(
                onFinish: _finishFlow,
                onNameAdvertisement: _createdAdvertisementId != null
                    ? _onNameAdvertisement
                    : null,
              ),
          },
        ),
      ),
    );
  }
}
