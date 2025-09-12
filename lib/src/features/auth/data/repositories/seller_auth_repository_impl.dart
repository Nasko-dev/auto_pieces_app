import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/seller.dart';
import '../../domain/repositories/seller_auth_repository.dart';
import '../datasources/seller_auth_remote_datasource.dart';
import '../datasources/particulier_auth_local_datasource.dart';
import '../models/seller_model.dart';

class SellerAuthRepositoryImpl implements SellerAuthRepository {
  final SellerAuthRemoteDataSource remoteDataSource;
  final ParticulierAuthLocalDataSource particulierLocalDataSource;
  final NetworkInfo networkInfo;

  SellerAuthRepositoryImpl({
    required this.remoteDataSource,
    required this.particulierLocalDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Seller>> registerSeller({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? companyName,
    String? phone,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final seller = await remoteDataSource.registerSeller(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          companyName: companyName,
          phone: phone,
        );
        return Right(seller);
      } on AuthFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure('Erreur serveur: $e'));
      }
    } else {
      return const Left(NetworkFailure('Aucune connexion internet'));
    }
  }

  @override
  Future<Either<Failure, Seller>> loginSeller({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final seller = await remoteDataSource.loginSeller(
          email: email,
          password: password,
        );
        return Right(seller);
      } on AuthFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure('Erreur serveur: $e'));
      }
    } else {
      return const Left(NetworkFailure('Aucune connexion internet'));
    }
  }

  @override
  Future<Either<Failure, void>> logoutSeller() async {
    try {
      print('🏠 [REPOSITORY] Début déconnexion vendeur complète');
      
      // 1. Déconnexion vendeur (Supabase Auth)
      await remoteDataSource.logoutSeller();
      
      // 2. Nettoyer le cache des particuliers pour éviter les conflits
      try {
        await particulierLocalDataSource.clearCache();
        print('🧹 [REPOSITORY] Cache particulier nettoyé');
      } catch (e) {
        print('⚠️ [REPOSITORY] Impossible de nettoyer le cache particulier: $e');
        // Ne pas faire échouer la déconnexion pour ça
      }
      
      print('✅ [REPOSITORY] Déconnexion vendeur complète réussie');
      return const Right(null);
    } catch (e) {
      print('❌ [REPOSITORY] Erreur déconnexion vendeur: $e');
      return Left(ServerFailure('Erreur lors de la déconnexion: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendPasswordResetEmail(email);
        return const Right(null);
      } on AuthFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure('Erreur serveur: $e'));
      }
    } else {
      return const Left(NetworkFailure('Aucune connexion internet'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updatePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
        return const Right(null);
      } on AuthFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure('Erreur serveur: $e'));
      }
    } else {
      return const Left(NetworkFailure('Aucune connexion internet'));
    }
  }

  @override
  Future<Either<Failure, Seller>> getCurrentSeller() async {
    if (await networkInfo.isConnected) {
      try {
        final seller = await remoteDataSource.getCurrentSeller();
        return Right(seller);
      } on AuthFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure('Erreur serveur: $e'));
      }
    } else {
      return const Left(NetworkFailure('Aucune connexion internet'));
    }
  }

  @override
  Future<Either<Failure, Seller>> updateSellerProfile(Seller seller) async {
    if (await networkInfo.isConnected) {
      try {
        final sellerModel = SellerModel.fromEntity(seller);
        final updatedSeller = await remoteDataSource.updateSellerProfile(sellerModel);
        return Right(updatedSeller);
      } on AuthFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure('Erreur serveur: $e'));
      }
    } else {
      return const Left(NetworkFailure('Aucune connexion internet'));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendEmailVerification();
        return const Right(null);
      } on AuthFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure('Erreur serveur: $e'));
      }
    } else {
      return const Left(NetworkFailure('Aucune connexion internet'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmail(String token) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.verifyEmail(token);
        return const Right(null);
      } on AuthFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure('Erreur serveur: $e'));
      }
    } else {
      return const Left(NetworkFailure('Aucune connexion internet'));
    }
  }
}