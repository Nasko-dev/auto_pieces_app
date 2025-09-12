import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/immatriculation_service.dart';
import '../services/rate_limiter_service.dart';
import '../../features/parts/domain/entities/vehicle_info.dart';
import '../errors/failures.dart';
import '../constants/app_constants.dart';
import 'particulier_auth_providers.dart';
import 'part_request_providers.dart';

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

final rateLimiterServiceProvider = Provider<RateLimiterService>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return RateLimiterService(sharedPrefs);
});

class VehicleSearchState {
  final bool isLoading;
  final VehicleInfo? vehicleInfo;
  final String? error;
  final String? lastSearchedPlate;
  final int remainingAttempts;
  final int timeUntilReset;
  final bool isRateLimited;
  final bool hasActiveRequest;
  final bool isCheckingActiveRequest;

  const VehicleSearchState({
    this.isLoading = false,
    this.vehicleInfo,
    this.error,
    this.lastSearchedPlate,
    this.remainingAttempts = 3,
    this.timeUntilReset = 0,
    this.isRateLimited = false,
    this.hasActiveRequest = false,
    this.isCheckingActiveRequest = false,
  });

  VehicleSearchState copyWith({
    bool? isLoading,
    VehicleInfo? vehicleInfo,
    String? error,
    String? lastSearchedPlate,
    int? remainingAttempts,
    int? timeUntilReset,
    bool? isRateLimited,
    bool? hasActiveRequest,
    bool? isCheckingActiveRequest,
    bool clearVehicleInfo = false,
    bool clearError = false,
  }) {
    return VehicleSearchState(
      isLoading: isLoading ?? this.isLoading,
      vehicleInfo: clearVehicleInfo ? null : (vehicleInfo ?? this.vehicleInfo),
      error: clearError ? null : (error ?? this.error),
      lastSearchedPlate: lastSearchedPlate ?? this.lastSearchedPlate,
      remainingAttempts: remainingAttempts ?? this.remainingAttempts,
      timeUntilReset: timeUntilReset ?? this.timeUntilReset,
      isRateLimited: isRateLimited ?? this.isRateLimited,
      hasActiveRequest: hasActiveRequest ?? this.hasActiveRequest,
      isCheckingActiveRequest: isCheckingActiveRequest ?? this.isCheckingActiveRequest,
    );
  }
}

class VehicleSearchNotifier extends StateNotifier<VehicleSearchState> {
  final ImmatriculationService _service;
  final RateLimiterService _rateLimiter;
  final Ref _ref;
  final Map<String, VehicleInfo> _cache = {};

  VehicleSearchNotifier(this._service, this._rateLimiter, this._ref) : super(const VehicleSearchState()) {
    _updateRateLimitStatus();
    _checkActiveRequest();
  }

  Future<void> searchVehicle(String plate) async {
    print('🔍 [VehicleSearchNotifier] Début recherche pour: $plate');
    
    // Vérification s'il y a déjà une demande active
    if (state.hasActiveRequest) {
      print('🚫 [VehicleSearchNotifier] Demande active existante');
      state = state.copyWith(
        error: 'Une demande est déjà en cours',
        clearVehicleInfo: true,
      );
      return;
    }
    
    // Mise à jour du status de limitation
    await _updateRateLimitStatus();
    
    // Vérification de la limitation de taux
    final canSearch = await _rateLimiter.canMakeSearch();
    if (!canSearch) {
      final timeUntilReset = await _rateLimiter.getTimeUntilReset();
      print('🚫 [VehicleSearchNotifier] Limite de recherches atteinte');
      state = state.copyWith(
        error: 'Limite de 3 recherches atteinte. Attendez ${timeUntilReset}min avant de réessayer.',
        clearVehicleInfo: true,
        isRateLimited: true,
      );
      return;
    }
    
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

    // Enregistrer la tentative de recherche
    await _rateLimiter.recordAttempt();
    await _updateRateLimitStatus();

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

  /// Met à jour le statut de limitation dans l'état
  Future<void> _updateRateLimitStatus() async {
    final remainingAttempts = await _rateLimiter.getRemainingAttempts();
    final timeUntilReset = await _rateLimiter.getTimeUntilReset();
    final canSearch = await _rateLimiter.canMakeSearch();
    
    state = state.copyWith(
      remainingAttempts: remainingAttempts,
      timeUntilReset: timeUntilReset,
      isRateLimited: !canSearch,
    );
  }

  /// Force la mise à jour du statut de limitation (pour l'UI)
  Future<void> updateRateLimitStatus() async {
    await _updateRateLimitStatus();
  }

  /// Vérifie s'il y a une demande active
  Future<void> _checkActiveRequest() async {
    print('🔍 [VehicleSearchNotifier] Vérification demande active...');
    state = state.copyWith(isCheckingActiveRequest: true);
    
    try {
      final repository = _ref.read(partRequestRepositoryProvider);
      
      // D'abord récupérer toutes les demandes pour compter
      final allRequestsResult = await repository.getUserPartRequests();
      allRequestsResult.fold(
        (failure) {
          print('❌ [VehicleSearchNotifier] Erreur récupération demandes: ${failure.message}');
        },
        (requests) {
          final activeRequests = requests.where((r) => r.status == 'active').toList();
          print('📊 [VehicleSearchNotifier] Nombre total de demandes: ${requests.length}');
          print('🔥 [VehicleSearchNotifier] Nombre de demandes actives: ${activeRequests.length}');
          
          // Afficher les détails des demandes actives
          for (final request in activeRequests) {
            print('  -> ID: ${request.id}, Pièces: ${request.partNames.join(", ")}, Status: ${request.status}');
          }
          
          // Vérification et blocage si >= 1 demande active
          if (activeRequests.length >= 1) {
            print('🚫 [VehicleSearchNotifier] BLOCAGE ACTIVÉ - ${activeRequests.length} demande(s) active(s) détectée(s)');
            print('🔒 [VehicleSearchNotifier] Champ plaque d\'immatriculation sera bloqué');
            
            state = state.copyWith(
              hasActiveRequest: true,
              isCheckingActiveRequest: false,
            );
            return; // Sortir ici, pas besoin de faire la vérification hasActivePartRequest
          } else {
            print('✅ [VehicleSearchNotifier] Aucune demande active - champ plaque autorisé');
            state = state.copyWith(
              hasActiveRequest: false,
              isCheckingActiveRequest: false,
            );
            return; // Sortir ici aussi
          }
        },
      );
    } catch (e) {
      print('💥 [VehicleSearchNotifier] Exception: $e');
      state = state.copyWith(
        hasActiveRequest: false,
        isCheckingActiveRequest: false,
      );
    }
  }

  /// Force la vérification de la demande active (pour l'UI)
  Future<void> checkActiveRequest() async {
    await _checkActiveRequest();
  }
}

final vehicleSearchProvider =
    StateNotifierProvider<VehicleSearchNotifier, VehicleSearchState>((ref) {
      final service = ref.watch(immatriculationServiceProvider);
      final rateLimiter = ref.watch(rateLimiterServiceProvider);
      return VehicleSearchNotifier(service, rateLimiter, ref);
    });

final remainingCreditsProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(immatriculationServiceProvider);
  final result = await service.checkRemainingCredits();

  return result.fold((failure) => 0, (credits) => credits);
});
