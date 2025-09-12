import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/particulier.dart';

abstract class ParticulierAuthRepository {
  Future<Either<Failure, Particulier>> signInAnonymously();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, Particulier>> getCurrentParticulier();

  Future<Either<Failure, bool>> isLoggedIn();
}