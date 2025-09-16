import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/providers/seller_auth_providers.dart';
import '../../domain/entities/seller.dart';
import '../../domain/usecases/seller_register.dart';
import '../../domain/usecases/seller_login.dart';
import '../../domain/usecases/seller_forgot_password.dart';
import '../../domain/usecases/seller_logout.dart';
import '../../domain/usecases/get_current_seller.dart';

part 'seller_auth_controller.freezed.dart';

@freezed
class SellerAuthState with _$SellerAuthState {
  const factory SellerAuthState.initial() = _Initial;
  const factory SellerAuthState.loading() = _Loading;
  const factory SellerAuthState.authenticated(Seller seller) = _Authenticated;
  const factory SellerAuthState.unauthenticated() = _Unauthenticated;
  const factory SellerAuthState.error(String message) = _Error;
}

class SellerAuthController extends StateNotifier<SellerAuthState> {
  final SellerRegister _sellerRegister;
  final SellerLogin _sellerLogin;
  final SellerForgotPassword _sellerForgotPassword;
  final SellerLogout _sellerLogout;
  final GetCurrentSeller _getCurrentSeller;

  SellerAuthController({
    required SellerRegister sellerRegister,
    required SellerLogin sellerLogin,
    required SellerForgotPassword sellerForgotPassword,
    required SellerLogout sellerLogout,
    required GetCurrentSeller getCurrentSeller,
  })  : _sellerRegister = sellerRegister,
        _sellerLogin = sellerLogin,
        _sellerForgotPassword = sellerForgotPassword,
        _sellerLogout = sellerLogout,
        _getCurrentSeller = getCurrentSeller,
        super(const SellerAuthState.initial());

  // Inscription vendeur
  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
    String? firstName,
    String? lastName,
    String? companyName,
    String? phone,
  }) async {
    
    state = const SellerAuthState.loading();

    final params = SellerRegisterParams(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      firstName: firstName,
      lastName: lastName,
      companyName: companyName,
      phone: phone,
    );

    final result = await _sellerRegister(params);

    result.fold(
      (failure) {
        state = SellerAuthState.error(_mapFailureToMessage(failure));
      },
      (seller) {
        state = SellerAuthState.authenticated(seller);
      },
    );
  }

  // Connexion vendeur
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const SellerAuthState.loading();

    final params = SellerLoginParams(
      email: email,
      password: password,
    );

    final result = await _sellerLogin(params);

    result.fold(
      (failure) => state = SellerAuthState.error(_mapFailureToMessage(failure)),
      (seller) => state = SellerAuthState.authenticated(seller),
    );
  }

  // Mot de passe oublié
  Future<void> forgotPassword(String email) async {
    state = const SellerAuthState.loading();

    final params = SellerForgotPasswordParams(email: email);
    final result = await _sellerForgotPassword(params);

    result.fold(
      (failure) => state = SellerAuthState.error(_mapFailureToMessage(failure)),
      (_) {
        // Retourner à l'état non authentifié avec un message de succès
        state = const SellerAuthState.unauthenticated();
        // Note: Dans une vraie app, on pourrait avoir un état de succès séparé
      },
    );
  }

  // Déconnexion
  Future<void> logout() async {
    state = const SellerAuthState.loading();

    final result = await _sellerLogout(NoParams());

    result.fold(
      (failure) => state = SellerAuthState.error(_mapFailureToMessage(failure)),
      (_) => state = const SellerAuthState.unauthenticated(),
    );
  }

  // Récupérer le vendeur actuel
  Future<void> getCurrentSeller() async {
    state = const SellerAuthState.loading();

    final result = await _getCurrentSeller(NoParams());

    result.fold(
      (failure) => state = const SellerAuthState.unauthenticated(),
      (seller) => state = SellerAuthState.authenticated(seller),
    );
  }

  // Vérifier l'état d'authentification au démarrage
  Future<void> checkAuthStatus() async {
    try {
      final result = await _getCurrentSeller(NoParams());
      result.fold(
        (failure) => state = const SellerAuthState.unauthenticated(),
        (seller) => state = SellerAuthState.authenticated(seller),
      );
    } catch (e) {
      state = const SellerAuthState.unauthenticated();
    }
  }

  // Reset l'état à initial
  void resetState() {
    state = const SellerAuthState.initial();
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

// Providers
final sellerAuthControllerProvider = StateNotifierProvider<SellerAuthController, SellerAuthState>((ref) {
  final sellerRegister = ref.watch(sellerRegisterProvider);
  final sellerLogin = ref.watch(sellerLoginProvider);
  final sellerForgotPassword = ref.watch(sellerForgotPasswordProvider);
  final sellerLogout = ref.watch(sellerLogoutProvider);
  final getCurrentSeller = ref.watch(getCurrentSellerProvider);

  return SellerAuthController(
    sellerRegister: sellerRegister,
    sellerLogin: sellerLogin,
    sellerForgotPassword: sellerForgotPassword,
    sellerLogout: sellerLogout,
    getCurrentSeller: getCurrentSeller,
  );
});

// Use case providers
final sellerRegisterProvider = Provider<SellerRegister>((ref) {
  final repository = ref.watch(sellerAuthRepositoryProvider);
  return SellerRegister(repository);
});

final sellerLoginProvider = Provider<SellerLogin>((ref) {
  final repository = ref.watch(sellerAuthRepositoryProvider);
  return SellerLogin(repository);
});

final sellerForgotPasswordProvider = Provider<SellerForgotPassword>((ref) {
  final repository = ref.watch(sellerAuthRepositoryProvider);
  return SellerForgotPassword(repository);
});

final sellerLogoutProvider = Provider<SellerLogout>((ref) {
  final repository = ref.watch(sellerAuthRepositoryProvider);
  return SellerLogout(repository);
});

final getCurrentSellerProvider = Provider<GetCurrentSeller>((ref) {
  final repository = ref.watch(sellerAuthRepositoryProvider);
  return GetCurrentSeller(repository);
});


// Extension pour faciliter l'utilisation
extension SellerAuthStateX on SellerAuthState {
  bool get isLoading => this is _Loading;
  bool get isAuthenticated => this is _Authenticated;
  bool get isError => this is _Error;
  bool get isUnauthenticated => this is _Unauthenticated;
  
  Seller? get seller => mapOrNull(
    authenticated: (state) => state.seller,
  );
  
  String? get errorMessage => mapOrNull(
    error: (state) => state.message,
  );
}