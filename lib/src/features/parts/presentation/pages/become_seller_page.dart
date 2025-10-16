import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../../features/parts/presentation/pages/particulier/become_seller/choice_step_page.dart';
import '../../../../features/parts/presentation/pages/particulier/become_seller/sub_type_step_page.dart';
import '../../../../features/parts/presentation/pages/particulier/become_seller/quantity_step_page.dart';
import '../../../../features/parts/presentation/pages/Vendeur/add_advertisement/seller_parts_selection_page.dart';
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
  String selectedSubType =
      ''; // engine_parts, transmission_parts, body_parts, both
  String quantityType =
      ''; // multiple, few, complete_engine, complete_transmission
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

  void _onQuantitySelected(String quantity) {
    setState(() {
      quantityType = quantity;

      // Si "complet", définir le nom et skip la sélection des pièces
      if (quantity == 'complete_engine') {
        partName = 'Moteur complet';
        _currentStep = 4; // Skip SellerPartsSelectionPage, go to PlateStepPage
      } else if (quantity == 'complete_transmission') {
        partName = 'Boîte complète';
        _currentStep = 4; // Skip SellerPartsSelectionPage, go to PlateStepPage
      } else {
        // Pour multiple ou few, aller à la page de sélection des pièces
        _currentStep = 3; // SellerPartsSelectionPage
      }
    });
  }

  void _onPartsSelected(List<String> parts, String completeOption) {
    setState(() {
      // Construire le nom de la pièce selon la sélection
      if (completeOption.isNotEmpty) {
        switch (completeOption) {
          case 'moteur_complet':
            partName = 'Moteur complet';
            break;
          case 'carrosserie_complete':
            partName = 'Carrosserie complète';
            break;
          case 'vehicule_complet':
            partName = 'Véhicule complet';
            break;
        }
      } else if (parts.isNotEmpty) {
        if (quantityType == 'multiple') {
          // +5 pièces : les pièces listées sont celles qu'on N'A PAS
          partName = 'Toutes pièces sauf: ${parts.join(', ')}';
        } else {
          // -5 pièces : les pièces listées sont celles qu'on A
          partName = parts.join(', ');
        }
      }

      _currentStep = 4; // PlateStepPage
    });
  }

  void _goToNextStep() {
    setState(() => _currentStep++);
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        // Gérer le retour selon le flow
        if (_currentStep == 1) {
          _currentStep = 0;
        } else if (_currentStep == 2) {
          if (selectedChoice == 'moteur' || selectedChoice == 'lesdeux') {
            _currentStep = 1;
          } else {
            _currentStep = 0;
          }
        } else if (_currentStep == 3) {
          // Depuis SellerPartsSelectionPage, retour à QuantityStep
          _currentStep = 2;
        } else if (_currentStep == 4) {
          // Depuis PlateStep, retour selon si on a skippé ou non
          if (quantityType == 'complete_engine' ||
              quantityType == 'complete_transmission') {
            _currentStep =
                2; // Retour direct à QuantityStep (on avait skippé step 3)
          } else {
            _currentStep = 3; // Retour à SellerPartsSelectionPage
          }
        } else {
          _currentStep--;
        }
      });
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
                selectedSubType: selectedSubType,
                onQuantitySelected: _onQuantitySelected,
              ),
            3 => SellerPartsSelectionPage(
                key: const ValueKey(3),
                selectedCategory: selectedChoice,
                hasMultipleParts: quantityType == 'multiple',
                onSubmit: _onPartsSelected,
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
