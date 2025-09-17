import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/seller_settings.dart';

abstract class SellerSettingsRepository {
  Future<Either<Failure, SellerSettings?>> getSellerSettings(String sellerId);
  Future<Either<Failure, SellerSettings>> saveSellerSettings(SellerSettings settings);
  Future<Either<Failure, Unit>> deleteSellerSettings(String sellerId);
}