import 'package:freezed_annotation/freezed_annotation.dart';

part 'seller_settings.freezed.dart';
part 'seller_settings.g.dart';

@freezed
class SellerSettings with _$SellerSettings {
  const factory SellerSettings({
    required String sellerId,
    String? companyName,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    String? siret,
    String? description,
    bool? isActive,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SellerSettings;

  factory SellerSettings.fromJson(Map<String, dynamic> json) =>
      _$SellerSettingsFromJson(json);
}