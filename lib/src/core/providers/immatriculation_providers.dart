import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/immatriculation_service.dart';
import '../../features/parts/domain/entities/vehicle_info.dart';
import '../errors/failures.dart';
import '../constants/app_constants.dart';

final immatriculationServiceProvider = Provider<ImmatriculationService>((ref) {
  final username = const String.fromEnvironment(
    'IMMATRICULATION_API_USERNAME',
    defaultValue: AppConstants.immatriculationApiUsername,
  );

  print('🔑 [ImmatriculationProvider] Initialisation avec username: $username');
  print(
    '⚠️ [ImmatriculationProvider] Note: Si username = "Moïse134", vous devez le configurer dans app_constants.dart',
  );

  return ImmatriculationService(apiUsername: username);
});

class VehicleSearchState {
  final bool isLoading;
  final VehicleInfo? vehicleInfo;
  final String? error;
  final String? lastSearchedPlate;

  const VehicleSearchState({
    this.isLoading = false,
    this.vehicleInfo,
    this.error,
    this.lastSearchedPlate,
  });

  VehicleSearchState copyWith({
    bool? isLoading,
    VehicleInfo? vehicleInfo,
    String? error,
    String? lastSearchedPlate,
    bool clearVehicleInfo = false,
    bool clearError = false,
  }) {
    return VehicleSearchState(
      isLoading: isLoading ?? this.isLoading,
      vehicleInfo: clearVehicleInfo ? null : (vehicleInfo ?? this.vehicleInfo),
      error: clearError ? null : (error ?? this.error),
      lastSearchedPlate: lastSearchedPlate ?? this.lastSearchedPlate,
    );
  }
}

class VehicleSearchNotifier extends StateNotifier<VehicleSearchState> {
  final ImmatriculationService _service;
  final Map<String, VehicleInfo> _cache = {};

  VehicleSearchNotifier(this._service) : super(const VehicleSearchState());

  Future<void> searchVehicle(String plate) async {
    print('🔍 [VehicleSearchNotifier] Début recherche pour: $plate');
    final cleanPlate = plate.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    print('🧹 [VehicleSearchNotifier] Plaque nettoyée: $cleanPlate');

    if (cleanPlate.isEmpty || cleanPlate.length < 6) {
      print('⚠️ [VehicleSearchNotifier] Plaque trop courte ou vide');
      state = state.copyWith(
        error: 'Veuillez entrer une plaque valide',
        clearVehicleInfo: true,
      );
      return;
    }

    if (state.lastSearchedPlate == cleanPlate && state.vehicleInfo != null) {
      print('💾 [VehicleSearchNotifier] Plaque déjà recherchée et en mémoire');
      return;
    }

    if (_cache.containsKey(cleanPlate)) {
      print('🎯 [VehicleSearchNotifier] Trouvé dans le cache');
      state = state.copyWith(
        vehicleInfo: _cache[cleanPlate],
        lastSearchedPlate: cleanPlate,
        clearError: true,
      );
      return;
    }

    print('🔄 [VehicleSearchNotifier] Début du chargement...');
    state = state.copyWith(isLoading: true, clearError: true);

    print('📡 [VehicleSearchNotifier] Appel du service API...');
    final result = await _service.getVehicleInfoFromPlate(cleanPlate);

    result.fold(
      (failure) {
        print(
          '❌ [VehicleSearchNotifier] Échec: ${failure.runtimeType} - ${failure.message}',
        );
        String errorMessage = 'Erreur lors de la recherche';
        if (failure is ValidationFailure) {
          errorMessage = failure.message;
        } else if (failure is NetworkFailure) {
          errorMessage = 'Problème de connexion réseau';
        } else if (failure is ServerFailure) {
          errorMessage = 'Véhicule non trouvé ou service indisponible';
        }

        print(
          '📝 [VehicleSearchNotifier] Message d\'erreur affiché: $errorMessage',
        );
        state = state.copyWith(
          isLoading: false,
          error: errorMessage,
          clearVehicleInfo: true,
        );
      },
      (vehicleInfo) {
        print('✅ [VehicleSearchNotifier] Succès! Véhicule trouvé:');
        print('   - Marque: ${vehicleInfo.make}');
        print('   - Modèle: ${vehicleInfo.model}');
        print('   - Année: ${vehicleInfo.year}');
        print('   - Motorisation: ${vehicleInfo.engineSize}');

        _cache[cleanPlate] = vehicleInfo;

        state = state.copyWith(
          isLoading: false,
          vehicleInfo: vehicleInfo,
          lastSearchedPlate: cleanPlate,
          clearError: true,
        );
      },
    );
  }

  void clearSearch() {
    state = const VehicleSearchState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String getVehicleDescription() {
    final info = state.vehicleInfo;
    if (info == null) return '';

    final parts = <String>[];
    if (info.make != null) parts.add(info.make!);
    if (info.model != null) parts.add(info.model!);
    if (info.year != null) parts.add(info.year.toString());
    if (info.engineSize != null) parts.add(info.engineSize!);
    if (info.fuelType != null) parts.add(info.fuelType!);

    return parts.join(' - ');
  }

  Map<String, String> getVehicleDetails() {
    final info = state.vehicleInfo;
    if (info == null) return {};

    return {
      if (info.make != null) 'Marque': info.make!,
      if (info.model != null) 'Modèle': info.model!,
      if (info.year != null) 'Année': info.year.toString(),
      if (info.engineSize != null) 'Motorisation': info.engineSize!,
      if (info.fuelType != null) 'Carburant': info.fuelType!,
      if (info.bodyStyle != null) 'Carrosserie': info.bodyStyle!,
      if (info.transmission != null) 'Transmission': info.transmission!,
      if (info.numberOfDoors != null) 'Portes': info.numberOfDoors.toString(),
      if (info.color != null) 'Couleur': info.color!,
    };
  }
}

final vehicleSearchProvider =
    StateNotifierProvider<VehicleSearchNotifier, VehicleSearchState>((ref) {
      final service = ref.watch(immatriculationServiceProvider);
      return VehicleSearchNotifier(service);
    });

final remainingCreditsProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(immatriculationServiceProvider);
  final result = await service.checkRemainingCredits();

  return result.fold((failure) => 0, (credits) => credits);
});
