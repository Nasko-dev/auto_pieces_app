import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/seller_settings.dart';

part 'seller_settings_model.freezed.dart';
part 'seller_settings_model.g.dart';

// Helper functions pour la conversion des dates
DateTime? _dateTimeFromJson(dynamic json) {
  if (json == null) return null;
  if (json is String) {
    return DateTime.tryParse(json);
  }
  if (json is DateTime) return json;
  return null;
}

String? _dateTimeToJson(DateTime? dateTime) {
  return dateTime?.toIso8601String();
}

@freezed
class SellerSettingsModel with _$SellerSettingsModel {
  const SellerSettingsModel._();

  const factory SellerSettingsModel({
    required String sellerId,
    required String email,
    String? firstName,
    String? lastName,
    String? companyName,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    String? siret,
    String? avatarUrl,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool emailNotificationsEnabled,
    @Default(true) bool isActive,
    @Default(false) bool isVerified,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SellerSettingsModel;

  factory SellerSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SellerSettingsModelFromJson(json);

  SellerSettings toEntity() => SellerSettings(
        sellerId: sellerId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        companyName: companyName,
        phone: phone,
        address: address,
        city: city,
        postalCode: postalCode,
        siret: siret,
        avatarUrl: avatarUrl,
        notificationsEnabled: notificationsEnabled,
        emailNotificationsEnabled: emailNotificationsEnabled,
        isActive: isActive,
        isVerified: isVerified,
        emailVerifiedAt: emailVerifiedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory SellerSettingsModel.fromEntity(SellerSettings entity) => SellerSettingsModel(
        sellerId: entity.sellerId,
        email: entity.email,
        firstName: entity.firstName,
        lastName: entity.lastName,
        companyName: entity.companyName,
        phone: entity.phone,
        address: entity.address,
        city: entity.city,
        postalCode: entity.postalCode,
        siret: entity.siret,
        avatarUrl: entity.avatarUrl,
        notificationsEnabled: entity.notificationsEnabled,
        emailNotificationsEnabled: entity.emailNotificationsEnabled,
        isActive: entity.isActive,
        isVerified: entity.isVerified,
        emailVerifiedAt: entity.emailVerifiedAt,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}