import 'package:cente_pice/src/core/services/device_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'device_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SharedPreferences>()])
void main() {
  late DeviceService deviceService;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    deviceService = DeviceService(mockPrefs);
  });

  group('DeviceService', () {
    group('getDeviceId', () {
      test('doit retourner l\'ID existant s\'il est présent', () async {
        // arrange
        const existingId = 'device_1234567890_abcd1234';
        when(mockPrefs.getString('DEVICE_ID')).thenReturn(existingId);

        // act
        final deviceId = await deviceService.getDeviceId();

        // assert
        expect(deviceId, existingId);
        verify(mockPrefs.getString('DEVICE_ID')).called(1);
        verifyNever(mockPrefs.setString(any, any));
      });

      test('doit générer un nouvel ID si aucun n\'existe', () async {
        // arrange
        when(mockPrefs.getString('DEVICE_ID')).thenReturn(null);
        when(mockPrefs.setString('DEVICE_ID', any))
            .thenAnswer((_) async => true);

        // act
        final deviceId = await deviceService.getDeviceId();

        // assert
        expect(deviceId, isNotNull);
        expect(deviceId.isNotEmpty, true);
        expect(deviceId, startsWith('device_'));
        verify(mockPrefs.getString('DEVICE_ID')).called(1);
        verify(mockPrefs.setString('DEVICE_ID', deviceId)).called(1);
      });

      test('doit générer un nouvel ID si l\'ID existant est vide', () async {
        // arrange
        when(mockPrefs.getString('DEVICE_ID')).thenReturn('');
        when(mockPrefs.setString('DEVICE_ID', any))
            .thenAnswer((_) async => true);

        // act
        final deviceId = await deviceService.getDeviceId();

        // assert
        expect(deviceId, isNotNull);
        expect(deviceId.isNotEmpty, true);
        expect(deviceId, startsWith('device_'));
        verify(mockPrefs.getString('DEVICE_ID')).called(1);
        verify(mockPrefs.setString('DEVICE_ID', deviceId)).called(1);
      });

      test('doit sauvegarder le nouvel ID généré', () async {
        // arrange
        when(mockPrefs.getString('DEVICE_ID')).thenReturn(null);
        when(mockPrefs.setString('DEVICE_ID', any))
            .thenAnswer((_) async => true);

        // act
        final deviceId = await deviceService.getDeviceId();

        // assert
        verify(mockPrefs.setString('DEVICE_ID', deviceId)).called(1);
      });

      test('doit retourner le même ID lors d\'appels multiples', () async {
        // arrange
        const existingId = 'device_1234567890_abcd1234';
        when(mockPrefs.getString('DEVICE_ID')).thenReturn(existingId);

        // act
        final deviceId1 = await deviceService.getDeviceId();
        final deviceId2 = await deviceService.getDeviceId();

        // assert
        expect(deviceId1, deviceId2);
        expect(deviceId1, existingId);
        verify(mockPrefs.getString('DEVICE_ID')).called(2);
      });
    });

    group('ID Generation Format', () {
      test('doit générer des IDs avec le bon format', () async {
        // arrange
        when(mockPrefs.getString('DEVICE_ID')).thenReturn(null);
        when(mockPrefs.setString('DEVICE_ID', any))
            .thenAnswer((_) async => true);

        // act
        final deviceId = await deviceService.getDeviceId();

        // assert
        expect(deviceId, matches(r'^device_\d+_[a-z0-9]{8}$'));
      });

      test('doit générer des IDs uniques', () async {
        // arrange
        when(mockPrefs.getString('DEVICE_ID')).thenReturn(null);
        when(mockPrefs.setString('DEVICE_ID', any))
            .thenAnswer((_) async => true);

        // act
        final deviceId1 = await deviceService.getDeviceId();

        // Réinitialiser le mock pour simuler un nouvel appareil
        when(mockPrefs.getString('DEVICE_ID')).thenReturn(null);
        final deviceService2 = DeviceService(mockPrefs);
        final deviceId2 = await deviceService2.getDeviceId();

        // assert
        expect(deviceId1, isNot(equals(deviceId2)));
      });

      test('doit inclure un timestamp dans l\'ID', () async {
        // arrange
        when(mockPrefs.getString('DEVICE_ID')).thenReturn(null);
        when(mockPrefs.setString('DEVICE_ID', any))
            .thenAnswer((_) async => true);

        final beforeTimestamp = DateTime.now().millisecondsSinceEpoch;

        // act
        final deviceId = await deviceService.getDeviceId();

        final afterTimestamp = DateTime.now().millisecondsSinceEpoch;

        // assert
        final parts = deviceId.split('_');
        expect(parts.length, 3);
        expect(parts[0], 'device');

        final timestamp = int.tryParse(parts[1]);
        expect(timestamp, isNotNull);
        expect(timestamp!, greaterThanOrEqualTo(beforeTimestamp));
        expect(timestamp, lessThanOrEqualTo(afterTimestamp));
      });

      test('doit inclure une partie aléatoire de 8 caractères', () async {
        // arrange
        when(mockPrefs.getString('DEVICE_ID')).thenReturn(null);
        when(mockPrefs.setString('DEVICE_ID', any))
            .thenAnswer((_) async => true);

        // act
        final deviceId = await deviceService.getDeviceId();

        // assert
        final parts = deviceId.split('_');
        expect(parts.length, 3);
        expect(parts[2].length, 8);
        expect(parts[2], matches(r'^[a-z0-9]{8}$'));
      });
    });

    group('clearDeviceId', () {
      test('doit supprimer l\'ID de l\'appareil', () async {
        // arrange
        when(mockPrefs.remove('DEVICE_ID')).thenAnswer((_) async => true);

        // act
        await deviceService.clearDeviceId();

        // assert
        verify(mockPrefs.remove('DEVICE_ID')).called(1);
      });

      test('doit permettre la génération d\'un nouvel ID après suppression',
          () async {
        // arrange
        when(mockPrefs.remove('DEVICE_ID')).thenAnswer((_) async => true);
        when(mockPrefs.getString('DEVICE_ID')).thenReturn(null);
        when(mockPrefs.setString('DEVICE_ID', any))
            .thenAnswer((_) async => true);

        // act
        await deviceService.clearDeviceId();
        final newDeviceId = await deviceService.getDeviceId();

        // assert
        expect(newDeviceId, isNotNull);
        expect(newDeviceId.isNotEmpty, true);
        expect(newDeviceId, startsWith('device_'));
        verify(mockPrefs.remove('DEVICE_ID')).called(1);
        verify(mockPrefs.setString('DEVICE_ID', newDeviceId)).called(1);
      });
    });

    group('Error Handling', () {
      test('doit gérer les erreurs de lecture des préférences', () async {
        // arrange
        when(mockPrefs.getString('DEVICE_ID'))
            .thenThrow(Exception('Read error'));
        when(mockPrefs.setString('DEVICE_ID', any))
            .thenAnswer((_) async => true);

        // act & assert - doit lever l'exception
        expect(() => deviceService.getDeviceId(), throwsException);
      });

      test('doit gérer les erreurs d\'écriture des préférences', () async {
        // arrange
        when(mockPrefs.getString('DEVICE_ID')).thenReturn(null);
        when(mockPrefs.setString('DEVICE_ID', any))
            .thenThrow(Exception('Write error'));

        // act & assert - doit lever l'exception
        expect(() => deviceService.getDeviceId(), throwsException);
      });

      test('doit gérer les erreurs de suppression des préférences', () async {
        // arrange
        when(mockPrefs.remove('DEVICE_ID'))
            .thenThrow(Exception('Remove error'));

        // act & assert - doit lever l'exception
        expect(() => deviceService.clearDeviceId(), throwsException);
      });
    });

    group('Edge Cases', () {
      test('doit gérer les chaînes vides correctement', () async {
        // arrange
        when(mockPrefs.getString('DEVICE_ID')).thenReturn('');
        when(mockPrefs.setString('DEVICE_ID', any))
            .thenAnswer((_) async => true);

        // act
        final deviceId = await deviceService.getDeviceId();

        // assert
        expect(deviceId, isNotEmpty);
        expect(deviceId, startsWith('device_'));
      });

      test('doit gérer les espaces dans l\'ID existant', () async {
        // arrange
        when(mockPrefs.getString('DEVICE_ID')).thenReturn('   ');
        when(mockPrefs.setString('DEVICE_ID', any))
            .thenAnswer((_) async => true);

        // act
        final deviceId = await deviceService.getDeviceId();

        // assert
        // Les espaces ne sont pas considérés comme valides, donc un nouvel ID sera généré
        expect(deviceId, startsWith('device_'));
        expect(deviceId, isNot('   '));
      });
    });

    group('Performance', () {
      test('doit être rapide pour des appels multiples avec ID existant',
          () async {
        // arrange
        const existingId = 'device_1234567890_abcd1234';
        when(mockPrefs.getString('DEVICE_ID')).thenReturn(existingId);

        // act
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 100; i++) {
          await deviceService.getDeviceId();
        }
        stopwatch.stop();

        // assert
        expect(stopwatch.elapsedMilliseconds,
            lessThan(1000)); // Moins d'1 seconde pour 100 appels
        verify(mockPrefs.getString('DEVICE_ID')).called(100);
        verifyNever(mockPrefs.setString(any, any));
      });
    });

    group('State Consistency', () {
      test('doit maintenir la cohérence après des opérations multiples',
          () async {
        // arrange
        when(mockPrefs.getString('DEVICE_ID')).thenReturn(null);
        when(mockPrefs.setString('DEVICE_ID', any))
            .thenAnswer((_) async => true);
        when(mockPrefs.remove('DEVICE_ID')).thenAnswer((_) async => true);

        // act
        final id1 = await deviceService.getDeviceId();

        // Simuler que l'ID est maintenant sauvegardé
        when(mockPrefs.getString('DEVICE_ID')).thenReturn(id1);

        final id2 = await deviceService.getDeviceId();

        await deviceService.clearDeviceId();

        // Simuler ID supprimé
        when(mockPrefs.getString('DEVICE_ID')).thenReturn(null);
        when(mockPrefs.setString('DEVICE_ID', any))
            .thenAnswer((_) async => true);

        final id3 = await deviceService.getDeviceId();

        // assert
        expect(id1, equals(id2)); // Même ID avant suppression
        expect(id1, isNot(equals(id3))); // Nouvel ID après suppression
        expect(id3, startsWith('device_'));
      });
    });
  });
}
