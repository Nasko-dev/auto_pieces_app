import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/part_advertisement.dart';
import '../../domain/repositories/part_advertisement_repository.dart';
import '../datasources/part_advertisement_remote_datasource.dart';
import '../models/part_advertisement_model.dart';

class PartAdvertisementRepositoryImpl implements PartAdvertisementRepository {
  final PartAdvertisementRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PartAdvertisementRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PartAdvertisement>> createPartAdvertisement(
    CreatePartAdvertisementParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      final model = await remoteDataSource.createPartAdvertisement(params);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erreur inconnue: $e'));
    }
  }

  @override
  Future<Either<Failure, PartAdvertisement>> getPartAdvertisementById(String id) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      final model = await remoteDataSource.getPartAdvertisementById(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erreur inconnue: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PartAdvertisement>>> getMyPartAdvertisements({
    String? particulierId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      final models = await remoteDataSource.getMyPartAdvertisements(
        particulierId: particulierId,
      );
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erreur inconnue: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PartAdvertisement>>> searchPartAdvertisements(
    SearchPartAdvertisementsParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      final models = await remoteDataSource.searchPartAdvertisements(params);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erreur inconnue: $e'));
    }
  }

  @override
  Future<Either<Failure, PartAdvertisement>> updatePartAdvertisement(
    String id,
    Map<String, dynamic> updates,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      final model = await remoteDataSource.updatePartAdvertisement(id, updates);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erreur inconnue: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePartAdvertisement(String id) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      await remoteDataSource.deletePartAdvertisement(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erreur inconnue: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSold(String id) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      await remoteDataSource.markAsSold(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erreur inconnue: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementViewCount(String id) async {
    if (!await networkInfo.isConnected) {
      return const Right(null); // Pas critique, on continue sans erreur
    }

    try {
      await remoteDataSource.incrementViewCount(id);
      return const Right(null);
    } catch (e) {
      // Pas critique, on continue sans erreur
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> incrementContactCount(String id) async {
    if (!await networkInfo.isConnected) {
      return const Right(null); // Pas critique, on continue sans erreur
    }

    try {
      await remoteDataSource.incrementContactCount(id);
      return const Right(null);
    } catch (e) {
      // Pas critique, on continue sans erreur
      return const Right(null);
    }
  }
}