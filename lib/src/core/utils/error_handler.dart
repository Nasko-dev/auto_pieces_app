import 'package:dartz/dartz.dart';
import '../errors/failures.dart';
import '../errors/exceptions.dart';
import 'logger.dart';

/// Classe utilitaire pour gérer les erreurs de manière centralisée
class ErrorHandler {
  /// Exécute une opération asynchrone et retourne Either
  static Future<Either<Failure, T>> handleAsync<T>(
    Future<T> Function() operation, {
    required bool checkNetwork,
    Future<bool> Function()? networkCheck,
    String? context,
  }) async {
    try {
      // Vérifier la connexion réseau si nécessaire
      if (checkNetwork && networkCheck != null) {
        final isConnected = await networkCheck();
        if (!isConnected) {
          Logger.warning('${context ?? 'Operation'}: Pas de connexion internet');
          return const Left(NetworkFailure('No internet connection'));
        }
      }

      // Exécuter l'opération
      final result = await operation();
      return Right(result);

    } on UnauthorizedException {
      Logger.error('${context ?? 'Operation'}: Utilisateur non authentifié');
      return const Left(AuthFailure('User not authenticated'));
    } on ServerException catch (e) {
      Logger.error('${context ?? 'Operation'}: Erreur serveur: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      Logger.error('${context ?? 'Operation'}: Erreur inattendue: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Exécute une opération sans retour et gère les erreurs
  static Future<Either<Failure, void>> handleVoidAsync(
    Future<void> Function() operation, {
    required bool checkNetwork,
    Future<bool> Function()? networkCheck,
    String? context,
  }) async {
    return handleAsync<void>(
      operation,
      checkNetwork: checkNetwork,
      networkCheck: networkCheck,
      context: context,
    );
  }

  /// Log une erreur de manière standardisée
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    Logger.error('$context: $error');
    if (stackTrace != null && const bool.fromEnvironment('dart.vm.product') == false) {
      // En mode debug uniquement
      Logger.error('Stack trace: $stackTrace');
    }
  }
}