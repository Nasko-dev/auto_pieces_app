import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/domain/entities/part_request.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/part_request_repository.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/create_part_request.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'create_part_request_test.mocks.dart';

@GenerateMocks([PartRequestRepository])
void main() {
  late CreatePartRequest usecase;
  late MockPartRequestRepository mockRepository;

  setUp(() {
    mockRepository = MockPartRequestRepository();
    usecase = CreatePartRequest(mockRepository);
  });

  final tPartRequest = PartRequest(
    id: '1',
    partNames: const ['moteur', 'transmission'],
    partType: 'engine',
    vehiclePlate: 'AB-123-CD',
    vehicleBrand: 'Renault',
    vehicleModel: 'Clio',
    vehicleYear: 2018,
    isAnonymous: false,
    userId: 'user123',
    status: 'active',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('CreatePartRequest', () {
    test('doit créer une demande de pièce avec succès', () async {
      // arrange
      final params = CreatePartRequestParams(
        partNames: const ['moteur', 'transmission'],
        partType: 'engine',
        vehiclePlate: 'AB-123-CD',
        vehicleBrand: 'Renault',
        vehicleModel: 'Clio',
        vehicleYear: 2018,
        isAnonymous: false,
      );

      when(mockRepository.createPartRequest(any))
          .thenAnswer((_) async => Right(tPartRequest));

      // act
      final result = await usecase(params);

      // assert
      expect(result, Right(tPartRequest));
      verify(mockRepository.createPartRequest(params));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner ValidationFailure quand partNames est vide', () async {
      // arrange
      final params = CreatePartRequestParams(
        partNames: const [],
        partType: 'engine',
        vehiclePlate: 'AB-123-CD',
        isAnonymous: false,
      );

      // act
      final result = await usecase(params);

      // assert
      expect(
          result,
          const Left(
              ValidationFailure('Au moins une pièce doit être spécifiée')));
      verifyZeroInteractions(mockRepository);
    });

    test('doit retourner ValidationFailure quand partType est vide', () async {
      // arrange
      final params = CreatePartRequestParams(
        partNames: const ['moteur'],
        partType: '',
        vehiclePlate: 'AB-123-CD',
        isAnonymous: false,
      );

      // act
      final result = await usecase(params);

      // assert
      expect(
          result, const Left(ValidationFailure('Le type de pièce est requis')));
      verifyZeroInteractions(mockRepository);
    });

    group('Validation pour demandes non-anonymes', () {
      test('doit accepter une demande avec plaque d\'immatriculation',
          () async {
        // arrange
        final params = CreatePartRequestParams(
          partNames: const ['moteur'],
          partType: 'engine',
          vehiclePlate: 'AB-123-CD',
          isAnonymous: false,
        );

        when(mockRepository.createPartRequest(any))
            .thenAnswer((_) async => Right(tPartRequest));

        // act
        final result = await usecase(params);

        // assert
        expect(result, Right(tPartRequest));
      });

      test('doit accepter une demande avec informations complètes du véhicule',
          () async {
        // arrange
        final params = CreatePartRequestParams(
          partNames: const ['moteur'],
          partType: 'engine',
          vehicleBrand: 'Renault',
          vehicleModel: 'Clio',
          vehicleYear: 2018,
          vehicleEngine:
              '1.2 TCe', // Ajout de la motorisation pour pièces moteur
          isAnonymous: false,
        );

        when(mockRepository.createPartRequest(any))
            .thenAnswer((_) async => Right(tPartRequest));

        // act
        final result = await usecase(params);

        // assert
        expect(result, Right(tPartRequest));
      });

      test(
          'doit retourner ValidationFailure sans plaque ni informations complètes',
          () async {
        // arrange
        final params = CreatePartRequestParams(
          partNames: const ['moteur'],
          partType: 'engine',
          vehicleBrand: 'Renault', // Manque model, year et engine
          isAnonymous: false,
        );

        // act
        final result = await usecase(params);

        // assert
        expect(
            result,
            const Left(ValidationFailure(
                'La plaque d\'immatriculation ou la motorisation est requise pour les pièces moteur')));
        verifyZeroInteractions(mockRepository);
      });

      test(
          'doit retourner ValidationFailure avec informations partielles du véhicule',
          () async {
        // arrange
        final params = CreatePartRequestParams(
          partNames: const ['moteur'],
          partType: 'engine',
          vehicleBrand: 'Renault',
          vehicleModel: 'Clio',
          // Manque vehicleYear et vehicleEngine
          isAnonymous: false,
        );

        // act
        final result = await usecase(params);

        // assert
        expect(
            result,
            const Left(ValidationFailure(
                'La plaque d\'immatriculation ou la motorisation est requise pour les pièces moteur')));
        verifyZeroInteractions(mockRepository);
      });
    });

    group('Demandes anonymes', () {
      test('doit accepter une demande anonyme sans informations de véhicule',
          () async {
        // arrange
        final params = CreatePartRequestParams(
          partNames: const ['moteur'],
          partType: 'engine',
          isAnonymous: true,
        );

        final anonymousPartRequest = tPartRequest.copyWith(isAnonymous: true);
        when(mockRepository.createPartRequest(any))
            .thenAnswer((_) async => Right(anonymousPartRequest));

        // act
        final result = await usecase(params);

        // assert
        expect(result, Right(anonymousPartRequest));
        verify(mockRepository.createPartRequest(params));
      });
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      final params = CreatePartRequestParams(
        partNames: const ['moteur'],
        partType: 'engine',
        vehiclePlate: 'AB-123-CD',
        isAnonymous: false,
      );

      when(mockRepository.createPartRequest(any))
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(params);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
    });
  });
}
