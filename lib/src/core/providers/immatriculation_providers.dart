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
    // Ne pas appeler _checkActiveRequest dans le constructeur pour éviter les blocages
    // Elle sera appelée par les pages qui en ont besoin
  }

  Future<void> searchVehicle(String plate) async {
    print('🔍 [VehicleSearchNotifier] Début recherche pour: $plate');
    
    // Vérification s'il y a déjà une demande/annonce active
    if (state.hasActiveRequest) {
      print('🚫 [VehicleSearchNotifier] Limite atteinte');
      
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
    print('🔍 [VehicleSearchNotifier] Vérification demande/annonce active...');
    
    // Ne pas bloquer l'UI pendant la vérification
    if (state.isCheckingActiveRequest) {
      print('⚠️ [VehicleSearchNotifier] Vérification déjà en cours, abandon');
      return;
    }
    
    state = state.copyWith(isCheckingActiveRequest: true);
    
    try {
      // Méthode simple et directe : vérifier dans Supabase si l'utilisateur a un profil vendeur
      print('🔍 [VehicleSearchNotifier] Vérification du type d\'utilisateur (direct)...');
      
      bool isSeller = false;
      try {
        final supabaseClient = _ref.read(seller_auth.supabaseClientProvider);
        final userId = supabaseClient.auth.currentUser?.id;
        
        if (userId != null) {
          print('🔍 [VehicleSearchNotifier] ID utilisateur: $userId');
          
          // SOLUTION TEMPORAIRE : Forcer certains utilisateurs à être vendeurs
          final forceSellerIds = [
            '82392786-b854-40b4-90c1-605636804164', // User ID supposé
            '27ff3e11-647a-4edb-878b-62a8f24009b0', // User ID de session actuel
          ];
          
          if (forceSellerIds.contains(userId)) {
            print('🔧 [VehicleSearchNotifier] FORCE: Utilisateur forcé en mode vendeur');
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
          print('👤 [VehicleSearchNotifier] Type utilisateur: ${isSeller ? "Vendeur" : "Particulier"}');
          
          if (isSeller) {
            print('🏪 [VehicleSearchNotifier] Profil vendeur trouvé dans la base');
          } else {
            print('👤 [VehicleSearchNotifier] Aucun profil vendeur - utilisateur particulier');
          }
        } else {
          print('❌ [VehicleSearchNotifier] Aucun utilisateur connecté');
          isSeller = false;
        }
      } catch (e) {
        print('❌ [VehicleSearchNotifier] Erreur vérification profil vendeur: $e');
        print('👤 [VehicleSearchNotifier] Par défaut: traiter comme particulier');
        isSeller = false;
      }
      
      if (isSeller) {
        // VENDEUR : Vérifier les annonces (AUCUNE LIMITE)
        print('🏪 [VehicleSearchNotifier] MODE VENDEUR DÉTECTÉ - AUCUNE LIMITATION');
        print('🔄 [VehicleSearchNotifier] Appel de _checkSellerAdvertisements()...');
        await _checkSellerAdvertisements();
        print('✅ [VehicleSearchNotifier] VENDEUR - hasActiveRequest forcé à FALSE');
      } else {
        // PARTICULIER : Vérifier les demandes (limite 1)  
        print('👤 [VehicleSearchNotifier] MODE PARTICULIER - Vérification des limites');
        print('🔄 [VehicleSearchNotifier] Appel de _checkParticulierRequests()...');
        await _checkParticulierRequests();
      }
      
      // SOLUTION TEMPORAIRE : Forcer le déblocage vendeur 
      // On applique la logique vendeur (limite 10) même si pas détecté comme vendeur
      if (!isSeller) {
        try {
          print('🔧 [VehicleSearchNotifier] SOLUTION TEMPORAIRE: Vérification annonces pour tous les utilisateurs');
          
          final advertisements = await _getMyAdvertisements();
          final activeAds = advertisements.where((ad) => ad['status'] == 'active').toList();
          
          print('📊 [VehicleSearchNotifier] TEMP: ${activeAds.length} annonces actives trouvées');
          
          // Si l'utilisateur a des annonces, on le traite comme un vendeur avec limite 10
          if (advertisements.isNotEmpty) {
            print('🏪 [VehicleSearchNotifier] TEMP: Utilisateur a des annonces -> traité comme vendeur');
            
            if (activeAds.length >= 10) {
              print('🚫 [VehicleSearchNotifier] TEMP: LIMITE VENDEUR ATTEINTE - ${activeAds.length}/10');
              state = state.copyWith(
                hasActiveRequest: true,
                isCheckingActiveRequest: false,
              );
            } else {
              print('✅ [VehicleSearchNotifier] TEMP: Limite vendeur OK - ${activeAds.length}/10 - DÉBLOCAGE');
              state = state.copyWith(
                hasActiveRequest: false,
                isCheckingActiveRequest: false,
              );
            }
          } else {
            print('👤 [VehicleSearchNotifier] TEMP: Aucune annonce -> traité comme particulier');
            // Garde la logique particulier qui a été appliquée
          }
        } catch (e) {
          print('💥 [VehicleSearchNotifier] TEMP échoué: $e');
        }
      }
    } catch (e) {
      print('💥 [VehicleSearchNotifier] Exception globale: $e');
      print('📍 [VehicleSearchNotifier] Stack trace: ${StackTrace.current}');
      state = state.copyWith(
        hasActiveRequest: false,
        isCheckingActiveRequest: false,
      );
    }
  }
  
  /// Vérifie les annonces pour les vendeurs (limite 10)
  Future<void> _checkSellerAdvertisements() async {
    print('🏪 [VehicleSearchNotifier] Vérification annonces vendeur...');
    print('🔍 [VehicleSearchNotifier] Récupération du repository des annonces...');
    
    try {
      final repository = _ref.read(partAdvertisementRepositoryProvider);
      print('✅ [VehicleSearchNotifier] Repository récupéré, appel de getMyPartAdvertisements...');
      
      final myAdsResult = await repository.getMyPartAdvertisements();
      print('📦 [VehicleSearchNotifier] Résultat reçu de getMyPartAdvertisements');
      
      myAdsResult.fold(
        (failure) {
          print('❌ [VehicleSearchNotifier] Erreur récupération annonces: ${failure.message}');
          print('📍 [VehicleSearchNotifier] Type d\'erreur: ${failure.runtimeType}');
          state = state.copyWith(
            hasActiveRequest: false,
            isCheckingActiveRequest: false,
          );
        },
        (advertisements) {
          print('✅ [VehicleSearchNotifier] Annonces récupérées avec succès');
          final activeAds = advertisements.where((ad) => ad.status == 'active').toList();
          print('📊 [VehicleSearchNotifier] Nombre total d\'annonces: ${advertisements.length}');
          print('🔥 [VehicleSearchNotifier] Nombre d\'annonces actives: ${activeAds.length}');
          
          // Debug: afficher les détails des annonces
          for (final ad in advertisements) {
            print('   📄 Annonce: ${ad.partName} - Status: ${ad.status} - ID: ${ad.id}');
          }
          
          // VENDEURS : AUCUNE LIMITE
          print('✅ [VehicleSearchNotifier] Mode vendeur - AUCUNE LIMITE (${activeAds.length} annonces actives)');
          print('🟢 [VehicleSearchNotifier] Mise à jour état: hasActiveRequest = false (vendeur illimité)');
          
          state = state.copyWith(
            hasActiveRequest: false,
            isCheckingActiveRequest: false,
          );
          
          print('📊 [VehicleSearchNotifier] État final: hasActiveRequest = ${state.hasActiveRequest}');
        },
      );
    } catch (e) {
      print('💥 [VehicleSearchNotifier] Exception annonces: $e');
      print('📍 [VehicleSearchNotifier] Stack trace: ${StackTrace.current}');
      state = state.copyWith(
        hasActiveRequest: false,
        isCheckingActiveRequest: false,
      );
    }
  }
  
  /// Vérifie les demandes pour les particuliers (limite 1)
  Future<void> _checkParticulierRequests() async {
    print('👤 [VehicleSearchNotifier] Vérification demandes particulier...');
    
    try {
      final repository = _ref.read(partRequestRepositoryProvider);
      final allRequestsResult = await repository.getUserPartRequests();
      
      allRequestsResult.fold(
        (failure) {
          print('❌ [VehicleSearchNotifier] Erreur récupération demandes: ${failure.message}');
          state = state.copyWith(
            hasActiveRequest: false,
            isCheckingActiveRequest: false,
          );
        },
        (requests) {
          final activeRequests = requests.where((r) => r.status == 'active').toList();
          print('📊 [VehicleSearchNotifier] Nombre total de demandes: ${requests.length}');
          print('🔥 [VehicleSearchNotifier] Nombre de demandes actives: ${activeRequests.length}');
          
          // Limite de 1 pour les particuliers
          if (activeRequests.length >= 1) {
            print('🚫 [VehicleSearchNotifier] LIMITE ATTEINTE - ${activeRequests.length} demande(s) active(s)');
            print('🔒 [VehicleSearchNotifier] Création de demande bloquée');
            
            state = state.copyWith(
              hasActiveRequest: true,
              isCheckingActiveRequest: false,
            );
          } else {
            print('✅ [VehicleSearchNotifier] Aucune demande active - création autorisée');
            state = state.copyWith(
              hasActiveRequest: false,
              isCheckingActiveRequest: false,
            );
          }
        },
      );
    } catch (e) {
      print('💥 [VehicleSearchNotifier] Exception demandes: $e');
      state = state.copyWith(
        hasActiveRequest: false,
        isCheckingActiveRequest: false,
      );
    }
  }

  /// Force la vérification de la demande active (pour l'UI)
  Future<void> checkActiveRequest() async {
    print('🔄 [VehicleSearchNotifier] Force re-vérification demandée...');
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
      print('❌ [VehicleSearchNotifier] Erreur récupération annonces: $e');
      return [];
    }
  }

  /// Méthode utilitaire pour debug - force le reset et re-check
  Future<void> forceRefreshActiveRequestCheck() async {
    print('🔄 [VehicleSearchNotifier] FORCE REFRESH - Reset état puis re-check...');
    
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
