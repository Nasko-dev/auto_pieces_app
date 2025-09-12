import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/immatriculation_providers.dart';
import 'french_license_plate.dart';

class LicensePlateInput extends ConsumerStatefulWidget {
  final Function(String plate)? onPlateValidated;
  final Function()? onManualMode;
  final bool showManualOption;
  final bool autoSearch;
  final String? initialPlate;

  const LicensePlateInput({
    super.key,
    this.onPlateValidated,
    this.onManualMode,
    this.showManualOption = true,
    this.autoSearch = true,
    this.initialPlate,
  });

  @override
  ConsumerState<LicensePlateInput> createState() => _LicensePlateInputState();
}

class _LicensePlateInputState extends ConsumerState<LicensePlateInput> {
  static const Color _blue = Color(0xFF1976D2);
  static const Color _textDark = Color(0xFF1C1C1E);
  static const Color _textGray = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const double _radius = 16;

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

    print('🔎 [LicensePlateInput] Recherche déclenchée pour: $plate');

    setState(() {
      _hasSearched = true;
    });

    await ref.read(vehicleSearchProvider.notifier).searchVehicle(plate);

    final state = ref.read(vehicleSearchProvider);
    print('📊 [LicensePlateInput] État après recherche:');
    print('   - Loading: ${state.isLoading}');
    print('   - Error: ${state.error}');
    print('   - VehicleInfo: ${state.vehicleInfo != null}');

    if (state.vehicleInfo != null) {
      print('✅ [LicensePlateInput] Véhicule trouvé, appel du callback');
      widget.onPlateValidated?.call(plate);
    } else if (state.error != null) {
      print('❌ [LicensePlateInput] Erreur: ${state.error}');
    }
  }


  @override
  Widget build(BuildContext context) {
    final vehicleState = ref.watch(vehicleSearchProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Merci de renseigner votre plaque\nd\'immatriculation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 12),

        FrenchLicensePlate(
          controller: _plateController,
          enabled: !vehicleState.isLoading,
          isLoading: vehicleState.isLoading,
          errorText: vehicleState.error != null && _hasSearched
              ? vehicleState.error
              : null,
          onChanged: (value) {
            setState(() {
              _hasSearched = false;
            });

            if (widget.autoSearch &&
                value.replaceAll(RegExp(r'[^A-Z0-9]'), '').length >= 7) {
              _handleSearch();
            }
          },
          onSubmitted: (_) => _handleSearch(),
        ),


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
              color: _textGray,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: widget.onManualMode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _textDark,
                elevation: 0,
                side: const BorderSide(color: _border, width: 1),
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
//         color: Colors.green.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(_radius),
//         border: Border.all(color: Colors.green.withOpacity(0.3)),
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