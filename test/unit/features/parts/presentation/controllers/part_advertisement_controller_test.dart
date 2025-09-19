import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/domain/entities/part_advertisement.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/part_advertisement_repository.dart';
import 'package:cente_pice/src/features/parts/data/models/part_advertisement_model.dart';
import 'package:cente_pice/src/features/parts/presentation/controllers/part_advertisement_controller.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'part_advertisement_controller_test.mocks.dart';

@GenerateMocks([PartAdvertisementRepository])
void main() {
  late PartAdvertisementController controller;
  late MockPartAdvertisementRepository mockRepository;

  setUp(() {
    mockRepository = MockPartAdvertisementRepository();
    controller = PartAdvertisementController(mockRepository);
  });

  tearDown(() {
    controller.dispose();
  });

  final tPartAdvertisement = PartAdvertisement(
    id: '1',
    userId: 'seller1',
    partType: 'moteur',
    partName: 'moteur',
    vehicleBrand: 'Peugeot',
    vehicleModel: '308',
    vehicleYear: 2018,
    description: 'Moteur en parfait état',
    price: 1500.0,
    condition: 'bon',
    status: 'active',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tPartAdvertisementsList = [tPartAdvertisement];

  final tCreateParams = CreatePartAdvertisementParams(
    partType: 'moteur',
    partName: 'moteur',
    vehicleBrand: 'Peugeot',
    vehicleModel: '308',
    vehicleYear: 2018,
    description: 'Moteur en parfait état',
    price: 1500.0,
    condition: 'bon',
  );

  final tSearchParams = SearchPartAdvertisementsParams(
    partType: 'moteur',
    query: 'Peugeot',
  );

  group('PartAdvertisementController', () {
    test('doit avoir l\'état initial correct', () {
      expect(controller.state.isLoading, false);
      expect(controller.state.isCreating, false);
      expect(controller.state.isUpdating, false);
      expect(controller.state.isDeleting, false);
      expect(controller.state.error, null);
      expect(controller.state.currentAdvertisement, null);
      expect(controller.state.advertisements, isEmpty);
    });

    group('createPartAdvertisement', () {
      test('doit créer une annonce avec succès', () async {
        // arrange
        when(mockRepository.createPartAdvertisement(tCreateParams))
            .thenAnswer((_) async => Right(tPartAdvertisement));
        when(mockRepository.getMyPartAdvertisements())
            .thenAnswer((_) async => Right(tPartAdvertisementsList));

        // act
        final result = await controller.createPartAdvertisement(tCreateParams);

        // assert
        expect(result, true);
        expect(controller.state.isCreating, false);
        expect(controller.state.currentAdvertisement, tPartAdvertisement);
        expect(controller.state.error, null);
      });

      test('doit gérer les erreurs lors de la création', () async {
        // arrange
        const failure = ServerFailure('Erreur serveur');
        when(mockRepository.createPartAdvertisement(tCreateParams))
            .thenAnswer((_) async => const Left(failure));

        // act
        final result = await controller.createPartAdvertisement(tCreateParams);

        // assert
        expect(result, false);
        expect(controller.state.isCreating, false);
        expect(controller.state.currentAdvertisement, null);
        expect(controller.state.error, failure.message);
      });

      test('doit passer par l\'état creating pendant la création', () async {
        // arrange
        when(mockRepository.createPartAdvertisement(tCreateParams))
            .thenAnswer((_) async => Right(tPartAdvertisement));
        when(mockRepository.getMyPartAdvertisements())
            .thenAnswer((_) async => Right(tPartAdvertisementsList));

        // act
        final future = controller.createPartAdvertisement(tCreateParams);

        // assert - état pendant l'opération
        expect(controller.state.isCreating, true);

        await future;

        // assert - état après l'opération
        expect(controller.state.isCreating, false);
      });

      test('doit gérer les exceptions', () async {
        // arrange
        when(mockRepository.createPartAdvertisement(tCreateParams))
            .thenThrow(Exception('Exception inattendue'));

        // act
        final result = await controller.createPartAdvertisement(tCreateParams);

        // assert
        expect(result, false);
        expect(controller.state.isCreating, false);
        expect(controller.state.error, 'Erreur inattendue: Exception: Exception inattendue');
      });
    });

    group('getAdvertisementById', () {
      test('doit récupérer une annonce par ID avec succès', () async {
        // arrange
        when(mockRepository.getPartAdvertisementById('1'))
            .thenAnswer((_) async => Right(tPartAdvertisement));

        // act
        await controller.getAdvertisementById('1');

        // assert
        expect(controller.state.isLoading, false);
        expect(controller.state.currentAdvertisement, tPartAdvertisement);
        expect(controller.state.error, null);
      });

      test('doit gérer les erreurs lors de la récupération', () async {
        // arrange
        const failure = ServerFailure('Annonce non trouvée');
        when(mockRepository.getPartAdvertisementById('1'))
            .thenAnswer((_) async => const Left(failure));

        // act
        await controller.getAdvertisementById('1');

        // assert
        expect(controller.state.isLoading, false);
        expect(controller.state.currentAdvertisement, null);
        expect(controller.state.error, failure.message);
      });

      test('doit passer par l\'état loading pendant la récupération', () async {
        // arrange
        when(mockRepository.getPartAdvertisementById('1'))
            .thenAnswer((_) async => Right(tPartAdvertisement));

        // act
        final future = controller.getAdvertisementById('1');

        // assert - état pendant l'opération
        expect(controller.state.isLoading, true);

        await future;

        // assert - état après l'opération
        expect(controller.state.isLoading, false);
      });

      test('doit gérer les exceptions', () async {
        // arrange
        when(mockRepository.getPartAdvertisementById('1'))
            .thenThrow(Exception('Exception inattendue'));

        // act
        await controller.getAdvertisementById('1');

        // assert
        expect(controller.state.isLoading, false);
        expect(controller.state.error, 'Erreur inattendue: Exception: Exception inattendue');
      });
    });

    group('getMyAdvertisements', () {
      test('doit récupérer mes annonces avec succès', () async {
        // arrange
        when(mockRepository.getMyPartAdvertisements())
            .thenAnswer((_) async => Right(tPartAdvertisementsList));

        // act
        await controller.getMyAdvertisements();

        // assert
        expect(controller.state.isLoading, false);
        expect(controller.state.advertisements.length, 1);
        expect(controller.state.advertisements.first.id, tPartAdvertisement.id);
        expect(controller.state.error, null);
      });

      test('doit gérer les erreurs lors de la récupération', () async {
        // arrange
        const failure = AuthFailure('Non authentifié');
        when(mockRepository.getMyPartAdvertisements())
            .thenAnswer((_) async => const Left(failure));

        // act
        await controller.getMyAdvertisements();

        // assert
        expect(controller.state.isLoading, false);
        expect(controller.state.advertisements, isEmpty);
        expect(controller.state.error, failure.message);
      });

      test('doit passer par l\'état loading pendant la récupération', () async {
        // arrange
        when(mockRepository.getMyPartAdvertisements())
            .thenAnswer((_) async => Right(tPartAdvertisementsList));

        // act
        final future = controller.getMyAdvertisements();

        // assert - état pendant l'opération
        expect(controller.state.isLoading, true);

        await future;

        // assert - état après l'opération
        expect(controller.state.isLoading, false);
      });

      test('doit gérer les exceptions', () async {
        // arrange
        when(mockRepository.getMyPartAdvertisements())
            .thenThrow(Exception('Exception inattendue'));

        // act
        await controller.getMyAdvertisements();

        // assert
        expect(controller.state.isLoading, false);
        expect(controller.state.error, 'Erreur inattendue: Exception: Exception inattendue');
      });
    });

    group('searchAdvertisements', () {
      test('doit rechercher des annonces avec succès', () async {
        // arrange
        when(mockRepository.searchPartAdvertisements(tSearchParams))
            .thenAnswer((_) async => Right(tPartAdvertisementsList));

        // act
        final result = await controller.searchAdvertisements(tSearchParams);

        // assert
        expect(result.length, 1);
        expect(result.first.id, tPartAdvertisement.id);
        expect(controller.state.isLoading, false);
        expect(controller.state.error, null);
      });

      test('doit retourner une liste vide en cas d\'erreur', () async {
        // arrange
        const failure = ServerFailure('Erreur de recherche');
        when(mockRepository.searchPartAdvertisements(tSearchParams))
            .thenAnswer((_) async => const Left(failure));

        // act
        final result = await controller.searchAdvertisements(tSearchParams);

        // assert
        expect(result, isEmpty);
        expect(controller.state.isLoading, false);
        expect(controller.state.error, failure.message);
      });

      test('doit passer par l\'état loading pendant la recherche', () async {
        // arrange
        when(mockRepository.searchPartAdvertisements(tSearchParams))
            .thenAnswer((_) async => Right(tPartAdvertisementsList));

        // act
        final future = controller.searchAdvertisements(tSearchParams);

        // assert - état pendant l'opération
        expect(controller.state.isLoading, true);

        await future;

        // assert - état après l'opération
        expect(controller.state.isLoading, false);
      });

      test('doit gérer les exceptions', () async {
        // arrange
        when(mockRepository.searchPartAdvertisements(tSearchParams))
            .thenThrow(Exception('Exception inattendue'));

        // act
        final result = await controller.searchAdvertisements(tSearchParams);

        // assert
        expect(result, isEmpty);
        expect(controller.state.isLoading, false);
        expect(controller.state.error, 'Erreur inattendue: Exception: Exception inattendue');
      });
    });

    group('updateAdvertisement', () {
      final updates = {'price': 1800.0, 'description': 'Description mise à jour'};
      final updatedAdvertisement = tPartAdvertisement.copyWith(
        price: 1800.0,
        description: 'Description mise à jour',
      );

      test('doit mettre à jour une annonce avec succès', () async {
        // arrange
        when(mockRepository.updatePartAdvertisement('1', updates))
            .thenAnswer((_) async => Right(updatedAdvertisement));
        when(mockRepository.getMyPartAdvertisements())
            .thenAnswer((_) async => Right([updatedAdvertisement]));

        // act
        final result = await controller.updateAdvertisement('1', updates);

        // assert
        expect(result, true);
        expect(controller.state.isUpdating, false);
        expect(controller.state.currentAdvertisement, updatedAdvertisement);
        expect(controller.state.error, null);
      });

      test('doit gérer les erreurs lors de la mise à jour', () async {
        // arrange
        const failure = ValidationFailure('Données invalides');
        when(mockRepository.updatePartAdvertisement('1', updates))
            .thenAnswer((_) async => const Left(failure));

        // act
        final result = await controller.updateAdvertisement('1', updates);

        // assert
        expect(result, false);
        expect(controller.state.isUpdating, false);
        expect(controller.state.error, failure.message);
      });

      test('doit passer par l\'état updating pendant la mise à jour', () async {
        // arrange
        when(mockRepository.updatePartAdvertisement('1', updates))
            .thenAnswer((_) async => Right(updatedAdvertisement));
        when(mockRepository.getMyPartAdvertisements())
            .thenAnswer((_) async => Right([updatedAdvertisement]));

        // act
        final future = controller.updateAdvertisement('1', updates);

        // assert - état pendant l'opération
        expect(controller.state.isUpdating, true);

        await future;

        // assert - état après l'opération
        expect(controller.state.isUpdating, false);
      });

      test('doit gérer les exceptions', () async {
        // arrange
        when(mockRepository.updatePartAdvertisement('1', updates))
            .thenThrow(Exception('Exception inattendue'));

        // act
        final result = await controller.updateAdvertisement('1', updates);

        // assert
        expect(result, false);
        expect(controller.state.isUpdating, false);
        expect(controller.state.error, 'Erreur inattendue: Exception: Exception inattendue');
      });
    });

    group('markAsSold', () {
      test('doit marquer comme vendu avec succès', () async {
        // arrange
        when(mockRepository.markAsSold('1'))
            .thenAnswer((_) async => const Right(unit));
        when(mockRepository.getMyPartAdvertisements())
            .thenAnswer((_) async => Right(tPartAdvertisementsList));

        // act
        final result = await controller.markAsSold('1');

        // assert
        expect(result, true);
        expect(controller.state.isUpdating, false);
        expect(controller.state.error, null);
      });

      test('doit gérer les erreurs lors du marquage comme vendu', () async {
        // arrange
        const failure = ServerFailure('Erreur serveur');
        when(mockRepository.markAsSold('1'))
            .thenAnswer((_) async => const Left(failure));

        // act
        final result = await controller.markAsSold('1');

        // assert
        expect(result, false);
        expect(controller.state.isUpdating, false);
        expect(controller.state.error, failure.message);
      });

      test('doit passer par l\'état updating pendant le marquage', () async {
        // arrange
        when(mockRepository.markAsSold('1'))
            .thenAnswer((_) async => const Right(unit));
        when(mockRepository.getMyPartAdvertisements())
            .thenAnswer((_) async => Right(tPartAdvertisementsList));

        // act
        final future = controller.markAsSold('1');

        // assert - état pendant l'opération
        expect(controller.state.isUpdating, true);

        await future;

        // assert - état après l'opération
        expect(controller.state.isUpdating, false);
      });

      test('doit gérer les exceptions', () async {
        // arrange
        when(mockRepository.markAsSold('1'))
            .thenThrow(Exception('Exception inattendue'));

        // act
        final result = await controller.markAsSold('1');

        // assert
        expect(result, false);
        expect(controller.state.isUpdating, false);
        expect(controller.state.error, 'Erreur inattendue: Exception: Exception inattendue');
      });
    });

    group('deleteAdvertisement', () {
      test('doit supprimer une annonce avec succès', () async {
        // arrange
        when(mockRepository.deletePartAdvertisement('1'))
            .thenAnswer((_) async => const Right(unit));
        when(mockRepository.getMyPartAdvertisements())
            .thenAnswer((_) async => const Right([]));

        // act
        final result = await controller.deleteAdvertisement('1');

        // assert
        expect(result, true);
        expect(controller.state.isDeleting, false);
        expect(controller.state.error, null);
      });

      test('doit gérer les erreurs lors de la suppression', () async {
        // arrange
        const failure = AuthFailure('Non autorisé');
        when(mockRepository.deletePartAdvertisement('1'))
            .thenAnswer((_) async => const Left(failure));

        // act
        final result = await controller.deleteAdvertisement('1');

        // assert
        expect(result, false);
        expect(controller.state.isDeleting, false);
        expect(controller.state.error, failure.message);
      });

      test('doit passer par l\'état deleting pendant la suppression', () async {
        // arrange
        when(mockRepository.deletePartAdvertisement('1'))
            .thenAnswer((_) async => const Right(unit));
        when(mockRepository.getMyPartAdvertisements())
            .thenAnswer((_) async => const Right([]));

        // act
        final future = controller.deleteAdvertisement('1');

        // assert - état pendant l'opération
        expect(controller.state.isDeleting, true);

        await future;

        // assert - état après l'opération
        expect(controller.state.isDeleting, false);
      });

      test('doit gérer les exceptions', () async {
        // arrange
        when(mockRepository.deletePartAdvertisement('1'))
            .thenThrow(Exception('Exception inattendue'));

        // act
        final result = await controller.deleteAdvertisement('1');

        // assert
        expect(result, false);
        expect(controller.state.isDeleting, false);
        expect(controller.state.error, 'Erreur inattendue: Exception: Exception inattendue');
      });
    });

    group('incrementViewCount', () {
      test('doit incrémenter le compteur de vues', () async {
        // arrange
        when(mockRepository.incrementViewCount('1'))
            .thenAnswer((_) async => const Right(unit));

        // act
        await controller.incrementViewCount('1');

        // assert
        verify(mockRepository.incrementViewCount('1'));
        // L'état ne change pas pour cette opération
        expect(controller.state.error, null);
      });

      test('doit gérer les erreurs silencieusement', () async {
        // arrange
        when(mockRepository.incrementViewCount('1'))
            .thenAnswer((_) async => const Left(ServerFailure('Erreur')));

        // act
        await controller.incrementViewCount('1');

        // assert
        verify(mockRepository.incrementViewCount('1'));
        // L'erreur ne doit pas affecter l'état car c'est une opération non-bloquante
        expect(controller.state.error, null);
      });
    });

    group('incrementContactCount', () {
      test('doit incrémenter le compteur de contacts', () async {
        // arrange
        when(mockRepository.incrementContactCount('1'))
            .thenAnswer((_) async => const Right(unit));

        // act
        await controller.incrementContactCount('1');

        // assert
        verify(mockRepository.incrementContactCount('1'));
        // L'état ne change pas pour cette opération
        expect(controller.state.error, null);
      });

      test('doit gérer les erreurs silencieusement', () async {
        // arrange
        when(mockRepository.incrementContactCount('1'))
            .thenAnswer((_) async => const Left(ServerFailure('Erreur')));

        // act
        await controller.incrementContactCount('1');

        // assert
        verify(mockRepository.incrementContactCount('1'));
        // L'erreur ne doit pas affecter l'état car c'est une opération non-bloquante
        expect(controller.state.error, null);
      });
    });

    group('resetState', () {
      test('doit réinitialiser l\'état', () {
        // arrange - état avec des données
        controller.state = controller.state.copyWith(
          currentAdvertisement: tPartAdvertisement,
          advertisements: tPartAdvertisementsList,
          error: 'Une erreur',
          isLoading: true,
        );

        // act
        controller.resetState();

        // assert
        expect(controller.state.currentAdvertisement, null);
        expect(controller.state.advertisements, isEmpty);
        expect(controller.state.error, null);
        expect(controller.state.isLoading, false);
        expect(controller.state.isCreating, false);
        expect(controller.state.isUpdating, false);
        expect(controller.state.isDeleting, false);
      });
    });

    group('clearError', () {
      test('doit effacer l\'erreur', () {
        // arrange - état avec erreur
        controller.state = controller.state.copyWith(error: 'Une erreur');

        // act
        controller.clearError();

        // assert
        expect(controller.state.error, null);
      });
    });

    test('doit maintenir l\'état correct lors d\'opérations multiples', () async {
      // arrange
      when(mockRepository.getMyPartAdvertisements())
          .thenAnswer((_) async => Right(tPartAdvertisementsList));
      when(mockRepository.getPartAdvertisementById('1'))
          .thenAnswer((_) async => Right(tPartAdvertisement));

      // act
      await controller.getMyAdvertisements();
      await controller.getAdvertisementById('1');

      // assert
      expect(controller.state.advertisements.length, 1);
      expect(controller.state.currentAdvertisement, tPartAdvertisement);
      expect(controller.state.isLoading, false);
      expect(controller.state.error, null);
    });
  });
}