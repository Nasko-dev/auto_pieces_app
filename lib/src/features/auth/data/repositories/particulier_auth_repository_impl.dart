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
      
      final particulier = await remoteDataSource.signInAnonymously();

      // Mettre en cache
      await localDataSource.cacheParticulier(particulier);
      
      return Right(particulier);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      // L'erreur de cache n'est pas bloquante pour la connexion
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erreur lors de la connexion anonyme: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      
      await remoteDataSource.logout();
      await localDataSource.clearCache();
      
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erreur lors de la déconnexion: $e'));
    }
  }

  @override
  Future<Either<Failure, Particulier>> getCurrentParticulier() async {
    try {
      
      // Essayer d'abord le cache
      final cachedParticulier = await localDataSource.getCachedParticulier();
      if (cachedParticulier != null) {
        return Right(cachedParticulier);
      }

      // Sinon récupérer depuis le serveur
      final particulier = await remoteDataSource.getCurrentParticulier();
      
      // Mettre en cache pour la prochaine fois
      await localDataSource.cacheParticulier(particulier);
      
      return Right(particulier);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      // Essayer quand même de récupérer depuis le serveur
      try {
        final particulier = await remoteDataSource.getCurrentParticulier();
        return Right(particulier);
      } on ServerException catch (serverError) {
        return Left(ServerFailure(serverError.message));
      }
    } catch (e) {
      return Left(ServerFailure('Erreur lors de la récupération de l\'utilisateur: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      
      final isLoggedIn = await remoteDataSource.isLoggedIn();
      
      return Right(isLoggedIn);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, Particulier>> updateParticulier(Particulier particulier) async {
    try {
      
      // Convertir en ParticulierModel pour la datasource
      final particulierModel = ParticulierModel.fromEntity(particulier);
      final updatedParticulier = await remoteDataSource.updateParticulier(particulierModel);
      
      // Mettre en cache la version mise à jour
      await localDataSource.cacheParticulier(updatedParticulier);
      
      return Right(updatedParticulier);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erreur lors de la mise à jour: $e'));
    }
  }
}