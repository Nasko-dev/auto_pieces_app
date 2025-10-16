import 'package:equatable/equatable.dart';

class Seller extends Equatable {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? companyName;
  final String? phone;
  final String? address;
  final String? city;
  final String? zipCode;
  final String? siret;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? emailVerifiedAt;

  const Seller({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.companyName,
    this.phone,
    this.address,
    this.city,
    this.zipCode,
    this.siret,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.emailVerifiedAt,
  });

  String get displayName {
    if (companyName != null && companyName!.isNotEmpty) {
      return companyName!;
    }
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return email.split('@').first;
  }

  bool get hasCompanyInfo => companyName != null && siret != null;
  bool get hasPersonalInfo => firstName != null && lastName != null;
  bool get isCompleteProfile => hasCompanyInfo || hasPersonalInfo;

  Seller copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? companyName,
    String? phone,
    String? address,
    String? city,
    String? zipCode,
    String? siret,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? emailVerifiedAt,
  }) {
    return Seller(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      siret: siret ?? this.siret,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        companyName,
        phone,
        address,
        city,
        zipCode,
        siret,
        isVerified,
        isActive,
        createdAt,
        updatedAt,
        emailVerifiedAt,
      ];
}
