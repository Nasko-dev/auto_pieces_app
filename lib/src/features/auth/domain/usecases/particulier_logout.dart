import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/particulier_auth_repository.dart';

class ParticulierLogout implements UseCase<void, NoParams> {
  final ParticulierAuthRepository repository;

  ParticulierLogout(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}