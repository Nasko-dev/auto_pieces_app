import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/providers/immatriculation_providers.dart';
import '../../../../../../shared/presentation/widgets/license_plate_input.dart';
import 'shared_widgets.dart';

class PlateStepPage extends ConsumerStatefulWidget {
  final Function(String plate)? onPlateSubmitted;
  final VoidCallback? onNext;
  final bool isLoading;

  const PlateStepPage({
    super.key,
    this.onPlateSubmitted,
    this.onNext,
    this.isLoading = false,
  }) : assert(onPlateSubmitted != null || onNext != null,
            'Either onPlateSubmitted or onNext must be provided');

  @override
  ConsumerState<PlateStepPage> createState() => _PlateStepPageState();
}

class _PlateStepPageState extends ConsumerState<PlateStepPage> {
  bool _manual = false;
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _manualEngineController =
      TextEditingController(); // ✅ FIX: Controller pour motorisation manuelle
  final ScrollController _scrollController = ScrollController();
  bool _showVehicleInfo = false;

  @override
  void dispose() {
    _plateController.dispose();
    _manualEngineController.dispose(); // ✅ FIX: Nettoyer le controller
    _scrollController.dispose();
    super.dispose();
  }

  String _getVehicleInfo(WidgetRef ref) {
    if (_manual) {
      return _manualEngineController.text.isNotEmpty
          ? _manualEngineController.text
          : 'Motorisation manuelle';
    } else {
      final vehicleState = ref.read(vehicleSearchProvider);
      if (vehicleState.vehicleInfo != null) {
        final info = vehicleState.vehicleInfo!;
        final parts = <String>[];

        if (info.make != null) parts.add(info.make!);
        if (info.model != null) parts.add(info.model!);
        if (info.engineSize != null) parts.add(info.engineSize!);
        if (info.fuelType != null) parts.add(info.fuelType!);
        if (info.engineCode != null) parts.add(info.engineCode!);

        return parts.isNotEmpty
            ? parts.join(' ')
            : 'Informations véhicule disponibles';
      }
      return 'Véhicule non identifié';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Dernière étape avant de\ndéposer votre annonce',
              style: TextStyle(
                fontSize: 28,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkBlue,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Merci de renseigner la plaque\nd'immatriculation de votre véhicule afin que\nnous puissions prendre en compte sa\nmotorisation. Si vous n'avez pas la plaque\nd'immatriculation, vous pouvez renseigner\nmanuellement la motorisation de votre\nvéhicule.",
              style: TextStyle(
                fontSize: 16,
                height: 1.35,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 24),
            if (!_manual)
              LicensePlateInput(
                initialPlate: _plateController.text,
                allowWithActiveRequest:
                    true, // ✅ FIX: Permettre de vendre même avec demande active
                onPlateValidated: (plate) {
                  setState(() {
                    _plateController.text = plate;
                    _showVehicleInfo = true;
                  });
                  // Auto-scroll vers la section véhicule
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  });
                },
                onManualMode: () {
                  setState(() {
                    _manual = true;
                    _showVehicleInfo = false;
                  });
                },
                showManualOption: false,
                autoSearch: true,
              ),
            if (_manual) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _manualEngineController,
                decoration: InputDecoration(
                  labelText: 'Ex: 1.6 HDi 115, 2.0 TFSI 200',
                  hintText: 'Ex: 1.6 HDi 115, 2.0 TFSI 200',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() {}), // Pour activer le bouton
              ),
            ],

            // Affichage des informations véhicule après validation
            if (_showVehicleInfo && !_manual) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Véhicule identifié',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getVehicleInfo(ref),
                      style: const TextStyle(
                        color: AppTheme.darkGray,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            BecomeSellerSharedWidgets.buildGhostButton(
              label: _manual ? 'Utiliser la plaque' : 'Remplir manuellement',
              onPressed: () => setState(() {
                _manual = !_manual;
                _showVehicleInfo = false;
              }),
            ),
            const SizedBox(height: 80),
            BecomeSellerSharedWidgets.buildPrimaryButton(
              label: widget.isLoading
                  ? 'Création en cours...'
                  : (widget.onPlateSubmitted != null
                      ? 'Déposer l\'annonce'
                      : 'Suivant'),
              enabled: !widget.isLoading &&
                  (_plateController.text.isNotEmpty ||
                      (_manual &&
                          _manualEngineController.text
                              .isNotEmpty) || // ✅ FIX: Vérifier que le champ manuel a du texte
                      _showVehicleInfo),
              onPressed: widget.isLoading
                  ? null
                  : () {
                      if (widget.onPlateSubmitted != null) {
                        // ✅ FIX: Passer la motorisation manuelle si mode manuel activé
                        final plateValue =
                            _manual && _manualEngineController.text.isNotEmpty
                                ? _manualEngineController.text
                                : _plateController.text;
                        widget.onPlateSubmitted!(plateValue);
                      } else {
                        widget.onNext!();
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
