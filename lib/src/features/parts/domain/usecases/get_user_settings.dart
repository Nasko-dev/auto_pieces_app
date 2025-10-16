import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_settings.dart';
import '../repositories/user_settings_repository.dart';

class GetUserSettings implements UseCase<UserSettings?, String> {
  final UserSettingsRepository repository;

  GetUserSettings(this.repository);

  @override
  Future<Either<Failure, UserSettings?>> call(String userId) async {
    return await repository.getUserSettings(userId);
  }
}
