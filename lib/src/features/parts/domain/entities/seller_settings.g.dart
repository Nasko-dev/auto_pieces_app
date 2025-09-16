// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SellerSettingsImpl _$$SellerSettingsImplFromJson(Map<String, dynamic> json) =>
    _$SellerSettingsImpl(
      sellerId: json['sellerId'] as String,
      companyName: json['companyName'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String?,
      siret: json['siret'] as String?,
      description: json['description'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      emailNotificationsEnabled:
          json['emailNotificationsEnabled'] as bool? ?? true,
      isActive: json['isActive'] as bool?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SellerSettingsImplToJson(
        _$SellerSettingsImpl instance) =>
    <String, dynamic>{
      'sellerId': instance.sellerId,
      'companyName': instance.companyName,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'city': instance.city,
      'postalCode': instance.postalCode,
      'country': instance.country,
      'siret': instance.siret,
      'description': instance.description,
      'avatarUrl': instance.avatarUrl,
      'notificationsEnabled': instance.notificationsEnabled,
      'emailNotificationsEnabled': instance.emailNotificationsEnabled,
      'isActive': instance.isActive,
      'preferences': instance.preferences,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
