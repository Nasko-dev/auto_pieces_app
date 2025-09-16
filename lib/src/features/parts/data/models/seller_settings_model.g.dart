// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SellerSettingsModelImpl _$$SellerSettingsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SellerSettingsModelImpl(
      sellerId: json['sellerId'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      companyName: json['companyName'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      postalCode: json['postalCode'] as String?,
      siret: json['siret'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      emailNotificationsEnabled:
          json['emailNotificationsEnabled'] as bool? ?? true,
      isActive: json['isActive'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
      emailVerifiedAt: _dateTimeFromJson(json['emailVerifiedAt']),
      createdAt: _dateTimeFromJson(json['createdAt']),
      updatedAt: _dateTimeFromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$SellerSettingsModelImplToJson(
        _$SellerSettingsModelImpl instance) =>
    <String, dynamic>{
      'sellerId': instance.sellerId,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'companyName': instance.companyName,
      'phone': instance.phone,
      'address': instance.address,
      'city': instance.city,
      'postalCode': instance.postalCode,
      'siret': instance.siret,
      'avatarUrl': instance.avatarUrl,
      'notificationsEnabled': instance.notificationsEnabled,
      'emailNotificationsEnabled': instance.emailNotificationsEnabled,
      'isActive': instance.isActive,
      'isVerified': instance.isVerified,
      'emailVerifiedAt': _dateTimeToJson(instance.emailVerifiedAt),
      'createdAt': _dateTimeToJson(instance.createdAt),
      'updatedAt': _dateTimeToJson(instance.updatedAt),
    };
