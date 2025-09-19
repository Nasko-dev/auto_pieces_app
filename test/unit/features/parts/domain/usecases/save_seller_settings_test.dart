import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/domain/entities/seller_settings.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/seller_settings_repository.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/save_seller_settings.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'save_seller_settings_test.mocks.dart';

@GenerateMocks([SellerSettingsRepository])
void main() {
  late SaveSellerSettings usecase;
  late MockSellerSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSellerSettingsRepository();
    usecase = SaveSellerSettings(mockRepository);
  });

  const tSellerId = 'seller123';

  final tSellerSettings = SellerSettings(
    sellerId: tSellerId,
    email: 'jean.dupont@example.com',
    firstName: 'Jean',
    lastName: 'Dupont',
    companyName: 'Pièces Auto Pro',
    phone: '+33123456789',
    address: '123 Rue de la Paix',
    city: 'Paris',
    postalCode: '75001',
    siret: '12345678901234',
    avatarUrl: 'https://example.com/avatar.jpg',
    notificationsEnabled: true,
    emailNotificationsEnabled: true,
    isActive: true,
    isVerified: true,
    emailVerifiedAt: DateTime.now().subtract(const Duration(days: 30)),
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
    updatedAt: DateTime.now(),
  );

  group('SaveSellerSettings', () {
    test('doit sauvegarder SellerSettings avec succès', () async {
      // arrange
      when(mockRepository.saveSellerSettings(tSellerSettings))
          .thenAnswer((_) async => Right(tSellerSettings));

      // act
      final result = await usecase(tSellerSettings);

      // assert
      expect(result, Right(tSellerSettings));
      verify(mockRepository.saveSellerSettings(tSellerSettings));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner AuthFailure quand le vendeur n\'est pas autorisé', () async {
      // arrange
      when(mockRepository.saveSellerSettings(tSellerSettings))
          .thenAnswer((_) async => const Left(AuthFailure('Vendeur non autorisé')));

      // act
      final result = await usecase(tSellerSettings);

      // assert
      expect(result, const Left(AuthFailure('Vendeur non autorisé')));
      verify(mockRepository.saveSellerSettings(tSellerSettings));
    });

    test('doit retourner ValidationFailure quand les données sont invalides', () async {
      // arrange
      when(mockRepository.saveSellerSettings(tSellerSettings))
          .thenAnswer((_) async => const Left(ValidationFailure('Email invalide')));

      // act
      final result = await usecase(tSellerSettings);

      // assert
      expect(result, const Left(ValidationFailure('Email invalide')));
      verify(mockRepository.saveSellerSettings(tSellerSettings));
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.saveSellerSettings(tSellerSettings))
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(tSellerSettings);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRepository.saveSellerSettings(tSellerSettings));
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau', () async {
      // arrange
      when(mockRepository.saveSellerSettings(tSellerSettings))
          .thenAnswer((_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(tSellerSettings);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.saveSellerSettings(tSellerSettings));
    });

    test('doit appeler le repository avec les bonnes données', () async {
      // arrange
      when(mockRepository.saveSellerSettings(tSellerSettings))
          .thenAnswer((_) async => Right(tSellerSettings));

      // act
      await usecase(tSellerSettings);

      // assert
      final captured = verify(mockRepository.saveSellerSettings(captureAny)).captured;
      expect(captured.first, tSellerSettings);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = CacheFailure('Erreur de cache');
      when(mockRepository.saveSellerSettings(tSellerSettings))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(tSellerSettings);

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions du repository', () async {
      // arrange
      when(mockRepository.saveSellerSettings(tSellerSettings))
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(tSellerSettings),
        throwsA(isA<Exception>()),
      );
    });

    test('doit sauvegarder avec toutes les propriétés correctement transmises', () async {
      // arrange
      when(mockRepository.saveSellerSettings(tSellerSettings))
          .thenAnswer((_) async => Right(tSellerSettings));

      // act
      final result = await usecase(tSellerSettings);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.sellerId, tSellerId);
          expect(settings.email, 'jean.dupont@example.com');
          expect(settings.firstName, 'Jean');
          expect(settings.lastName, 'Dupont');
          expect(settings.companyName, 'Pièces Auto Pro');
          expect(settings.phone, '+33123456789');
          expect(settings.address, '123 Rue de la Paix');
          expect(settings.city, 'Paris');
          expect(settings.postalCode, '75001');
          expect(settings.siret, '12345678901234');
          expect(settings.avatarUrl, 'https://example.com/avatar.jpg');
          expect(settings.notificationsEnabled, true);
          expect(settings.emailNotificationsEnabled, true);
          expect(settings.isActive, true);
          expect(settings.isVerified, true);
        },
      );
    });

    test('doit gérer la sauvegarde avec informations minimales', () async {
      // arrange
      final minimalSettings = SellerSettings(
        sellerId: tSellerId,
        email: 'minimal@example.com',
        notificationsEnabled: false,
        emailNotificationsEnabled: false,
        isActive: false,
        isVerified: false,
      );

      when(mockRepository.saveSellerSettings(minimalSettings))
          .thenAnswer((_) async => Right(minimalSettings));

      // act
      final result = await usecase(minimalSettings);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.sellerId, tSellerId);
          expect(settings.email, 'minimal@example.com');
          expect(settings.firstName, null);
          expect(settings.lastName, null);
          expect(settings.companyName, null);
          expect(settings.phone, null);
          expect(settings.address, null);
          expect(settings.city, null);
          expect(settings.postalCode, null);
          expect(settings.siret, null);
          expect(settings.avatarUrl, null);
          expect(settings.notificationsEnabled, false);
          expect(settings.emailNotificationsEnabled, false);
          expect(settings.isActive, false);
          expect(settings.isVerified, false);
        },
      );
    });

    test('doit gérer la mise à jour des préférences de notifications', () async {
      // arrange
      final updatedSettings = tSellerSettings.copyWith(
        notificationsEnabled: false,
        emailNotificationsEnabled: false,
      );

      when(mockRepository.saveSellerSettings(updatedSettings))
          .thenAnswer((_) async => Right(updatedSettings));

      // act
      final result = await usecase(updatedSettings);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.notificationsEnabled, false);
          expect(settings.emailNotificationsEnabled, false);
          expect(settings.sellerId, tSellerId);
        },
      );
    });

    test('doit gérer la mise à jour du statut de vérification', () async {
      // arrange
      final verifiedSettings = tSellerSettings.copyWith(
        isVerified: true,
        emailVerifiedAt: DateTime.now(),
      );

      when(mockRepository.saveSellerSettings(verifiedSettings))
          .thenAnswer((_) async => Right(verifiedSettings));

      // act
      final result = await usecase(verifiedSettings);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.isVerified, true);
          expect(settings.emailVerifiedAt, isNotNull);
        },
      );
    });

    test('doit gérer la mise à jour des informations de la société', () async {
      // arrange
      final companySettings = tSellerSettings.copyWith(
        companyName: 'Nouvelle Société Auto',
        siret: '98765432109876',
        address: '456 Avenue des Entrepreneurs',
        city: 'Lyon',
        postalCode: '69000',
      );

      when(mockRepository.saveSellerSettings(companySettings))
          .thenAnswer((_) async => Right(companySettings));

      // act
      final result = await usecase(companySettings);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.companyName, 'Nouvelle Société Auto');
          expect(settings.siret, '98765432109876');
          expect(settings.address, '456 Avenue des Entrepreneurs');
          expect(settings.city, 'Lyon');
          expect(settings.postalCode, '69000');
        },
      );
    });

    test('doit fonctionner avec différents vendeurs', () async {
      // arrange
      const seller1Id = 'seller1';
      const seller2Id = 'seller2';

      final settings1 = SellerSettings(sellerId: seller1Id, email: 'seller1@example.com');
      final settings2 = SellerSettings(sellerId: seller2Id, email: 'seller2@example.com');

      when(mockRepository.saveSellerSettings(settings1))
          .thenAnswer((_) async => Right(settings1));
      when(mockRepository.saveSellerSettings(settings2))
          .thenAnswer((_) async => Right(settings2));

      // act
      final result1 = await usecase(settings1);
      final result2 = await usecase(settings2);

      // assert
      expect(result1, Right(settings1));
      expect(result2, Right(settings2));
      verify(mockRepository.saveSellerSettings(settings1));
      verify(mockRepository.saveSellerSettings(settings2));
    });

    test('doit gérer la mise à jour de l\'avatar', () async {
      // arrange
      final updatedSettings = tSellerSettings.copyWith(
        avatarUrl: 'https://newcdn.example.com/avatars/new_photo.jpg',
      );

      when(mockRepository.saveSellerSettings(updatedSettings))
          .thenAnswer((_) async => Right(updatedSettings));

      // act
      final result = await usecase(updatedSettings);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.avatarUrl, 'https://newcdn.example.com/avatars/new_photo.jpg');
        },
      );
    });

    test('doit gérer la suppression de l\'avatar', () async {
      // arrange
      final settingsWithoutAvatar = tSellerSettings.copyWith(
        avatarUrl: null,
      );

      when(mockRepository.saveSellerSettings(settingsWithoutAvatar))
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

    test('doit gérer la mise à jour du statut actif', () async {
      // arrange
      final inactiveSettings = tSellerSettings.copyWith(
        isActive: false,
      );

      when(mockRepository.saveSellerSettings(inactiveSettings))
          .thenAnswer((_) async => Right(inactiveSettings));

      // act
      final result = await usecase(inactiveSettings);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings.isActive, false);
        },
      );
    });

    test('doit gérer les timestamps de création et mise à jour', () async {
      // arrange
      final now = DateTime.now();
      final timestampedSettings = tSellerSettings.copyWith(
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now,
      );

      when(mockRepository.saveSellerSettings(timestampedSettings))
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

    test('doit déléguer entièrement au repository', () async {
      // arrange
      when(mockRepository.saveSellerSettings(tSellerSettings))
          .thenAnswer((_) async => Right(tSellerSettings));

      // act
      final result = await usecase(tSellerSettings);

      // assert
      expect(result, Right(tSellerSettings));
      // Vérifier que l'use case ne fait que déléguer au repository
      verify(mockRepository.saveSellerSettings(tSellerSettings));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}