import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../shared/presentation/widgets/license_plate_input.dart';
import '../../../../../../core/providers/immatriculation_providers.dart';
import 'seller_shared_widgets.dart';

class SellerPlateStepPage extends ConsumerStatefulWidget {
  final String partName;
  final double price;
  final Function(String plate) onPlateSubmitted;
  final bool isSubmitting;

  const SellerPlateStepPage({
    super.key,
    required this.partName,
    required this.price,
    required this.onPlateSubmitted,
    required this.isSubmitting,
  });

  @override
  ConsumerState<SellerPlateStepPage> createState() => _SellerPlateStepPageState();
}

class _SellerPlateStepPageState extends ConsumerState<SellerPlateStepPage> {
  final TextEditingController _plateController = TextEditingController();
  bool _isValidated = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Plaque d\'immatriculation',
                    style: TextStyle(
                      fontSize: 32,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkBlue,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pour finaliser votre annonce "${widget.partName}" au prix de ${widget.price.toStringAsFixed(0)}€, renseignez la plaque d\'immatriculation du véhicule.',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.35,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Résumé de l'annonce
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Résumé de votre annonce :',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.build, size: 16, color: AppTheme.primaryBlue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.partName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.darkBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.euro, size: 16, color: AppTheme.success),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.price.toStringAsFixed(0)} €',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Widget de recherche de plaque
                  LicensePlateInput(
                    initialPlate: _plateController.text,
                    onPlateValidated: (plate) {
                      setState(() {
                        _plateController.text = plate;
                        _isValidated = true;
                      });
                    },
                    showManualOption: false,
                    autoSearch: true,
                  ),

                  const SizedBox(height: 24),

                  // Information sur l'utilisation des données
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Ces informations seront utilisées pour identifier précisément votre véhicule et ses pièces compatibles.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.darkGray,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SellerSharedWidgets.buildPrimaryButton(
            label: widget.isSubmitting ? 'Publication...' : 'Publier l\'annonce',
            enabled: _isValidated && !widget.isSubmitting,
            isLoading: widget.isSubmitting,
            onPressed: (_isValidated && !widget.isSubmitting) 
                ? () => widget.onPlateSubmitted(_plateController.text)
                : null,
          ),
        ],
      ),
    );
  }
}