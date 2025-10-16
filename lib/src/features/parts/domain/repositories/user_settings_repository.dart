import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_settings.dart';

abstract class UserSettingsRepository {
  /// Récupère les paramètres utilisateur
  Future<Either<Failure, UserSettings?>> getUserSettings(String userId);

  /// Sauvegarde ou met à jour les paramètres utilisateur
  Future<Either<Failure, UserSettings>> saveUserSettings(UserSettings settings);

  /// Supprime les paramètres utilisateur
  Future<Either<Failure, void>> deleteUserSettings(String userId);
}
