import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/auth/domain/entities/particulier.dart';
import 'package:cente_pice/src/features/auth/domain/repositories/particulier_auth_repository.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/update_particulier.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'update_particulier_test.mocks.dart';

@GenerateMocks([ParticulierAuthRepository])
void main() {
  late UpdateParticulier usecase;
  late MockParticulierAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockParticulierAuthRepository();
    usecase = UpdateParticulier(mockRepository);
  });

  final tParticulier = Particulier(
    id: '1',
    email: 'particulier@example.com',
    firstName: 'Jean',
    lastName: 'Dupont',
    phone: '+33123456789',
    address: '123 Rue de la Paix',
    zipCode: '75001',
    city: 'Paris',
    createdAt: DateTime.now(),
    isActive: true,
  );

  final tUpdatedParticulier = Particulier(
    id: '1',
    email: 'nouveau.particulier@example.com',
    firstName: 'Jean-Claude',
    lastName: 'Dupont-Moreau',
    phone: '+33987654321',
    address: '456 Avenue des Champs',
    zipCode: '75008',
    city: 'Paris',
    createdAt: tParticulier.createdAt,
    isActive: true,
  );

  group('UpdateParticulier', () {
    test('doit retourner un Particulier mis à jour quand la mise à jour réussit', () async {
      // arrange
      when(mockRepository.updateParticulier(tParticulier))
          .thenAnswer((_) async => Right(tUpdatedParticulier));

      // act
      final result = await usecase(tParticulier);

      // assert
      expect(result, Right(tUpdatedParticulier));
      verify(mockRepository.updateParticulier(tParticulier));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner ServerFailure quand la mise à jour échoue côté serveur', () async {
      // arrange
      when(mockRepository.updateParticulier(tParticulier))
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(tParticulier);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRepository.updateParticulier(tParticulier));
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau', () async {
      // arrange
      when(mockRepository.updateParticulier(tParticulier))
          .thenAnswer((_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(tParticulier);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.updateParticulier(tParticulier));
    });

    test('doit retourner AuthFailure quand l\'utilisateur n\'est pas autorisé', () async {
      // arrange
      when(mockRepository.updateParticulier(tParticulier))
          .thenAnswer((_) async => const Left(AuthFailure('Non autorisé')));

      // act
      final result = await usecase(tParticulier);

      // assert
      expect(result, const Left(AuthFailure('Non autorisé')));
      verify(mockRepository.updateParticulier(tParticulier));
    });

    test('doit retourner ValidationFailure pour des données invalides', () async {
      // arrange
      final invalidParticulier = Particulier(
        id: '1',
        email: 'email_invalide',
        firstName: '',
        lastName: '',
        phone: 'téléphone_invalide',
        address: '',
        zipCode: 'code_postal_invalide',
        city: '',
        createdAt: DateTime.now(),
        isActive: true,
      );

      when(mockRepository.updateParticulier(invalidParticulier))
          .thenAnswer((_) async => const Left(ValidationFailure('Données invalides')));

      // act
      final result = await usecase(invalidParticulier);

      // assert
      expect(result, const Left(ValidationFailure('Données invalides')));
      verify(mockRepository.updateParticulier(invalidParticulier));
    });

    test('doit retourner CacheFailure si la mise en cache échoue', () async {
      // arrange
      when(mockRepository.updateParticulier(tParticulier))
          .thenAnswer((_) async => const Left(CacheFailure('Erreur de cache')));

      // act
      final result = await usecase(tParticulier);

      // assert
      expect(result, const Left(CacheFailure('Erreur de cache')));
      verify(mockRepository.updateParticulier(tParticulier));
    });

    test('doit appeler le repository une seule fois', () async {
      // arrange
      when(mockRepository.updateParticulier(tParticulier))
          .thenAnswer((_) async => Right(tUpdatedParticulier));

      // act
      await usecase(tParticulier);

      // assert
      verify(mockRepository.updateParticulier(tParticulier)).called(1);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = ServerFailure('Erreur de serveur');
      when(mockRepository.updateParticulier(tParticulier))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(tParticulier);

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions imprévues du repository', () async {
      // arrange
      when(mockRepository.updateParticulier(tParticulier))
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(tParticulier),
        throwsA(isA<Exception>()),
      );
    });

    test('doit mettre à jour toutes les propriétés du particulier', () async {
      // arrange
      when(mockRepository.updateParticulier(tParticulier))
          .thenAnswer((_) async => Right(tUpdatedParticulier));

      // act
      final result = await usecase(tParticulier);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (particulier) {
          expect(particulier.id, tUpdatedParticulier.id);
          expect(particulier.email, tUpdatedParticulier.email);
          expect(particulier.firstName, tUpdatedParticulier.firstName);
          expect(particulier.lastName, tUpdatedParticulier.lastName);
          expect(particulier.phone, tUpdatedParticulier.phone);
          expect(particulier.address, tUpdatedParticulier.address);
          expect(particulier.zipCode, tUpdatedParticulier.zipCode);
          expect(particulier.city, tUpdatedParticulier.city);
          expect(particulier.isActive, tUpdatedParticulier.isActive);
        },
      );
    });

    test('doit préserver l\'ID et la date de création lors de la mise à jour', () async {
      // arrange
      when(mockRepository.updateParticulier(tParticulier))
          .thenAnswer((_) async => Right(tUpdatedParticulier));

      // act
      final result = await usecase(tParticulier);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (particulier) {
          expect(particulier.id, tParticulier.id);
          expect(particulier.createdAt, tParticulier.createdAt);
        },
      );
    });

    test('doit gérer la mise à jour d\'un particulier inactif', () async {
      // arrange
      final inactiveParticulier = Particulier(
        id: '2',
        email: 'inactive@example.com',
        firstName: 'Inactive',
        lastName: 'User',
        phone: '+33555666777',
        address: 'Old Address',
        zipCode: '69000',
        city: 'Lyon',
        createdAt: DateTime.now(),
        isActive: false,
      );

      when(mockRepository.updateParticulier(inactiveParticulier))
          .thenAnswer((_) async => Right(inactiveParticulier));

      // act
      final result = await usecase(inactiveParticulier);

      // assert
      expect(result, Right(inactiveParticulier));
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (particulier) => expect(particulier.isActive, false),
      );
    });

    test('doit gérer la mise à jour avec des champs optionnels vides', () async {
      // arrange
      final particulierChampVides = Particulier(
        id: '3',
        email: 'minimal@example.com',
        firstName: 'Min',
        lastName: 'User',
        phone: '',
        address: '',
        zipCode: '',
        city: '',
        createdAt: DateTime.now(),
        isActive: true,
      );

      when(mockRepository.updateParticulier(particulierChampVides))
          .thenAnswer((_) async => Right(particulierChampVides));

      // act
      final result = await usecase(particulierChampVides);

      // assert
      expect(result, Right(particulierChampVides));
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (particulier) {
          expect(particulier.phone, '');
          expect(particulier.address, '');
          expect(particulier.zipCode, '');
          expect(particulier.city, '');
        },
      );
    });

    test('doit appeler le repository avec le bon particulier en paramètre', () async {
      // arrange
      when(mockRepository.updateParticulier(tParticulier))
          .thenAnswer((_) async => Right(tUpdatedParticulier));

      // act
      await usecase(tParticulier);

      // assert
      final captured = verify(mockRepository.updateParticulier(captureAny)).captured;
      expect(captured.first, tParticulier);
    });

    test('doit fonctionner avec des mises à jour multiples', () async {
      // arrange
      final autreParticulier = Particulier(
        id: '4',
        email: 'autre@example.com',
        firstName: 'Autre',
        lastName: 'Utilisateur',
        phone: '+33111222333',
        address: 'Autre Adresse',
        zipCode: '13000',
        city: 'Marseille',
        createdAt: DateTime.now(),
        isActive: true,
      );

      when(mockRepository.updateParticulier(tParticulier))
          .thenAnswer((_) async => Right(tUpdatedParticulier));
      when(mockRepository.updateParticulier(autreParticulier))
          .thenAnswer((_) async => Right(autreParticulier));

      // act
      final result1 = await usecase(tParticulier);
      final result2 = await usecase(autreParticulier);

      // assert
      expect(result1, Right(tUpdatedParticulier));
      expect(result2, Right(autreParticulier));
      verify(mockRepository.updateParticulier(tParticulier));
      verify(mockRepository.updateParticulier(autreParticulier));
    });
  });
}