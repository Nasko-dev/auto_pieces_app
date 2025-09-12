import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller.dart';
import '../repositories/seller_auth_repository.dart';

class SellerLogin implements UseCase<Seller, SellerLoginParams> {
  final SellerAuthRepository repository;

  SellerLogin(this.repository);

  @override
  Future<Either<Failure, Seller>> call(SellerLoginParams params) async {
    // Validation des paramètres
    if (params.email.isEmpty) {
      return const Left(ValidationFailure('L\'email est requis'));
    }

    if (params.password.isEmpty) {
      return const Left(ValidationFailure('Le mot de passe est requis'));
    }

    // Validation du format email
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(params.email)) {
      return const Left(ValidationFailure('Format d\'email invalide'));
    }

    return repository.loginSeller(
      email: params.email.toLowerCase().trim(),
      password: params.password,
    );
  }
}

class SellerLoginParams extends Equatable {
  final String email;
  final String password;

  const SellerLoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}