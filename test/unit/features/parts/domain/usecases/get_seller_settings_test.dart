import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/domain/entities/seller_settings.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/seller_settings_repository.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/get_seller_settings.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_seller_settings_test.mocks.dart';

@GenerateMocks([SellerSettingsRepository])
void main() {
  late GetSellerSettings usecase;
  late MockSellerSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSellerSettingsRepository();
    usecase = GetSellerSettings(mockRepository);
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
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  );

  group('GetSellerSettings', () {
    test('doit retourner SellerSettings quand les paramètres existent', () async {
      // arrange
      when(mockRepository.getSellerSettings(tSellerId))
          .thenAnswer((_) async => Right(tSellerSettings));

      // act
      final result = await usecase(tSellerId);

      // assert
      expect(result, Right(tSellerSettings));
      verify(mockRepository.getSellerSettings(tSellerId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner null quand les paramètres n\'existent pas', () async {
      // arrange
      when(mockRepository.getSellerSettings(tSellerId))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(tSellerId);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) => expect(settings, null),
      );
      verify(mockRepository.getSellerSettings(tSellerId));
    });

    test('doit retourner AuthFailure quand le vendeur n\'est pas connecté', () async {
      // arrange
      when(mockRepository.getSellerSettings(tSellerId))
          .thenAnswer((_) async => const Left(AuthFailure('Vendeur non connecté')));

      // act
      final result = await usecase(tSellerId);

      // assert
      expect(result, const Left(AuthFailure('Vendeur non connecté')));
      verify(mockRepository.getSellerSettings(tSellerId));
    });

    test('doit retourner ValidationFailure quand le vendeur n\'existe pas', () async {
      // arrange
      when(mockRepository.getSellerSettings(tSellerId))
          .thenAnswer((_) async => const Left(ValidationFailure('Vendeur non trouvé')));

      // act
      final result = await usecase(tSellerId);

      // assert
      expect(result, const Left(ValidationFailure('Vendeur non trouvé')));
      verify(mockRepository.getSellerSettings(tSellerId));
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.getSellerSettings(tSellerId))
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(tSellerId);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRepository.getSellerSettings(tSellerId));
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau', () async {
      // arrange
      when(mockRepository.getSellerSettings(tSellerId))
          .thenAnswer((_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(tSellerId);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.getSellerSettings(tSellerId));
    });

    test('doit appeler le repository avec le bon sellerId', () async {
      // arrange
      when(mockRepository.getSellerSettings(tSellerId))
          .thenAnswer((_) async => Right(tSellerSettings));

      // act
      await usecase(tSellerId);

      // assert
      final captured = verify(mockRepository.getSellerSettings(captureAny)).captured;
      expect(captured.first, tSellerId);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = CacheFailure('Erreur de cache');
      when(mockRepository.getSellerSettings(tSellerId))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(tSellerId);

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions du repository', () async {
      // arrange
      when(mockRepository.getSellerSettings(tSellerId))
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(tSellerId),
        throwsA(isA<Exception>()),
      );
    });

    test('doit retourner les paramètres avec toutes les propriétés correctes', () async {
      // arrange
      when(mockRepository.getSellerSettings(tSellerId))
          .thenAnswer((_) async => Right(tSellerSettings));

      // act
      final result = await usecase(tSellerId);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings, isNotNull);
          expect(settings!.sellerId, tSellerId);
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
          expect(settings.emailVerifiedAt, isNotNull);
          expect(settings.createdAt, isNotNull);
          expect(settings.updatedAt, isNotNull);
        },
      );
    });

    test('doit gérer les paramètres avec informations minimales', () async {
      // arrange
      final minimalSettings = SellerSettings(
        sellerId: tSellerId,
        email: 'minimal@example.com',
        notificationsEnabled: false,
        emailNotificationsEnabled: false,
        isActive: false,
        isVerified: false,
      );

      when(mockRepository.getSellerSettings(tSellerId))
          .thenAnswer((_) async => Right(minimalSettings));

      // act
      final result = await usecase(tSellerId);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings, isNotNull);
          expect(settings!.sellerId, tSellerId);
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
          expect(settings.emailVerifiedAt, null);
          expect(settings.createdAt, null);
          expect(settings.updatedAt, null);
        },
      );
    });

    test('doit gérer les paramètres avec statuts de vérification différents', () async {
      // arrange
      final unverifiedSettings = SellerSettings(
        sellerId: tSellerId,
        email: 'unverified@example.com',
        isVerified: false,
        emailVerifiedAt: null,
        isActive: true,
      );

      final verifiedSettings = SellerSettings(
        sellerId: 'seller456',
        email: 'verified@example.com',
        isVerified: true,
        emailVerifiedAt: DateTime.now().subtract(const Duration(days: 5)),
        isActive: true,
      );

      when(mockRepository.getSellerSettings(tSellerId))
          .thenAnswer((_) async => Right(unverifiedSettings));
      when(mockRepository.getSellerSettings('seller456'))
          .thenAnswer((_) async => Right(verifiedSettings));

      // act
      final result1 = await usecase(tSellerId);
      final result2 = await usecase('seller456');

      // assert
      result1.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings!.isVerified, false);
          expect(settings.emailVerifiedAt, null);
        },
      );

      result2.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings!.isVerified, true);
          expect(settings.emailVerifiedAt, isNotNull);
        },
      );
    });

    test('doit gérer les paramètres avec différents niveaux de notifications', () async {
      // arrange
      final allNotificationsSettings = SellerSettings(
        sellerId: tSellerId,
        email: 'all@example.com',
        notificationsEnabled: true,
        emailNotificationsEnabled: true,
      );

      final partialNotificationsSettings = SellerSettings(
        sellerId: 'seller456',
        email: 'partial@example.com',
        notificationsEnabled: true,
        emailNotificationsEnabled: false,
      );

      final noNotificationsSettings = SellerSettings(
        sellerId: 'seller789',
        email: 'none@example.com',
        notificationsEnabled: false,
        emailNotificationsEnabled: false,
      );

      when(mockRepository.getSellerSettings(tSellerId))
          .thenAnswer((_) async => Right(allNotificationsSettings));
      when(mockRepository.getSellerSettings('seller456'))
          .thenAnswer((_) async => Right(partialNotificationsSettings));
      when(mockRepository.getSellerSettings('seller789'))
          .thenAnswer((_) async => Right(noNotificationsSettings));

      // act
      final result1 = await usecase(tSellerId);
      final result2 = await usecase('seller456');
      final result3 = await usecase('seller789');

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

    test('doit fonctionner avec différents sellerId', () async {
      // arrange
      const seller1Id = 'seller1';
      const seller2Id = 'seller2';

      final settings1 = SellerSettings(sellerId: seller1Id, email: 'seller1@example.com');
      final settings2 = SellerSettings(sellerId: seller2Id, email: 'seller2@example.com');

      when(mockRepository.getSellerSettings(seller1Id))
          .thenAnswer((_) async => Right(settings1));
      when(mockRepository.getSellerSettings(seller2Id))
          .thenAnswer((_) async => Right(settings2));

      // act
      final result1 = await usecase(seller1Id);
      final result2 = await usecase(seller2Id);

      // assert
      expect(result1, Right(settings1));
      expect(result2, Right(settings2));
      verify(mockRepository.getSellerSettings(seller1Id));
      verify(mockRepository.getSellerSettings(seller2Id));
    });

    test('doit retourner les mêmes paramètres à chaque appel (cohérence)', () async {
      // arrange
      when(mockRepository.getSellerSettings(tSellerId))
          .thenAnswer((_) async => Right(tSellerSettings));

      // act
      final result1 = await usecase(tSellerId);
      final result2 = await usecase(tSellerId);

      // assert
      expect(result1, equals(result2));
      verify(mockRepository.getSellerSettings(tSellerId)).called(2);
    });

    test('doit gérer les IDs de vendeur avec différents formats', () async {
      // arrange & act & assert
      final validIds = [
        'seller123',
        'SELLER-456',
        'seller_789',
        '12345',
        'uuid-style-f47ac10b-58cc-4372-a567-0e02b2c3d479',
      ];

      for (final validId in validIds) {
        final settings = SellerSettings(sellerId: validId, email: '$validId@example.com');
        when(mockRepository.getSellerSettings(validId))
            .thenAnswer((_) async => Right(settings));

        final result = await usecase(validId);
        expect(result, Right(settings));
        verify(mockRepository.getSellerSettings(validId));
      }
    });

    test('doit gérer les paramètres avec informations de société complètes', () async {
      // arrange
      final companySettings = SellerSettings(
        sellerId: tSellerId,
        email: 'contact@company.com',
        firstName: 'Jean',
        lastName: 'Directeur',
        companyName: 'Automobile Solutions SARL',
        phone: '+33987654321',
        address: '456 Avenue des Entrepreneurs',
        city: 'Lyon',
        postalCode: '69000',
        siret: '98765432109876',
        avatarUrl: 'https://company.com/logo.png',
        isVerified: true,
        emailVerifiedAt: DateTime.now().subtract(const Duration(days: 10)),
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      when(mockRepository.getSellerSettings(tSellerId))
          .thenAnswer((_) async => Right(companySettings));

      // act
      final result = await usecase(tSellerId);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (settings) {
          expect(settings!.companyName, 'Automobile Solutions SARL');
          expect(settings.siret, '98765432109876');
          expect(settings.address, '456 Avenue des Entrepreneurs');
          expect(settings.city, 'Lyon');
          expect(settings.postalCode, '69000');
          expect(settings.isVerified, true);
        },
      );
    });

    test('doit déléguer entièrement au repository', () async {
      // arrange
      when(mockRepository.getSellerSettings(tSellerId))
          .thenAnswer((_) async => Right(tSellerSettings));

      // act
      final result = await usecase(tSellerId);

      // assert
      expect(result, Right(tSellerSettings));
      // Vérifier que l'use case ne fait que déléguer au repository
      verify(mockRepository.getSellerSettings(tSellerId));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}