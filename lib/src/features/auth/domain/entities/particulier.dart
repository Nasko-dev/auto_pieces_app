import 'package:equatable/equatable.dart';

class Particulier extends Equatable {
  final String id;
  final String? deviceId;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? address;
  final String? city;
  final String? zipCode;
  final String? avatar_url;
  final bool isVerified;
  final bool isActive;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? emailVerifiedAt;

  const Particulier({
    required this.id,
    this.deviceId,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.address,
    this.city,
    this.zipCode,
    this.avatar_url,
    this.isVerified = false,
    this.isActive = true,
    this.isAnonymous = true,
    required this.createdAt,
    this.updatedAt,
    this.emailVerifiedAt,
  });

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) {
      return firstName!;
    }
    if (email != null) {
      return email!.split('@').first;
    }
    return 'Utilisateur Anonyme';
  }

  bool get hasPersonalInfo => firstName != null && lastName != null;
  bool get isCompleteProfile => hasPersonalInfo && phone != null;

  Particulier copyWith({
    String? id,
    String? deviceId,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? city,
    String? zipCode,
    String? avatar_url,
    bool? isVerified,
    bool? isActive,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? emailVerifiedAt,
  }) {
    return Particulier(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      avatar_url: avatar_url ?? this.avatar_url,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        deviceId,
        email,
        firstName,
        lastName,
        phone,
        address,
        city,
        zipCode,
        avatar_url,
        isVerified,
        isActive,
        isAnonymous,
        createdAt,
        updatedAt,
        emailVerifiedAt,
      ];
}