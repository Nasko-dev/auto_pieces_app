import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/particulier.dart';

part 'particulier_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ParticulierModel extends Particulier {
  const ParticulierModel({
    required super.id,
    super.deviceId,
    super.email,
    super.firstName,
    super.lastName,
    super.phone,
    super.address,
    super.city,
    super.zipCode,
    super.avatarUrl,
    super.isVerified = false,
    super.isActive = true,
    super.isAnonymous = true,
    required super.createdAt,
    super.updatedAt,
    super.emailVerifiedAt,
  });

  factory ParticulierModel.fromJson(Map<String, dynamic> json) {
    return _$ParticulierModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ParticulierModelToJson(this);

  factory ParticulierModel.fromEntity(Particulier particulier) {
    return ParticulierModel(
      id: particulier.id,
      deviceId: particulier.deviceId,
      email: particulier.email,
      firstName: particulier.firstName,
      lastName: particulier.lastName,
      phone: particulier.phone,
      address: particulier.address,
      city: particulier.city,
      zipCode: particulier.zipCode,
      avatarUrl: particulier.avatarUrl,
      isVerified: particulier.isVerified,
      isActive: particulier.isActive,
      isAnonymous: particulier.isAnonymous,
      createdAt: particulier.createdAt,
      updatedAt: particulier.updatedAt,
      emailVerifiedAt: particulier.emailVerifiedAt,
    );
  }

  // Factory pour création depuis Supabase auth anonyme
  factory ParticulierModel.fromAnonymousAuth({
    required String id,
    required String deviceId,
    required DateTime createdAt,
  }) {
    return ParticulierModel(
      id: id,
      deviceId: deviceId,
      createdAt: createdAt,
      isAnonymous: true,
      isVerified: false,
    );
  }

  // Factory pour création depuis Supabase auth avec email
  factory ParticulierModel.fromSupabaseAuth({
    required String id,
    required String email,
    required DateTime createdAt,
    DateTime? emailConfirmedAt,
  }) {
    return ParticulierModel(
      id: id,
      email: email,
      createdAt: createdAt,
      emailVerifiedAt: emailConfirmedAt,
      isVerified: emailConfirmedAt != null,
      isAnonymous: false,
    );
  }

  // Données pour l'insertion en base
  Map<String, dynamic> toInsert() {
    return {
      'id': id,
      'device_id': deviceId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'address': address,
      'city': city,
      'zip_code': zipCode,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'is_active': isActive,
      'is_anonymous': isAnonymous,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
    };
  }

  @override
  ParticulierModel copyWith({
    String? id,
    String? deviceId,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? city,
    String? zipCode,
    String? avatarUrl,
    bool? isVerified,
    bool? isActive,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? emailVerifiedAt,
  }) {
    return ParticulierModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    );
  }
}
