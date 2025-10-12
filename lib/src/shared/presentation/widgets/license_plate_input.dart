import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/immatriculation_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import 'french_license_plate.dart';

class LicensePlateInput extends ConsumerStatefulWidget {
  final Function(String plate)? onPlateValidated;
  final Function()? onManualMode;
  final bool showManualOption;
  final bool autoSearch;
  final String? initialPlate;
  final bool allowWithActiveRequest; // ✅ FIX: Permettre même si demande active (pour annonces)

  const LicensePlateInput({
    super.key,
    this.onPlateValidated,
    this.onManualMode,
    this.showManualOption = true,
    this.autoSearch = true,
    this.initialPlate,
    this.allowWithActiveRequest = false, // Par défaut, bloquer (comportement actuel)
  });

  @override
  ConsumerState<LicensePlateInput> createState() => _LicensePlateInputState();
}

class _LicensePlateInputState extends ConsumerState<LicensePlateInput> {

  static const double _radius = 10;

  late TextEditingController _plateController;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController(text: widget.initialPlate ?? '');
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  void _handleSearch() async {
    final plate = _plateController.text.trim();
    if (plate.isEmpty) return;


    setState(() {
      _hasSearched = true;
    });

    await ref.read(vehicleSearchProvider.notifier).searchVehicle(
      plate,
      allowWithActiveRequest: widget.allowWithActiveRequest,
    );

    final state = ref.read(vehicleSearchProvider);

    if (state.vehicleInfo != null) {
      widget.onPlateValidated?.call(plate);
    } else if (state.error != null) {
    }
  }


  @override
  Widget build(BuildContext context) {
    final vehicleState = ref.watch(vehicleSearchProvider);

    // Debug prints pour diagnostiquer l'état

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Merci de renseigner votre plaque\nd\'immatriculation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 12),

        FrenchLicensePlate(
          controller: _plateController,
          enabled: !vehicleState.isLoading && (widget.allowWithActiveRequest || !vehicleState.hasActiveRequest),
          isLoading: vehicleState.isLoading || vehicleState.isCheckingActiveRequest,
          errorText: vehicleState.error != null && _hasSearched
              ? vehicleState.error
              : null,
          onChanged: (vehicleState.hasActiveRequest && !widget.allowWithActiveRequest) ? null : (value) {
            setState(() {
              _hasSearched = false;
            });
          },
          onSubmitted: null,
        ),

        const SizedBox(height: 16),

        // Bouton de validation
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: (vehicleState.isLoading ||
                       vehicleState.isCheckingActiveRequest ||
                       (vehicleState.hasActiveRequest && !widget.allowWithActiveRequest) ||
                       _plateController.text.replaceAll(RegExp(r'[^A-Z0-9]'), '').length < 7)
                ? null
                : _handleSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_radius),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            child: vehicleState.isLoading || vehicleState.isCheckingActiveRequest
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Valider'),
          ),
        ),

        // ✅ FIX: Affichage du blocage UNIQUEMENT si pas allowWithActiveRequest
        if (vehicleState.hasActiveRequest && !widget.allowWithActiveRequest) ...[
          const SizedBox(height: 12),
          _ActiveRequestWarning(),
        ]
        // Affichage des limitations de tentatives SEULEMENT si pas de demande active
        else if (!vehicleState.hasActiveRequest || widget.allowWithActiveRequest) ...[
          if (vehicleState.isRateLimited) ...[
            const SizedBox(height: 12),
            _RateLimitWarning(
              remainingAttempts: vehicleState.remainingAttempts,
              timeUntilReset: vehicleState.timeUntilReset,
            ),
          ] else if (vehicleState.remainingAttempts < 3) ...[
            const SizedBox(height: 12),
            _RemainingAttemptsInfo(remainingAttempts: vehicleState.remainingAttempts),
          ],
        ],

        // if (vehicleState.vehicleInfo != null) ...[
        //   const SizedBox(height: 12),
        //   _VehicleInfoCard(vehicleInfo: vehicleState.vehicleInfo!),
        // ],
        if (widget.showManualOption && vehicleState.vehicleInfo == null) ...[
          const SizedBox(height: 24),
          const Text(
            'Ou remplir les informations manuellement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: widget.onManualMode,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.white,
                foregroundColor: AppTheme.darkGray,
                elevation: 0,
                side: const BorderSide(color: AppColors.grey200, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_radius),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              child: const Text('Manuel'),
            ),
          ),
        ],
      ],
    );
  }
}

class _RateLimitWarning extends StatelessWidget {
  final int remainingAttempts;
  final int timeUntilReset;

  static const double _radius = 10;

  const _RateLimitWarning({
    required this.remainingAttempts,
    required this.timeUntilReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Limite atteinte. Attendez ${timeUntilReset}min avant de réessayer.',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppTheme.darkGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemainingAttemptsInfo extends StatelessWidget {
  final int remainingAttempts;

  static const double _radius = 10;

  const _RemainingAttemptsInfo({
    required this.remainingAttempts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppTheme.warning,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tentatives restantes: $remainingAttempts/3',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppTheme.darkGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveRequestWarning extends StatelessWidget {
  static const Color _warning = Color(0xFFFF9500); // Orange léger
  static const Color _textDark = Color(0xFF1C1C1E);
  static const double _radius = 12;

  const _ActiveRequestWarning();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.go('/requests');
      },
      borderRadius: BorderRadius.circular(_radius),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: _warning.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.block,
                  color: _warning,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Une demande est déjà en cours',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: _textDark,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: _warning,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Vous ne pouvez pas créer une nouvelle demande tant qu\'une demande est en cours. Consultez vos demandes dans l\'onglet "Mes demandes".',
              style: TextStyle(
                fontSize: 13,
                color: _textDark.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class _VehicleInfoCard extends ConsumerWidget {
//   final dynamic vehicleInfo;
//   static const Color _blue = Color(0xFF1976D2);
//   static const Color _textDark = Color(0xFF1C1C1E);
//   static const double _radius = 16;

//   const _VehicleInfoCard({required this.vehicleInfo});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final details = ref.read(vehicleSearchProvider.notifier).getVehicleDetails();

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.green.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(_radius),
//         border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.check_circle,
//                 color: Colors.green.shade600,
//                 size: 24,
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 'Véhicule identifié',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 16,
//                   color: Colors.green.shade600,
//                 ),
//               ),
//             ],
//           ),
//           if (details.isNotEmpty) ...[
//             const SizedBox(height: 16),
//             ...details.entries.map((entry) => Padding(
//               padding: const EdgeInsets.symmetric(vertical: 4),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     width: 120,
//                     child: Text(
//                       '${entry.key}:',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         color: _textDark,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Text(
//                       entry.value,
//                       style: const TextStyle(
//                         color: _textDark,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )),
//           ],
//         ],
//       ),
//     );
//   }
// }
