import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_settings.dart';

part 'user_settings_model.freezed.dart';
part 'user_settings_model.g.dart';

@freezed
class UserSettingsModel with _$UserSettingsModel {
  const UserSettingsModel._();
  
  const factory UserSettingsModel({
    required String userId,
    String? displayName,
    String? address,
    String? city,
    String? postalCode,
    @Default('France') String country,
    String? phone,
    String? avatarUrl,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool emailNotificationsEnabled,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? createdAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? updatedAt,
  }) = _UserSettingsModel;

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsModelFromJson(json);

  UserSettings toEntity() => UserSettings(
        userId: userId,
        displayName: displayName,
        address: address,
        city: city,
        postalCode: postalCode,
        country: country,
        phone: phone,
        avatarUrl: avatarUrl,
        notificationsEnabled: notificationsEnabled,
        emailNotificationsEnabled: emailNotificationsEnabled,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory UserSettingsModel.fromEntity(UserSettings entity) => UserSettingsModel(
        userId: entity.userId,
        displayName: entity.displayName,
        address: entity.address,
        city: entity.city,
        postalCode: entity.postalCode,
        country: entity.country,
        phone: entity.phone,
        avatarUrl: entity.avatarUrl,
        notificationsEnabled: entity.notificationsEnabled,
        emailNotificationsEnabled: entity.emailNotificationsEnabled,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}

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