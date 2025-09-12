import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller.dart';
import '../repositories/seller_auth_repository.dart';
import 'package:equatable/equatable.dart';

class SellerRegister implements UseCase<Seller, SellerRegisterParams> {
  final SellerAuthRepository repository;

  SellerRegister(this.repository);

  @override
  Future<Either<Failure, Seller>> call(SellerRegisterParams params) async {
    // Validation des paramètres
    if (params.email.isEmpty) {
      return const Left(ValidationFailure('L\'email est requis'));
    }

    if (params.password.isEmpty) {
      return const Left(ValidationFailure('Le mot de passe est requis'));
    }

    if (params.password.length < 8) {
      return const Left(ValidationFailure('Le mot de passe doit contenir au moins 8 caractères'));
    }

    if (params.confirmPassword != params.password) {
      return const Left(ValidationFailure('Les mots de passe ne correspondent pas'));
    }

    // Validation du format email
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(params.email)) {
      return const Left(ValidationFailure('Format d\'email invalide'));
    }

    // Validation du mot de passe fort
    if (!_isStrongPassword(params.password)) {
      return const Left(ValidationFailure(
        'Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial'
      ));
    }

    // Si un nom d'entreprise est fourni, vérifier qu'il ne soit pas vide
    if (params.companyName != null && params.companyName!.trim().isEmpty) {
      return const Left(ValidationFailure('Le nom d\'entreprise ne peut pas être vide'));
    }

    // Validation du téléphone si fourni
    if (params.phone != null && !_isValidPhone(params.phone!)) {
      return const Left(ValidationFailure('Format de téléphone invalide'));
    }

    return repository.registerSeller(
      email: params.email.toLowerCase().trim(),
      password: params.password,
      firstName: params.firstName?.trim(),
      lastName: params.lastName?.trim(),
      companyName: params.companyName?.trim(),
      phone: params.phone?.trim(),
    );
  }

  bool _isStrongPassword(String password) {
    return password.length >= 8 &&
           RegExp(r'[A-Z]').hasMatch(password) && // Au moins une majuscule
           RegExp(r'[a-z]').hasMatch(password) && // Au moins une minuscule
           RegExp(r'[0-9]').hasMatch(password) && // Au moins un chiffre
           RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password); // Au moins un caractère spécial
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^(?:(?:\+|00)33|0)\s*[1-9](?:[\s.-]*\d{2}){4}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s.-]'), ''));
  }
}

class SellerRegisterParams extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final String? firstName;
  final String? lastName;
  final String? companyName;
  final String? phone;

  const SellerRegisterParams({
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.firstName,
    this.lastName,
    this.companyName,
    this.phone,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    confirmPassword,
    firstName,
    lastName,
    companyName,
    phone,
  ];
}