import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/seller_auth_repository.dart';

class SellerForgotPassword
    implements UseCase<void, SellerForgotPasswordParams> {
  final SellerAuthRepository repository;

  SellerForgotPassword(this.repository);

  @override
  Future<Either<Failure, void>> call(SellerForgotPasswordParams params) async {
    // Validation des paramètres
    if (params.email.isEmpty) {
      return const Left(ValidationFailure('L\'email est requis'));
    }

    // Validation du format email
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(params.email)) {
      return const Left(ValidationFailure('Format d\'email invalide'));
    }

    return repository.sendPasswordResetEmail(
      params.email.toLowerCase().trim(),
    );
  }
}

class SellerForgotPasswordParams extends Equatable {
  final String email;

  const SellerForgotPasswordParams({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}
