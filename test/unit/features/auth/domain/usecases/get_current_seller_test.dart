import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/core/usecases/usecase.dart';
import 'package:cente_pice/src/features/auth/domain/entities/seller.dart';
import 'package:cente_pice/src/features/auth/domain/repositories/seller_auth_repository.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/get_current_seller.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_current_seller_test.mocks.dart';

@GenerateMocks([SellerAuthRepository])
void main() {
  late GetCurrentSeller usecase;
  late MockSellerAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockSellerAuthRepository();
    usecase = GetCurrentSeller(mockRepository);
  });

  final tSeller = Seller(
    id: '1',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    phone: '+33123456789',
    companyName: 'Test Company',
    siret: '12345678901234',
    address: 'Test Address',
    zipCode: '75001',
    city: 'Paris',
    createdAt: DateTime.now(),
    isActive: true,
  );

  group('GetCurrentSeller', () {
    test('doit retourner un Seller quand l\'utilisateur est connecté', () async {
      // arrange
      when(mockRepository.getCurrentSeller())
          .thenAnswer((_) async => Right(tSeller));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, Right(tSeller));
      verify(mockRepository.getCurrentSeller());
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner AuthFailure quand l\'utilisateur n\'est pas connecté', () async {
      // arrange
      when(mockRepository.getCurrentSeller())
          .thenAnswer((_) async => const Left(AuthFailure('Non authentifié')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(AuthFailure('Non authentifié')));
      verify(mockRepository.getCurrentSeller());
    });

    test('doit retourner AuthFailure quand le token est expiré', () async {
      // arrange
      when(mockRepository.getCurrentSeller())
          .thenAnswer((_) async => const Left(AuthFailure('Token expiré')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(AuthFailure('Token expiré')));
      verify(mockRepository.getCurrentSeller());
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau', () async {
      // arrange
      when(mockRepository.getCurrentSeller())
          .thenAnswer((_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.getCurrentSeller());
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.getCurrentSeller())
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRepository.getCurrentSeller());
    });

    test('doit retourner CacheFailure en cas d\'erreur de cache', () async {
      // arrange
      when(mockRepository.getCurrentSeller())
          .thenAnswer((_) async => const Left(CacheFailure('Erreur de cache')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(CacheFailure('Erreur de cache')));
      verify(mockRepository.getCurrentSeller());
    });

    test('doit appeler le repository une seule fois', () async {
      // arrange
      when(mockRepository.getCurrentSeller())
          .thenAnswer((_) async => Right(tSeller));

      // act
      await usecase(NoParams());

      // assert
      verify(mockRepository.getCurrentSeller()).called(1);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = ValidationFailure('Données invalides');
      when(mockRepository.getCurrentSeller())
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions imprévues du repository', () async {
      // arrange
      when(mockRepository.getCurrentSeller())
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(NoParams()),
        throwsA(isA<Exception>()),
      );
    });

    test('doit retourner le même vendeur à chaque appel (cohérence)', () async {
      // arrange
      when(mockRepository.getCurrentSeller())
          .thenAnswer((_) async => Right(tSeller));

      // act
      final result1 = await usecase(NoParams());
      final result2 = await usecase(NoParams());

      // assert
      expect(result1, equals(result2));
      verify(mockRepository.getCurrentSeller()).called(2);
    });

    test('doit retourner un vendeur avec toutes les propriétés correctes', () async {
      // arrange
      when(mockRepository.getCurrentSeller())
          .thenAnswer((_) async => Right(tSeller));

      // act
      final result = await usecase(NoParams());

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (seller) {
          expect(seller.id, tSeller.id);
          expect(seller.email, tSeller.email);
          expect(seller.firstName, tSeller.firstName);
          expect(seller.lastName, tSeller.lastName);
          expect(seller.companyName, tSeller.companyName);
          expect(seller.phone, tSeller.phone);
          expect(seller.isActive, tSeller.isActive);
        },
      );
    });
  });
}