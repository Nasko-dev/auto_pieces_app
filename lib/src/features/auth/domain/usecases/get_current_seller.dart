import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller.dart';
import '../repositories/seller_auth_repository.dart';

class GetCurrentSeller implements UseCase<Seller, NoParams> {
  final SellerAuthRepository repository;

  GetCurrentSeller(this.repository);

  @override
  Future<Either<Failure, Seller>> call(NoParams params) async {
    return repository.getCurrentSeller();
  }
}
