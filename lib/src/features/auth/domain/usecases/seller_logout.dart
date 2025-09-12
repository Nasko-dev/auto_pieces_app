import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/seller_auth_repository.dart';

class SellerLogout implements UseCase<void, NoParams> {
  final SellerAuthRepository repository;

  SellerLogout(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return repository.logoutSeller();
  }
}