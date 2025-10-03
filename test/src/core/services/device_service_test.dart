import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cente_pice/src/core/services/device_service.dart';

void main() {
  group('DeviceService', () {
    late SharedPreferences prefs;
    late DeviceService deviceService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      deviceService = DeviceService(prefs);
    });

    tearDown(() async {
      await prefs.clear();
    });

    test('devrait générer un device ID la première fois', () async {
      final deviceId = await deviceService.getDeviceId();

      expect(deviceId, isNotEmpty);
      expect(deviceId, startsWith('device_'));
    });

    test('devrait retourner le même device ID lors des appels suivants', () async {
      final deviceId1 = await deviceService.getDeviceId();
      final deviceId2 = await deviceService.getDeviceId();
      final deviceId3 = await deviceService.getDeviceId();

      expect(deviceId1, equals(deviceId2));
      expect(deviceId2, equals(deviceId3));
    });

    test('devrait persister le device ID dans SharedPreferences', () async {
      final deviceId = await deviceService.getDeviceId();

      final savedId = prefs.getString('DEVICE_ID');

      expect(savedId, equals(deviceId));
    });

    test('le device ID devrait avoir un format valide', () async {
      final deviceId = await deviceService.getDeviceId();

      // Format: device_<timestamp>_<random>
      final parts = deviceId.split('_');

      expect(parts.length, 3);
      expect(parts[0], 'device');
      expect(int.tryParse(parts[1]), isNotNull); // Timestamp doit être un nombre
      expect(parts[2].length, 8); // Partie aléatoire de 8 caractères
    });

    test('la partie aléatoire devrait contenir uniquement des caractères valides', () async {
      final deviceId = await deviceService.getDeviceId();
      final randomPart = deviceId.split('_')[2];

      final validChars = RegExp(r'^[a-z0-9]+$');
      expect(validChars.hasMatch(randomPart), isTrue);
    });

    test('clearDeviceId devrait supprimer le device ID', () async {
      // Générer un device ID
      final deviceId1 = await deviceService.getDeviceId();
      expect(deviceId1, isNotEmpty);

      // Effacer
      await deviceService.clearDeviceId();

      // Vérifier qu'il n'est plus dans les préférences
      final savedId = prefs.getString('DEVICE_ID');
      expect(savedId, isNull);
    });

    test('devrait générer un nouveau device ID après clearDeviceId', () async {
      final deviceId1 = await deviceService.getDeviceId();

      await deviceService.clearDeviceId();

      final deviceId2 = await deviceService.getDeviceId();

      expect(deviceId2, isNotEmpty);
      expect(deviceId1, isNot(equals(deviceId2)));
    });

    test('devrait gérer un device ID vide ou invalide dans SharedPreferences', () async {
      // Simuler un device ID vide
      await prefs.setString('DEVICE_ID', '');

      final deviceId = await deviceService.getDeviceId();

      expect(deviceId, isNotEmpty);
      expect(deviceId, startsWith('device_'));
    });

    test('devrait gérer un device ID avec des espaces', () async {
      await prefs.setString('DEVICE_ID', '   ');

      final deviceId = await deviceService.getDeviceId();

      expect(deviceId, isNotEmpty);
      expect(deviceId, startsWith('device_'));
    });

    test('deux instances de DeviceService devraient utiliser le même ID', () async {
      final deviceService1 = DeviceService(prefs);
      final deviceService2 = DeviceService(prefs);

      final id1 = await deviceService1.getDeviceId();
      final id2 = await deviceService2.getDeviceId();

      expect(id1, equals(id2));
    });

    test('devrait générer des IDs uniques pour chaque nouveau device', () async {
      final service1 = DeviceService(prefs);
      final id1 = await service1.getDeviceId();

      await service1.clearDeviceId();

      final service2 = DeviceService(prefs);
      final id2 = await service2.getDeviceId();

      expect(id1, isNot(equals(id2)));
    });

    test('le timestamp dans le device ID devrait être récent', () async {
      final beforeTimestamp = DateTime.now().millisecondsSinceEpoch;

      final deviceId = await deviceService.getDeviceId();
      final deviceTimestamp = int.parse(deviceId.split('_')[1]);

      final afterTimestamp = DateTime.now().millisecondsSinceEpoch;

      expect(deviceTimestamp, greaterThanOrEqualTo(beforeTimestamp));
      expect(deviceTimestamp, lessThanOrEqualTo(afterTimestamp));
    });

    test('devrait gérer plusieurs appels concurrents correctement', () async {
      final futures = <Future<String>>[];

      for (int i = 0; i < 5; i++) {
        futures.add(deviceService.getDeviceId());
      }

      final results = await Future.wait(futures);

      // Tous les résultats devraient être identiques
      expect(results.toSet().length, 1);
    });
  });
}
