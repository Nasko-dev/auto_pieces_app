import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller_settings.dart';
import '../repositories/seller_settings_repository.dart';

class SaveSellerSettings implements UseCase<SellerSettings, SellerSettings> {
  final SellerSettingsRepository repository;

  SaveSellerSettings(this.repository);

  @override
  Future<Either<Failure, SellerSettings>> call(SellerSettings settings) async {
    return await repository.saveSellerSettings(settings);
  }
}