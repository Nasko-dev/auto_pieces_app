import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/seller_settings.dart';
import '../../domain/repositories/seller_settings_repository.dart';
import '../datasources/seller_settings_remote_datasource.dart';
import '../models/seller_settings_model.dart';

class SellerSettingsRepositoryImpl implements SellerSettingsRepository {
  final SellerSettingsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SellerSettingsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, SellerSettings?>> getSellerSettings(
      String sellerId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteSettings =
            await remoteDataSource.getSellerSettings(sellerId);
        return Right(remoteSettings?.toEntity());
      } on ServerFailure catch (failure) {
        return Left(failure);
      }
    } else {
      return const Left(ServerFailure('Pas de connexion internet'));
    }
  }

  @override
  Future<Either<Failure, SellerSettings>> saveSellerSettings(
      SellerSettings settings) async {
    if (await networkInfo.isConnected) {
      try {
        final settingsModel = SellerSettingsModel.fromEntity(settings);
        final result = await remoteDataSource.saveSellerSettings(settingsModel);
        return Right(result.toEntity());
      } on ServerFailure catch (failure) {
        return Left(failure);
      }
    } else {
      return const Left(ServerFailure('Pas de connexion internet'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSellerSettings(String sellerId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteSellerSettings(sellerId);
        return const Right(unit);
      } on ServerFailure catch (failure) {
        return Left(failure);
      }
    } else {
      return const Left(ServerFailure('Pas de connexion internet'));
    }
  }
}
