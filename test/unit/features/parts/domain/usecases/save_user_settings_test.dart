import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/domain/entities/user_settings.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/user_settings_repository.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/save_user_settings.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'save_user_settings_test.mocks.dart';

@GenerateMocks([UserSettingsRepository])
void main() {
  late SaveUserSettings usecase;
  late MockUserSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockUserSettingsRepository();
    usecase = SaveUserSettings(mockRepository);
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
    updatedAt: DateTime.now(),
  );

  group('SaveUserSettings', () {
    test('doit sauvegarder UserSettings avec succès', () async {
      // arrange
      when(mockRepository.saveUserSettings(tUserSettings))
          .thenAnswer((_) async => Right(tUserSettings));

      // act
      final result = await usecase(tUserSettings);

      // assert
      expect(result, Right(tUserSettings));
      verify(mockRepository.saveUserSettings(tUserSettings));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner AuthFailure quand l\'utilisateur n\'est pas autorisé',
        () async {
      // arrange
      when(mockRepository.saveUserSettings(tUserSettings)).thenAnswer(
          (_) async => const Left(AuthFailure('Utilisateur non autorisé')));

      // act
      final result = await usecase(tUserSettings);

      // assert
      expect(result, const Left(AuthFailure('Utilisateur non autorisé')));
      verify(mockRepository.saveUserSettings(tUserSettings));
    });

    test('doit retourner ValidationFailure quand les données sont invalides',
        () async {
      // arrange
      when(mockRepository.saveUserSettings(tUserSettings)).thenAnswer(
          (_) async =>
              const Left(ValidationFailure('Nom d\'affichage invalide')));

      // act
      final result = await usecase(tUserSettings);

      // assert
      expect(
          result, const Left(ValidationFailure('Nom d\'affichage invalide')));
      verify(mockRepository.saveUserSettings(tUserSettings));
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.saveUserSettings(tUserSettings))
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(tUserSettings);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRepository.saveUserSettings(tUserSettings));
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau',
        () async {
      // arrange
      when(mockRepository.saveUserSettings(tUserSettings)).thenAnswer(
          (_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(tUserSettings);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.saveUserSettings(tUserSettings));
    });

    test('doit appeler le repository avec les bonnes données', () async {
      // arrange
      when(mockRepository.saveUserSettings(tUserSettings))
          .thenAnswer((_) async => Right(tUserSettings));

      // act
      await usecase(tUserSettings);

      // assert
      final captured =
          verify(mockRepository.saveUserSettings(captureAny)).captured;
      expect(captured.first, tUserSettings);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = CacheFailure('Erreur de cache');
      when(mockRepository.saveUserSettings(tUserSettings))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(tUserSettings);

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions du repository', () async {
      // arrange
      when(mockRepository.saveUserSettings(tUserSettings))
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(tUserSettings),
        throwsA(isA<Exception>()),
      );
    });

    test('doit sauvegarder avec toutes les propriétés correctement transmises',
        () async {
      // arrange
      when(mockRepository.saveUserSettings(tUserSettings))
          .thenAnswer((_) async => Right(tUserSettings));

      // act
      final result = await usecase(tUserSettings);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.userId, tUserId);
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

    test('doit gérer la sauvegarde avec informations minimales', () async {
      // arrange
      final minimalSettings = UserSettings(
        userId: tUserId,
        notificationsEnabled: false,
        emailNotificationsEnabled: false,
      );

      when(mockRepository.saveUserSettings(minimalSettings))
          .thenAnswer((_) async => Right(minimalSettings));

      // act
      final result = await usecase(minimalSettings);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.userId, tUserId);
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

    test('doit gérer la mise à jour des préférences de notifications',
        () async {
      // arrange
      final updatedSettings = tUserSettings.copyWith(
        notificationsEnabled: false,
        emailNotificationsEnabled: false,
      );

      when(mockRepository.saveUserSettings(updatedSettings))
          .thenAnswer((_) async => Right(updatedSettings));

      // act
      final result = await usecase(updatedSettings);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.notificationsEnabled, false);
          expect(settings.emailNotificationsEnabled, false);
          expect(settings.userId, tUserId);
        },
      );
    });

    test('doit gérer la mise à jour de l\'adresse complète', () async {
      // arrange
      final addressSettings = tUserSettings.copyWith(
        address: '123 Rue de la Liberté, Apt 5B',
        city: 'Marseille',
        postalCode: '13001',
        country: 'France',
      );

      when(mockRepository.saveUserSettings(addressSettings))
          .thenAnswer((_) async => Right(addressSettings));

      // act
      final result = await usecase(addressSettings);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.address, '123 Rue de la Liberté, Apt 5B');
          expect(settings.city, 'Marseille');
          expect(settings.postalCode, '13001');
          expect(settings.country, 'France');
        },
      );
    });

    test('doit gérer différents pays', () async {
      // arrange
      final belgianSettings = tUserSettings.copyWith(
        country: 'Belgique',
        city: 'Bruxelles',
      );

      final swissSettings = tUserSettings.copyWith(
        country: 'Suisse',
        city: 'Genève',
      );

      when(mockRepository.saveUserSettings(belgianSettings))
          .thenAnswer((_) async => Right(belgianSettings));
      when(mockRepository.saveUserSettings(swissSettings))
          .thenAnswer((_) async => Right(swissSettings));

      // act
      final result1 = await usecase(belgianSettings);
      final result2 = await usecase(swissSettings);

      // assert
      result1.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.country, 'Belgique');
          expect(settings.city, 'Bruxelles');
        },
      );

      result2.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.country, 'Suisse');
          expect(settings.city, 'Genève');
        },
      );
    });

    test('doit fonctionner avec différents utilisateurs', () async {
      // arrange
      const user1Id = 'user1';
      const user2Id = 'user2';

      final settings1 =
          UserSettings(userId: user1Id, displayName: 'Utilisateur 1');
      final settings2 =
          UserSettings(userId: user2Id, displayName: 'Utilisateur 2');

      when(mockRepository.saveUserSettings(settings1))
          .thenAnswer((_) async => Right(settings1));
      when(mockRepository.saveUserSettings(settings2))
          .thenAnswer((_) async => Right(settings2));

      // act
      final result1 = await usecase(settings1);
      final result2 = await usecase(settings2);

      // assert
      expect(result1, Right(settings1));
      expect(result2, Right(settings2));
      verify(mockRepository.saveUserSettings(settings1));
      verify(mockRepository.saveUserSettings(settings2));
    });

    test('doit gérer la mise à jour de l\'avatar', () async {
      // arrange
      final updatedSettings = tUserSettings.copyWith(
        avatarUrl: 'https://newcdn.example.com/avatars/new_photo.jpg',
      );

      when(mockRepository.saveUserSettings(updatedSettings))
          .thenAnswer((_) async => Right(updatedSettings));

      // act
      final result = await usecase(updatedSettings);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.avatarUrl,
              'https://newcdn.example.com/avatars/new_photo.jpg');
        },
      );
    });

    test('doit gérer la suppression de l\'avatar', () async {
      // arrange
      final settingsWithoutAvatar = tUserSettings.copyWith(
        avatarUrl: null,
      );

      when(mockRepository.saveUserSettings(settingsWithoutAvatar))
          .thenAnswer((_) async => Right(settingsWithoutAvatar));

      // act
      final result = await usecase(settingsWithoutAvatar);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.avatarUrl, null);
        },
      );
    });

    test('doit gérer la mise à jour du nom d\'affichage', () async {
      // arrange
      final updatedSettings = tUserSettings.copyWith(
        displayName: 'Nouveau Nom',
      );

      when(mockRepository.saveUserSettings(updatedSettings))
          .thenAnswer((_) async => Right(updatedSettings));

      // act
      final result = await usecase(updatedSettings);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.displayName, 'Nouveau Nom');
        },
      );
    });

    test('doit gérer la mise à jour du numéro de téléphone', () async {
      // arrange
      final updatedSettings = tUserSettings.copyWith(
        phone: '+33612345678',
      );

      when(mockRepository.saveUserSettings(updatedSettings))
          .thenAnswer((_) async => Right(updatedSettings));

      // act
      final result = await usecase(updatedSettings);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.phone, '+33612345678');
        },
      );
    });

    test('doit gérer la suppression du numéro de téléphone', () async {
      // arrange
      final settingsWithoutPhone = tUserSettings.copyWith(
        phone: null,
      );

      when(mockRepository.saveUserSettings(settingsWithoutPhone))
          .thenAnswer((_) async => Right(settingsWithoutPhone));

      // act
      final result = await usecase(settingsWithoutPhone);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.phone, null);
        },
      );
    });

    test('doit gérer les timestamps de création et mise à jour', () async {
      // arrange
      final now = DateTime.now();
      final timestampedSettings = tUserSettings.copyWith(
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now,
      );

      when(mockRepository.saveUserSettings(timestampedSettings))
          .thenAnswer((_) async => Right(timestampedSettings));

      // act
      final result = await usecase(timestampedSettings);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.createdAt, isNotNull);
          expect(settings.updatedAt, isNotNull);
          expect(settings.updatedAt!.isAfter(settings.createdAt!), true);
        },
      );
    });

    test('doit gérer les paramètres avec seulement userId requis', () async {
      // arrange
      final basicSettings = UserSettings(
        userId: tUserId,
      );

      when(mockRepository.saveUserSettings(basicSettings))
          .thenAnswer((_) async => Right(basicSettings));

      // act
      final result = await usecase(basicSettings);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.userId, tUserId);
          expect(settings.country, 'France'); // Valeur par défaut
          expect(settings.notificationsEnabled, true); // Valeur par défaut
          expect(settings.emailNotificationsEnabled, true); // Valeur par défaut
        },
      );
    });

    test('doit déléguer entièrement au repository', () async {
      // arrange
      when(mockRepository.saveUserSettings(tUserSettings))
          .thenAnswer((_) async => Right(tUserSettings));

      // act
      final result = await usecase(tUserSettings);

      // assert
      expect(result, Right(tUserSettings));
      // Vérifier que l'use case ne fait que déléguer au repository
      verify(mockRepository.saveUserSettings(tUserSettings));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
