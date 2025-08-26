import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginAsParticulier {
  final AuthRepository repository;

  LoginAsParticulier(this.repository);

  Future<Either<Failure, User>> call() async {
    return await repository.loginAsParticulier();
  }
}