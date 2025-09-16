import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/session_service.dart';
import '../../domain/entities/particulier.dart';
import '../../domain/usecases/particulier_anonymous_auth.dart';
import '../../domain/usecases/particulier_logout.dart';
import '../../domain/usecases/get_current_particulier.dart';

part 'particulier_auth_controller.freezed.dart';

@freezed
class ParticulierAuthState with _$ParticulierAuthState {
  const factory ParticulierAuthState.initial() = _Initial;
  const factory ParticulierAuthState.loading() = _Loading;
  const factory ParticulierAuthState.anonymousAuthenticated(Particulier particulier) = _AnonymousAuthenticated;
  const factory ParticulierAuthState.error(String message) = _Error;
}

class ParticulierAuthController extends StateNotifier<ParticulierAuthState> {
  final ParticulierAnonymousAuth _particulierAnonymousAuth;
  final ParticulierLogout _particulierLogout;
  final GetCurrentParticulier _getCurrentParticulier;

  ParticulierAuthController({
    required ParticulierAnonymousAuth particulierAnonymousAuth,
    required ParticulierLogout particulierLogout,
    required GetCurrentParticulier getCurrentParticulier,
  })  : _particulierAnonymousAuth = particulierAnonymousAuth,
        _particulierLogout = particulierLogout,
        _getCurrentParticulier = getCurrentParticulier,
        super(const ParticulierAuthState.initial());

  // Connexion anonyme automatique
  Future<void> signInAnonymously() async {
    state = const ParticulierAuthState.loading();

    final result = await _particulierAnonymousAuth(NoParams());

    result.fold(
      (failure) {
        state = ParticulierAuthState.error(_mapFailureToMessage(failure));
      },
      (particulier) {
        state = ParticulierAuthState.anonymousAuthenticated(particulier);
      },
    );
  }

  // Déconnexion
  Future<void> logout() async {
    state = const ParticulierAuthState.loading();

    final result = await _particulierLogout(NoParams());

    result.fold(
      (failure) {
        state = ParticulierAuthState.error(_mapFailureToMessage(failure));
      },
      (_) {
        state = const ParticulierAuthState.initial();
      },
    );
  }

  // Récupérer le particulier actuel
  Future<void> getCurrentParticulier() async {
    state = const ParticulierAuthState.loading();

    final result = await _getCurrentParticulier(NoParams());

    result.fold(
      (failure) {
        state = const ParticulierAuthState.initial();
      },
      (particulier) {
        state = ParticulierAuthState.anonymousAuthenticated(particulier);
      },
    );
  }

  // Vérifier l'état d'authentification au démarrage
  Future<void> checkAuthStatus() async {
    try {
      final result = await _getCurrentParticulier(NoParams());
      result.fold(
        (failure) {
          // Ne pas faire de connexion automatique, juste mettre l'état à initial
          state = const ParticulierAuthState.initial();
        },
        (particulier) {
          state = ParticulierAuthState.anonymousAuthenticated(particulier);
        },
      );
    } catch (e) {
      // En cas d'erreur, mettre l'état à initial au lieu de faire une connexion automatique
      state = const ParticulierAuthState.initial();
    }
  }

  // Reset l'état à initial
  void resetState() {
    state = const ParticulierAuthState.initial();
  }


  // Utilitaire pour mapper les erreurs
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      case NetworkFailure:
        return (failure as NetworkFailure).message;
      case AuthFailure:
        return (failure as AuthFailure).message;
      case ValidationFailure:
        return (failure as ValidationFailure).message;
      case CacheFailure:
        return (failure as CacheFailure).message;
      default:
        return 'Une erreur inattendue s\'est produite';
    }
  }
}

// Extension pour faciliter l'utilisation
extension ParticulierAuthStateX on ParticulierAuthState {
  bool get isLoading => this is _Loading;
  bool get isAuthenticated => this is _AnonymousAuthenticated;
  bool get isError => this is _Error;
  bool get isInitial => this is _Initial;
  
  Particulier? get particulier => mapOrNull(
    anonymousAuthenticated: (state) => state.particulier,
  );
  
  String? get errorMessage => mapOrNull(
    error: (state) => state.message,
  );
}