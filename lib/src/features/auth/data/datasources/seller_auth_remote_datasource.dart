import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/seller_model.dart';

abstract class SellerAuthRemoteDataSource {
  Future<SellerModel> registerSeller({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? companyName,
    String? phone,
  });

  Future<SellerModel> loginSeller({
    required String email,
    required String password,
  });

  Future<void> logoutSeller();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<SellerModel> getCurrentSeller();

  Future<SellerModel> updateSellerProfile(SellerModel seller);

  Future<void> sendEmailVerification();

  Future<void> verifyEmail(String token);
}

class SellerAuthRemoteDataSourceImpl implements SellerAuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  SellerAuthRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<SellerModel> registerSeller({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? companyName,
    String? phone,
  }) async {
    try {
      // Validation des données
      if (password.length < 8) {
        throw const AuthFailure(
            'Le mot de passe doit contenir au moins 8 caractères');
      }

      if (!_isValidEmail(email)) {
        throw const AuthFailure('Format d\'email invalide');
      }

      // 1. Créer l'utilisateur dans Supabase Auth
      final authResponse = await _supabaseClient.auth.signUp(
        email: email.toLowerCase().trim(),
        password: password,
        data: {
          'user_type': AppConstants.userTypeSeller,
          'first_name': firstName,
          'last_name': lastName,
          'company_name': companyName,
          'phone': phone,
        },
      );

      if (authResponse.user == null) {
        throw const AuthFailure('Erreur lors de la création du compte');
      }

      final user = authResponse.user!;

      // Créer le profil vendeur dans la table sellers
      final sellerInsertData = {
        'id': user.id,
        'email': user.email!,
        'first_name': firstName,
        'last_name': lastName,
        'company_name': companyName,
        'phone': phone,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabaseClient.from('sellers').insert(sellerInsertData);

      // Créer le SellerModel à partir des données insérées
      final sellerModel = SellerModel(
        id: user.id,
        email: user.email!,
        firstName: firstName,
        lastName: lastName,
        companyName: companyName,
        phone: phone,
        createdAt: DateTime.parse(user.createdAt),
        emailVerifiedAt: user.emailConfirmedAt != null
            ? DateTime.parse(user.emailConfirmedAt!)
            : null,
        isVerified: user.emailConfirmedAt != null,
      );

      return sellerModel;
    } on AuthException catch (e) {
      throw AuthFailure(_mapSupabaseAuthError(e.message));
    } on PostgrestException catch (e) {
      // Gestion des erreurs spécifiques
      if (e.code == '23505') {
        // Duplicate key violation
        if (e.message.contains('sellers_pkey')) {
          throw const AuthFailure(
              'Ce compte existe déjà. Essayez de vous connecter.');
        } else if (e.message.contains('sellers_email_key')) {
          throw const AuthFailure('Un compte avec cet email existe déjà.');
        }
      }

      throw AuthFailure('Erreur de base de données: ${e.message}');
    } catch (e) {
      throw AuthFailure('Erreur inattendue: $e');
    }
  }

  @override
  Future<SellerModel> loginSeller({
    required String email,
    required String password,
  }) async {
    try {
      if (!_isValidEmail(email)) {
        throw const AuthFailure('Format d\'email invalide');
      }

      // 1. Authentification avec Supabase
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );

      if (response.user == null) {
        throw const AuthFailure('Email ou mot de passe incorrect');
      }

      // 2. Récupérer le profil vendeur
      final sellerData = await _supabaseClient
          .from('sellers')
          .select()
          .eq('id', response.user!.id)
          .single();

      final seller = SellerModel.fromJson(sellerData);

      // 3. Vérifier que le compte est actif
      if (!seller.isActive) {
        await _supabaseClient.auth.signOut();
        throw const AuthFailure(
            'Votre compte a été désactivé. Contactez le support.');
      }

      return seller;
    } on AuthException catch (e) {
      throw AuthFailure(_mapSupabaseAuthError(e.message));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const AuthFailure('Compte vendeur introuvable');
      }
      throw AuthFailure('Erreur de base de données: ${e.message}');
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure('Erreur inattendue: $e');
    }
  }

  @override
  Future<void> logoutSeller() async {
    try {
      // Déconnexion Supabase Auth (nettoie la session)
      await _supabaseClient.auth.signOut(scope: SignOutScope.global);
    } catch (e) {
      throw const AuthFailure('Erreur lors de la déconnexion');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (!_isValidEmail(email)) {
        throw const AuthFailure('Format d\'email invalide');
      }

      await _supabaseClient.auth.resetPasswordForEmail(
        email.toLowerCase().trim(),
        redirectTo: '${AppConstants.appScheme}://reset-password',
      );
    } on AuthException catch (e) {
      throw AuthFailure(_mapSupabaseAuthError(e.message));
    } catch (e) {
      throw AuthFailure('Erreur lors de l\'envoi de l\'email: $e');
    }
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (newPassword.length < 8) {
        throw const AuthFailure(
            'Le nouveau mot de passe doit contenir au moins 8 caractères');
      }

      // Vérifier le mot de passe actuel en tentant une re-authentification
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser?.email == null) {
        throw const AuthFailure('Utilisateur non connecté');
      }

      // Re-authentifier pour vérifier le mot de passe actuel
      try {
        await _supabaseClient.auth.signInWithPassword(
          email: currentUser!.email!,
          password: currentPassword,
        );
      } catch (e) {
        throw const AuthFailure('Mot de passe actuel incorrect');
      }

      // Mettre à jour le mot de passe
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw AuthFailure(_mapSupabaseAuthError(e.message));
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure('Erreur lors de la mise à jour du mot de passe: $e');
    }
  }

  @override
  Future<SellerModel> getCurrentSeller() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthFailure('Aucun utilisateur connecté');
      }

      final sellerData = await _supabaseClient
          .from('sellers')
          .select()
          .eq('id', user.id)
          .single();

      final sellerModel = SellerModel.fromJson(sellerData);

      return sellerModel;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const AuthFailure('Profil vendeur introuvable');
      }
      throw AuthFailure('Erreur de base de données: ${e.message}');
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure('Erreur lors de la récupération du profil: $e');
    }
  }

  @override
  Future<SellerModel> updateSellerProfile(SellerModel seller) async {
    try {
      final updatedData = {
        'first_name': seller.firstName,
        'last_name': seller.lastName,
        'company_name': seller.companyName,
        'phone': seller.phone,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabaseClient
          .from('sellers')
          .update(updatedData)
          .eq('id', seller.id);

      return seller.copyWith(updatedAt: DateTime.now()) as SellerModel;
    } on PostgrestException catch (e) {
      throw AuthFailure('Erreur de mise à jour: ${e.message}');
    } catch (e) {
      throw AuthFailure('Erreur lors de la mise à jour du profil: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthFailure('Aucun utilisateur connecté');
      }

      await _supabaseClient.auth.resend(
        type: OtpType.signup,
        email: user.email,
      );
    } on AuthException catch (e) {
      throw AuthFailure(_mapSupabaseAuthError(e.message));
    } catch (e) {
      throw AuthFailure(
          'Erreur lors de l\'envoi de l\'email de vérification: $e');
    }
  }

  @override
  Future<void> verifyEmail(String token) async {
    try {
      await _supabaseClient.auth.verifyOTP(
        type: OtpType.signup,
        token: token,
      );

      // Mettre à jour le statut de vérification dans la table sellers
      final user = _supabaseClient.auth.currentUser;
      if (user != null) {
        await _supabaseClient.from('sellers').update({
          'email_verified_at': DateTime.now().toIso8601String(),
          'is_verified': true,
        }).eq('id', user.id);
      }
    } on AuthException catch (e) {
      throw AuthFailure(_mapSupabaseAuthError(e.message));
    } catch (e) {
      throw AuthFailure('Erreur lors de la vérification de l\'email: $e');
    }
  }

  // Méthodes utilitaires privées
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  String _mapSupabaseAuthError(String error) {
    switch (error.toLowerCase()) {
      case 'invalid login credentials':
      case 'email not confirmed':
        return 'Email ou mot de passe incorrect';
      case 'user already registered':
        return 'Un compte existe déjà avec cet email';
      case 'password should be at least 6 characters':
        return 'Le mot de passe doit contenir au moins 6 caractères';
      case 'signup disabled':
        return 'Les inscriptions sont temporairement désactivées';
      case 'email rate limit exceeded':
        return 'Trop de tentatives. Veuillez patienter avant de réessayer';
      case 'invalid email':
        return 'Format d\'email invalide';
      case 'weak password':
        return 'Le mot de passe est trop faible';
      default:
        return 'Erreur d\'authentification: $error';
    }
  }
}
