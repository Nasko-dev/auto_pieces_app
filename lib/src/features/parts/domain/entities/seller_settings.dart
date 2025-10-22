import 'package:freezed_annotation/freezed_annotation.dart';

part 'seller_settings.freezed.dart';

@freezed
class SellerSettings with _$SellerSettings {
  const factory SellerSettings({
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
  }) = _SellerSettings;
}
