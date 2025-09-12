// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'particulier_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParticulierModel _$ParticulierModelFromJson(Map<String, dynamic> json) =>
    ParticulierModel(
      id: json['id'] as String,
      deviceId: json['device_id'] as String?,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      zipCode: json['zip_code'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      isAnonymous: json['is_anonymous'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      emailVerifiedAt: json['email_verified_at'] == null
          ? null
          : DateTime.parse(json['email_verified_at'] as String),
    );

Map<String, dynamic> _$ParticulierModelToJson(ParticulierModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'device_id': instance.deviceId,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone': instance.phone,
      'address': instance.address,
      'city': instance.city,
      'zip_code': instance.zipCode,
      'is_verified': instance.isVerified,
      'is_active': instance.isActive,
      'is_anonymous': instance.isAnonymous,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'email_verified_at': instance.emailVerifiedAt?.toIso8601String(),
    };
