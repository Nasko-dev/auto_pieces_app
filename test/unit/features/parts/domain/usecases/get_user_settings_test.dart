import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/domain/entities/user_settings.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/user_settings_repository.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/get_user_settings.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_user_settings_test.mocks.dart';

@GenerateMocks([UserSettingsRepository])
void main() {
  late GetUserSettings usecase;
  late MockUserSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockUserSettingsRepository();
    usecase = GetUserSettings(mockRepository);
  });

  const tUserId = 'user123';

  final tUserSettings = UserSettings(
    userId: tUserId,
    displayName: 'Marie Martin',
    address: '456 Avenue de la République',
    city: 'Lyon',
    postalCode: '69001',
    country: 'France',
    phone: '+33987654321',
    avatarUrl: 'https://example.com/user_avatar.jpg',
    notificationsEnabled: true,
    emailNotificationsEnabled: true,
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    updatedAt: DateTime.now().subtract(const Duration(days: 5)),
  );

  group('GetUserSettings', () {
    test('doit retourner UserSettings quand les paramètres existent', () async {
      // arrange
      when(mockRepository.getUserSettings(tUserId))
          .thenAnswer((_) async => Right(tUserSettings));

      // act
      final result = await usecase(tUserId);

      // assert
      expect(result, Right(tUserSettings));
      verify(mockRepository.getUserSettings(tUserId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner null quand les paramètres n\'existent pas', () async {
      // arrange
      when(mockRepository.getUserSettings(tUserId))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(tUserId);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) => expect(settings, null),
      );
      verify(mockRepository.getUserSettings(tUserId));
    });

    test('doit retourner AuthFailure quand l\'utilisateur n\'est pas connecté',
        () async {
      // arrange
      when(mockRepository.getUserSettings(tUserId)).thenAnswer(
          (_) async => const Left(AuthFailure('Utilisateur non connecté')));

      // act
      final result = await usecase(tUserId);

      // assert
      expect(result, const Left(AuthFailure('Utilisateur non connecté')));
      verify(mockRepository.getUserSettings(tUserId));
    });

    test('doit retourner ValidationFailure quand l\'utilisateur n\'existe pas',
        () async {
      // arrange
      when(mockRepository.getUserSettings(tUserId)).thenAnswer(
          (_) async => const Left(ValidationFailure('Utilisateur non trouvé')));

      // act
      final result = await usecase(tUserId);

      // assert
      expect(result, const Left(ValidationFailure('Utilisateur non trouvé')));
      verify(mockRepository.getUserSettings(tUserId));
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.getUserSettings(tUserId))
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(tUserId);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRepository.getUserSettings(tUserId));
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau',
        () async {
      // arrange
      when(mockRepository.getUserSettings(tUserId)).thenAnswer(
          (_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(tUserId);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.getUserSettings(tUserId));
    });

    test('doit appeler le repository avec le bon userId', () async {
      // arrange
      when(mockRepository.getUserSettings(tUserId))
          .thenAnswer((_) async => Right(tUserSettings));

      // act
      await usecase(tUserId);

      // assert
      final captured =
          verify(mockRepository.getUserSettings(captureAny)).captured;
      expect(captured.first, tUserId);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = CacheFailure('Erreur de cache');
      when(mockRepository.getUserSettings(tUserId))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(tUserId);

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions du repository', () async {
      // arrange
      when(mockRepository.getUserSettings(tUserId))
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(tUserId),
        throwsA(isA<Exception>()),
      );
    });

    test('doit retourner les paramètres avec toutes les propriétés correctes',
        () async {
      // arrange
      when(mockRepository.getUserSettings(tUserId))
          .thenAnswer((_) async => Right(tUserSettings));

      // act
      final result = await usecase(tUserId);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings, isNotNull);
          expect(settings!.userId, tUserId);
          expect(settings.displayName, 'Marie Martin');
          expect(settings.address, '456 Avenue de la République');
          expect(settings.city, 'Lyon');
          expect(settings.postalCode, '69001');
          expect(settings.country, 'France');
          expect(settings.phone, '+33987654321');
          expect(settings.avatarUrl, 'https://example.com/user_avatar.jpg');
          expect(settings.notificationsEnabled, true);
          expect(settings.emailNotificationsEnabled, true);
          expect(settings.createdAt, isNotNull);
          expect(settings.updatedAt, isNotNull);
        },
      );
    });

    test('doit gérer les paramètres avec informations minimales', () async {
      // arrange
      final minimalSettings = UserSettings(
        userId: tUserId,
        notificationsEnabled: false,
        emailNotificationsEnabled: false,
      );

      when(mockRepository.getUserSettings(tUserId))
          .thenAnswer((_) async => Right(minimalSettings));

      // act
      final result = await usecase(tUserId);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings, isNotNull);
          expect(settings!.userId, tUserId);
          expect(settings.displayName, null);
          expect(settings.address, null);
          expect(settings.city, null);
          expect(settings.postalCode, null);
          expect(settings.country, 'France'); // Valeur par défaut
          expect(settings.phone, null);
          expect(settings.avatarUrl, null);
          expect(settings.notificationsEnabled, false);
          expect(settings.emailNotificationsEnabled, false);
          expect(settings.createdAt, null);
          expect(settings.updatedAt, null);
        },
      );
    });

    test('doit gérer les paramètres avec différents pays', () async {
      // arrange
      final frenchSettings = UserSettings(
        userId: tUserId,
        displayName: 'Pierre Français',
        country: 'France',
        city: 'Paris',
      );

      final belgianSettings = UserSettings(
        userId: 'user456',
        displayName: 'Jean Belge',
        country: 'Belgique',
        city: 'Bruxelles',
      );

      final swissSettings = UserSettings(
        userId: 'user789',
        displayName: 'Anne Suisse',
        country: 'Suisse',
        city: 'Genève',
      );

      when(mockRepository.getUserSettings(tUserId))
          .thenAnswer((_) async => Right(frenchSettings));
      when(mockRepository.getUserSettings('user456'))
          .thenAnswer((_) async => Right(belgianSettings));
      when(mockRepository.getUserSettings('user789'))
          .thenAnswer((_) async => Right(swissSettings));

      // act
      final result1 = await usecase(tUserId);
      final result2 = await usecase('user456');
      final result3 = await usecase('user789');

      // assert
      result1.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings!.country, 'France');
          expect(settings.city, 'Paris');
        },
      );

      result2.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings!.country, 'Belgique');
          expect(settings.city, 'Bruxelles');
        },
      );

      result3.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings!.country, 'Suisse');
          expect(settings.city, 'Genève');
        },
      );
    });

    test('doit gérer les paramètres avec différents niveaux de notifications',
        () async {
      // arrange
      final allNotificationsSettings = UserSettings(
        userId: tUserId,
        displayName: 'Utilisateur Tout',
        notificationsEnabled: true,
        emailNotificationsEnabled: true,
      );

      final partialNotificationsSettings = UserSettings(
        userId: 'user456',
        displayName: 'Utilisateur Partiel',
        notificationsEnabled: true,
        emailNotificationsEnabled: false,
      );

      final noNotificationsSettings = UserSettings(
        userId: 'user789',
        displayName: 'Utilisateur Silencieux',
        notificationsEnabled: false,
        emailNotificationsEnabled: false,
      );

      when(mockRepository.getUserSettings(tUserId))
          .thenAnswer((_) async => Right(allNotificationsSettings));
      when(mockRepository.getUserSettings('user456'))
          .thenAnswer((_) async => Right(partialNotificationsSettings));
      when(mockRepository.getUserSettings('user789'))
          .thenAnswer((_) async => Right(noNotificationsSettings));

      // act
      final result1 = await usecase(tUserId);
      final result2 = await usecase('user456');
      final result3 = await usecase('user789');

      // assert
      result1.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings!.notificationsEnabled, true);
          expect(settings.emailNotificationsEnabled, true);
        },
      );

      result2.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings!.notificationsEnabled, true);
          expect(settings.emailNotificationsEnabled, false);
        },
      );

      result3.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings!.notificationsEnabled, false);
          expect(settings.emailNotificationsEnabled, false);
        },
      );
    });

    test('doit gérer les paramètres avec adresses complètes', () async {
      // arrange
      final completeAddressSettings = UserSettings(
        userId: tUserId,
        displayName: 'Utilisateur Complet',
        address: '123 Rue de la Liberté, Apt 5B',
        city: 'Marseille',
        postalCode: '13001',
        country: 'France',
        phone: '+33456789012',
      );

      when(mockRepository.getUserSettings(tUserId))
          .thenAnswer((_) async => Right(completeAddressSettings));

      // act
      final result = await usecase(tUserId);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings!.address, '123 Rue de la Liberté, Apt 5B');
          expect(settings.city, 'Marseille');
          expect(settings.postalCode, '13001');
          expect(settings.country, 'France');
          expect(settings.phone, '+33456789012');
        },
      );
    });

    test('doit fonctionner avec différents userId', () async {
      // arrange
      const user1Id = 'user1';
      const user2Id = 'user2';

      final settings1 =
          UserSettings(userId: user1Id, displayName: 'Utilisateur 1');
      final settings2 =
          UserSettings(userId: user2Id, displayName: 'Utilisateur 2');

      when(mockRepository.getUserSettings(user1Id))
          .thenAnswer((_) async => Right(settings1));
      when(mockRepository.getUserSettings(user2Id))
          .thenAnswer((_) async => Right(settings2));

      // act
      final result1 = await usecase(user1Id);
      final result2 = await usecase(user2Id);

      // assert
      expect(result1, Right(settings1));
      expect(result2, Right(settings2));
      verify(mockRepository.getUserSettings(user1Id));
      verify(mockRepository.getUserSettings(user2Id));
    });

    test('doit retourner les mêmes paramètres à chaque appel (cohérence)',
        () async {
      // arrange
      when(mockRepository.getUserSettings(tUserId))
          .thenAnswer((_) async => Right(tUserSettings));

      // act
      final result1 = await usecase(tUserId);
      final result2 = await usecase(tUserId);

      // assert
      expect(result1, equals(result2));
      verify(mockRepository.getUserSettings(tUserId)).called(2);
    });

    test('doit gérer les IDs d\'utilisateur avec différents formats', () async {
      // arrange & act & assert
      final validIds = [
        'user123',
        'USER-456',
        'user_789',
        '12345',
        'uuid-style-f47ac10b-58cc-4372-a567-0e02b2c3d479',
      ];

      for (final validId in validIds) {
        final settings =
            UserSettings(userId: validId, displayName: 'Utilisateur $validId');
        when(mockRepository.getUserSettings(validId))
            .thenAnswer((_) async => Right(settings));

        final result = await usecase(validId);
        expect(result, Right(settings));
        verify(mockRepository.getUserSettings(validId));
      }
    });

    test('doit gérer les paramètres avec avatars personnalisés', () async {
      // arrange
      final avatarSettings = UserSettings(
        userId: tUserId,
        displayName: 'Utilisateur avec Avatar',
        avatarUrl: 'https://cdn.example.com/avatars/user123.png',
      );

      final noAvatarSettings = UserSettings(
        userId: 'user456',
        displayName: 'Utilisateur sans Avatar',
        avatarUrl: null,
      );

      when(mockRepository.getUserSettings(tUserId))
          .thenAnswer((_) async => Right(avatarSettings));
      when(mockRepository.getUserSettings('user456'))
          .thenAnswer((_) async => Right(noAvatarSettings));

      // act
      final result1 = await usecase(tUserId);
      final result2 = await usecase('user456');

      // assert
      result1.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings!.avatarUrl,
              'https://cdn.example.com/avatars/user123.png');
        },
      );

      result2.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings!.avatarUrl, null);
        },
      );
    });

    test('doit gérer les paramètres avec dates de création et mise à jour',
        () async {
      // arrange
      final createdDate = DateTime.now().subtract(const Duration(days: 100));
      final updatedDate = DateTime.now().subtract(const Duration(hours: 6));

      final timestampedSettings = UserSettings(
        userId: tUserId,
        displayName: 'Utilisateur avec Timestamps',
        createdAt: createdDate,
        updatedAt: updatedDate,
      );

      when(mockRepository.getUserSettings(tUserId))
          .thenAnswer((_) async => Right(timestampedSettings));

      // act
      final result = await usecase(tUserId);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings!.createdAt, createdDate);
          expect(settings.updatedAt, updatedDate);
          expect(settings.updatedAt!.isAfter(settings.createdAt!), true);
        },
      );
    });

    test('doit déléguer entièrement au repository', () async {
      // arrange
      when(mockRepository.getUserSettings(tUserId))
          .thenAnswer((_) async => Right(tUserSettings));

      // act
      final result = await usecase(tUserId);

      // assert
      expect(result, Right(tUserSettings));
      // Vérifier que l'use case ne fait que déléguer au repository
      verify(mockRepository.getUserSettings(tUserId));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
