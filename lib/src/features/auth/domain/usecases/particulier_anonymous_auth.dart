import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/particulier.dart';
import '../repositories/particulier_auth_repository.dart';

class ParticulierAnonymousAuth implements UseCase<Particulier, NoParams> {
  final ParticulierAuthRepository repository;

  ParticulierAnonymousAuth(this.repository);

  @override
  Future<Either<Failure, Particulier>> call(NoParams params) async {
    return await repository.signInAnonymously();
  }
}