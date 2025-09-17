import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/particulier.dart';
import '../repositories/particulier_auth_repository.dart';

class UpdateParticulier {
  final ParticulierAuthRepository repository;

  UpdateParticulier(this.repository);

  Future<Either<Failure, Particulier>> call(Particulier particulier) async {
    return await repository.updateParticulier(particulier);
  }
}