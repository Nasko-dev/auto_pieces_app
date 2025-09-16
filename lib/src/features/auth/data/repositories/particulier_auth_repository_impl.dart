import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/particulier.dart';
import '../../domain/repositories/particulier_auth_repository.dart';
import '../datasources/particulier_auth_remote_datasource.dart';
import '../datasources/particulier_auth_local_datasource.dart';
import '../models/particulier_model.dart';

class ParticulierAuthRepositoryImpl implements ParticulierAuthRepository {
  final ParticulierAuthRemoteDataSource remoteDataSource;
  final ParticulierAuthLocalDataSource localDataSource;

  ParticulierAuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Particulier>> signInAnonymously() async {
    try {
      print('👤 [Repository] Connexion anonyme automatique');
      
      final particulier = await remoteDataSource.signInAnonymously();

      // Mettre en cache
      await localDataSource.cacheParticulier(particulier);
      
      print('✅ [Repository] Connexion anonyme réussie');
      return Right(particulier);
    } on ServerException catch (e) {
      print('❌ [Repository] Erreur serveur: ${e.message}');
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      print('⚠️ [Repository] Erreur cache (non bloquante): ${e.message}');
      // L'erreur de cache n'est pas bloquante pour la connexion
      return Left(CacheFailure(e.message));
    } catch (e) {
      print('❌ [Repository] Erreur inattendue: $e');
      return Left(ServerFailure('Erreur lors de la connexion anonyme: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      print('🚪 [Repository] Déconnexion particulier');
      
      await remoteDataSource.logout();
      await localDataSource.clearCache();
      
      print('✅ [Repository] Déconnexion réussie');
      return const Right(null);
    } on ServerException catch (e) {
      print('❌ [Repository] Erreur serveur: ${e.message}');
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      print('⚠️ [Repository] Erreur cache: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      print('❌ [Repository] Erreur inattendue: $e');
      return Left(ServerFailure('Erreur lors de la déconnexion: $e'));
    }
  }

  @override
  Future<Either<Failure, Particulier>> getCurrentParticulier() async {
    try {
      print('👤 [Repository] Récupération particulier actuel');
      
      // Essayer d'abord le cache
      final cachedParticulier = await localDataSource.getCachedParticulier();
      if (cachedParticulier != null) {
        print('✅ [Repository] Particulier trouvé en cache');
        return Right(cachedParticulier);
      }

      // Sinon récupérer depuis le serveur
      print('🌐 [Repository] Récupération depuis le serveur');
      final particulier = await remoteDataSource.getCurrentParticulier();
      
      // Mettre en cache pour la prochaine fois
      await localDataSource.cacheParticulier(particulier);
      
      print('✅ [Repository] Particulier récupéré du serveur');
      return Right(particulier);
    } on ServerException catch (e) {
      print('❌ [Repository] Erreur serveur: ${e.message}');
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      print('⚠️ [Repository] Erreur cache: ${e.message}');
      // Essayer quand même de récupérer depuis le serveur
      try {
        final particulier = await remoteDataSource.getCurrentParticulier();
        return Right(particulier);
      } on ServerException catch (serverError) {
        return Left(ServerFailure(serverError.message));
      }
    } catch (e) {
      print('❌ [Repository] Erreur inattendue: $e');
      return Left(ServerFailure('Erreur lors de la récupération de l\'utilisateur: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      print('🔍 [Repository] Vérification connexion');
      
      final isLoggedIn = await remoteDataSource.isLoggedIn();
      
      print('ℹ️ [Repository] Statut connexion: $isLoggedIn');
      return Right(isLoggedIn);
    } catch (e) {
      print('❌ [Repository] Erreur vérification: $e');
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, Particulier>> updateParticulier(Particulier particulier) async {
    try {
      print('💾 [Repository] Mise à jour particulier: ${particulier.id}');
      
      // Convertir en ParticulierModel pour la datasource
      final particulierModel = ParticulierModel.fromEntity(particulier);
      final updatedParticulier = await remoteDataSource.updateParticulier(particulierModel);
      
      // Mettre en cache la version mise à jour
      await localDataSource.cacheParticulier(updatedParticulier);
      
      print('✅ [Repository] Particulier mis à jour avec succès');
      return Right(updatedParticulier);
    } on ServerException catch (e) {
      print('❌ [Repository] Erreur serveur: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('❌ [Repository] Erreur inattendue: $e');
      return Left(ServerFailure('Erreur lors de la mise à jour: $e'));
    }
  }
}