import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/seller.dart';

abstract class SellerAuthRepository {
  Future<Either<Failure, Seller>> registerSeller({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? companyName,
    String? phone,
  });
  
  Future<Either<Failure, Seller>> loginSeller({
    required String email,
    required String password,
  });
  
  Future<Either<Failure, void>> logoutSeller();
  
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
  
  Future<Either<Failure, Seller>> getCurrentSeller();
  
  Future<Either<Failure, Seller>> updateSellerProfile(Seller seller);
  
  Future<Either<Failure, void>> sendEmailVerification();
  
  Future<Either<Failure, void>> verifyEmail(String token);
}