import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/user_settings_repository.dart';
import '../datasources/user_settings_remote_datasource.dart';
import '../models/user_settings_model.dart';

class UserSettingsRepositoryImpl implements UserSettingsRepository {
  final UserSettingsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UserSettingsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserSettings?>> getUserSettings(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final settingsModel = await remoteDataSource.getUserSettings(userId);
        return Right(settingsModel?.toEntity());
      } on ServerFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure('Erreur serveur: $e'));
      }
    } else {
      return const Left(NetworkFailure('Aucune connexion internet'));
    }
  }

  @override
  Future<Either<Failure, UserSettings>> saveUserSettings(
      UserSettings settings) async {
    if (await networkInfo.isConnected) {
      try {
        final settingsModel = UserSettingsModel.fromEntity(settings);
        final savedModel =
            await remoteDataSource.saveUserSettings(settingsModel);
        return Right(savedModel.toEntity());
      } on ServerFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure('Erreur serveur: $e'));
      }
    } else {
      return const Left(NetworkFailure('Aucune connexion internet'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserSettings(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteUserSettings(userId);
        return const Right(null);
      } on ServerFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure('Erreur serveur: $e'));
      }
    } else {
      return const Left(NetworkFailure('Aucune connexion internet'));
    }
  }
}
