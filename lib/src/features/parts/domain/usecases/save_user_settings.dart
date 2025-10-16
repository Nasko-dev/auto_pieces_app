import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_settings.dart';
import '../repositories/user_settings_repository.dart';

class SaveUserSettings implements UseCase<UserSettings, UserSettings> {
  final UserSettingsRepository repository;

  SaveUserSettings(this.repository);

  @override
  Future<Either<Failure, UserSettings>> call(UserSettings settings) async {
    return await repository.saveUserSettings(settings);
  }
}
