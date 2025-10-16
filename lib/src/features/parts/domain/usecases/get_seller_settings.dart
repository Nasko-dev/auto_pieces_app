import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller_settings.dart';
import '../repositories/seller_settings_repository.dart';

class GetSellerSettings implements UseCase<SellerSettings?, String> {
  final SellerSettingsRepository repository;

  GetSellerSettings(this.repository);

  @override
  Future<Either<Failure, SellerSettings?>> call(String sellerId) async {
    return await repository.getSellerSettings(sellerId);
  }
}
