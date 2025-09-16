import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings.freezed.dart';

@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserSettings;
}