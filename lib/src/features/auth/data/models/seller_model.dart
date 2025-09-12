import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/seller.dart';

part 'seller_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SellerModel extends Seller {
  const SellerModel({
    required super.id,
    required super.email,
    super.firstName,
    super.lastName,
    super.companyName,
    super.phone,
    super.address,
    super.city,
    super.zipCode,
    super.siret,
    super.isVerified = false,
    super.isActive = true,
    required super.createdAt,
    super.updatedAt,
    super.emailVerifiedAt,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return _$SellerModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SellerModelToJson(this);

  factory SellerModel.fromEntity(Seller seller) {
    return SellerModel(
      id: seller.id,
      email: seller.email,
      firstName: seller.firstName,
      lastName: seller.lastName,
      companyName: seller.companyName,
      phone: seller.phone,
      address: seller.address,
      city: seller.city,
      zipCode: seller.zipCode,
      siret: seller.siret,
      isVerified: seller.isVerified,
      isActive: seller.isActive,
      createdAt: seller.createdAt,
      updatedAt: seller.updatedAt,
      emailVerifiedAt: seller.emailVerifiedAt,
    );
  }

  // Factory pour création depuis Supabase auth
  factory SellerModel.fromSupabaseAuth({
    required String id,
    required String email,
    required DateTime createdAt,
    DateTime? emailConfirmedAt,
  }) {
    return SellerModel(
      id: id,
      email: email,
      createdAt: createdAt,
      emailVerifiedAt: emailConfirmedAt,
      isVerified: emailConfirmedAt != null,
    );
  }

  // Données pour l'insertion en base
  Map<String, dynamic> toInsert() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'company_name': companyName,
      'phone': phone,
      'address': address,
      'city': city,
      'zip_code': zipCode,
      'siret': siret,
      'is_verified': isVerified,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
    };
  }
}