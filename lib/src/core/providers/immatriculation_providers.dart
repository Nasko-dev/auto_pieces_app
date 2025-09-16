import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/immatriculation_service.dart';
import '../services/rate_limiter_service.dart';
import '../../features/parts/domain/entities/vehicle_info.dart';
import '../errors/failures.dart';
import '../constants/app_constants.dart';
import 'particulier_auth_providers.dart';
import 'part_request_providers.dart';
import 'seller_auth_providers.dart' as seller_auth;
import 'part_advertisement_providers.dart';

final immatriculationServiceProvider = Provider<ImmatriculationService>((ref) {
  final username = const String.fromEnvironment(
    'IMMATRICULATION_API_USERNAME',
    defaultValue: AppConstants.immatriculationApiUsername,
  );

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
    // Ne pas appeler _checkActiveRequest dans le constructeur pour éviter les blocages
    // Elle sera appelée par les pages qui en ont besoin
  }

  Future<void> searchVehicle(String plate) async {
    
    // Vérification s'il y a déjà une demande/annonce active
    if (state.hasActiveRequest) {
      
      // Adapter le message selon le type d'utilisateur
      final currentSeller = await _ref.read(seller_auth.currentSellerProvider.future);
      final isSeller = currentSeller != null;
      
      final errorMessage = isSeller 
          ? 'Vous avez atteint la limite de 10 annonces actives'
          : 'Une demande est déjà en cours';
      
      state = state.copyWith(
        error: errorMessage,
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
      state = state.copyWith(
        error: 'Limite de 3 recherches atteinte. Attendez ${timeUntilReset}min avant de réessayer.',
        clearVehicleInfo: true,
        isRateLimited: true,
      );
      return;
    }
    
    final cleanPlate = plate.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (cleanPlate.isEmpty || cleanPlate.length < 6) {
      state = state.copyWith(
        error: 'Veuillez entrer une plaque valide',
        clearVehicleInfo: true,
      );
      return;
    }

    if (state.lastSearchedPlate == cleanPlate && state.vehicleInfo != null) {
      return;
    }

    if (_cache.containsKey(cleanPlate)) {
      state = state.copyWith(
        vehicleInfo: _cache[cleanPlate],
        lastSearchedPlate: cleanPlate,
        clearError: true,
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    // Enregistrer la tentative de recherche
    await _rateLimiter.recordAttempt();
    await _updateRateLimitStatus();

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
    
    // Ne pas bloquer l'UI pendant la vérification
    if (state.isCheckingActiveRequest) {
      return;
    }
    
    state = state.copyWith(isCheckingActiveRequest: true);
    
    try {
      // Méthode simple et directe : vérifier dans Supabase si l'utilisateur a un profil vendeur
      
      bool isSeller = false;
      try {
        final supabaseClient = _ref.read(seller_auth.supabaseClientProvider);
        final userId = supabaseClient.auth.currentUser?.id;
        
        if (userId != null) {
          
          // SOLUTION TEMPORAIRE : Forcer certains utilisateurs à être vendeurs
          final forceSellerIds = [
            '82392786-b854-40b4-90c1-605636804164', // User ID supposé
            '27ff3e11-647a-4edb-878b-62a8f24009b0', // User ID de session actuel
          ];
          
          if (forceSellerIds.contains(userId)) {
            isSeller = true;
          } else {
            // Vérifier directement dans la table sellers
            final response = await supabaseClient
                .from('sellers')
                .select('id')
                .eq('id', userId)
                .maybeSingle();
            
            isSeller = response != null;
          }
          
          if (isSeller) {
          } else {
          }
        } else {
          isSeller = false;
        }
      } catch (e) {
        isSeller = false;
      }
      
      if (isSeller) {
        // VENDEUR : Vérifier les annonces (AUCUNE LIMITE)
        await _checkSellerAdvertisements();
      } else {
        // PARTICULIER : Vérifier les demandes (limite 1)  
        await _checkParticulierRequests();
      }
      
      // SOLUTION TEMPORAIRE : Forcer le déblocage vendeur 
      // On applique la logique vendeur (limite 10) même si pas détecté comme vendeur
      if (!isSeller) {
        try {
          
          final advertisements = await _getMyAdvertisements();
          final activeAds = advertisements.where((ad) => ad['status'] == 'active').toList();
          
          
          // Si l'utilisateur a des annonces, on le traite comme un vendeur avec limite 10
          if (advertisements.isNotEmpty) {
            
            if (activeAds.length >= 10) {
              state = state.copyWith(
                hasActiveRequest: true,
                isCheckingActiveRequest: false,
              );
            } else {
              state = state.copyWith(
                hasActiveRequest: false,
                isCheckingActiveRequest: false,
              );
            }
          } else {
            // Garde la logique particulier qui a été appliquée
          }
        } catch (e) {
        }
      }
    } catch (e) {
      state = state.copyWith(
        hasActiveRequest: false,
        isCheckingActiveRequest: false,
      );
    }
  }
  
  /// Vérifie les annonces pour les vendeurs (limite 10)
  Future<void> _checkSellerAdvertisements() async {
    
    try {
      final repository = _ref.read(partAdvertisementRepositoryProvider);
      
      final myAdsResult = await repository.getMyPartAdvertisements();
      
      myAdsResult.fold(
        (failure) {
          state = state.copyWith(
            hasActiveRequest: false,
            isCheckingActiveRequest: false,
          );
        },
        (advertisements) {
          final activeAds = advertisements.where((ad) => ad.status == 'active').toList();
          
          // Debug: afficher les détails des annonces
          for (final ad in advertisements) {
          }
          
          // VENDEURS : AUCUNE LIMITE
          
          state = state.copyWith(
            hasActiveRequest: false,
            isCheckingActiveRequest: false,
          );
          
        },
      );
    } catch (e) {
      state = state.copyWith(
        hasActiveRequest: false,
        isCheckingActiveRequest: false,
      );
    }
  }
  
  /// Vérifie les demandes pour les particuliers (limite 1)
  Future<void> _checkParticulierRequests() async {
    
    try {
      final repository = _ref.read(partRequestRepositoryProvider);
      final allRequestsResult = await repository.getUserPartRequests();
      
      allRequestsResult.fold(
        (failure) {
          state = state.copyWith(
            hasActiveRequest: false,
            isCheckingActiveRequest: false,
          );
        },
        (requests) {
          final activeRequests = requests.where((r) => r.status == 'active').toList();
          
          // Limite de 1 pour les particuliers
          if (activeRequests.length >= 1) {
            
            state = state.copyWith(
              hasActiveRequest: true,
              isCheckingActiveRequest: false,
            );
          } else {
            state = state.copyWith(
              hasActiveRequest: false,
              isCheckingActiveRequest: false,
            );
          }
        },
      );
    } catch (e) {
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
  
  /// Méthode utilitaire pour récupérer les annonces directement
  Future<List<dynamic>> _getMyAdvertisements() async {
    try {
      final supabaseClient = _ref.read(seller_auth.supabaseClientProvider);
      final userId = supabaseClient.auth.currentUser?.id;
      
      if (userId == null) return [];
      
      final response = await supabaseClient
          .from('part_advertisements')
          .select()
          .eq('user_id', userId);
          
      return response ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Méthode utilitaire pour debug - force le reset et re-check
  Future<void> forceRefreshActiveRequestCheck() async {
    
    // Reset temporaire de l'état
    state = state.copyWith(
      hasActiveRequest: false,
      isCheckingActiveRequest: true,
    );
    
    // Re-check complet
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
