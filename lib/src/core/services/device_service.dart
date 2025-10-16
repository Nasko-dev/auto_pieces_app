import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  static const String _deviceIdKey = 'DEVICE_ID';
  final SharedPreferences _prefs;

  DeviceService(this._prefs);

  /// Récupère ou génère l'identifiant unique de l'appareil
  Future<String> getDeviceId() async {
    String? deviceId = _prefs.getString(_deviceIdKey);

    if (deviceId == null || deviceId.trim().isEmpty) {
      deviceId = _generateDeviceId();
      await _prefs.setString(_deviceIdKey, deviceId);
    } else {}

    return deviceId;
  }

  /// Génère un identifiant unique pour l'appareil
  String _generateDeviceId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Générer une partie aléatoire
    final randomPart =
        List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();

    // Combiner timestamp et partie aléatoire
    return 'device_${timestamp}_$randomPart';
  }

  /// Efface l'identifiant de l'appareil (utile pour les tests)
  Future<void> clearDeviceId() async {
    await _prefs.remove(_deviceIdKey);
  }
}
