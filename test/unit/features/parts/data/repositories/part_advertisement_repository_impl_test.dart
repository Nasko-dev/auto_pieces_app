import 'package:cente_pice/src/core/errors/exceptions.dart';
import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/core/network/network_info.dart';
import 'package:cente_pice/src/features/parts/data/datasources/part_advertisement_remote_datasource.dart';
import 'package:cente_pice/src/features/parts/data/models/part_advertisement_model.dart';
import 'package:cente_pice/src/features/parts/data/repositories/part_advertisement_repository_impl.dart';
import 'package:cente_pice/src/features/parts/domain/entities/part_advertisement.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'part_advertisement_repository_impl_test.mocks.dart';

@GenerateMocks([PartAdvertisementRemoteDataSource, NetworkInfo])
void main() {
  late PartAdvertisementRepositoryImpl repository;
  late MockPartAdvertisementRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockPartAdvertisementRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = PartAdvertisementRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tId = 'ad123';
  const tUserId = 'user456';

  final tPartAdvertisementModel = PartAdvertisementModel(
    id: tId,
    userId: tUserId,
    partType: 'moteur',
    partName: 'Moteur complet',
    vehiclePlate: 'AB123CD',
    vehicleBrand: 'Peugeot',
    vehicleModel: '308',
    vehicleYear: 2015,
    vehicleEngine: '1.6 HDI',
    description: 'Moteur en excellent état',
    price: 2500.0,
    condition: 'bon',
    images: ['image1.jpg', 'image2.jpg'],
    status: 'active',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tPartAdvertisement = tPartAdvertisementModel.toEntity();

  final tCreateParams = CreatePartAdvertisementParams(
    partType: 'moteur',
    partName: 'Moteur complet',
    vehiclePlate: 'AB123CD',
    vehicleBrand: 'Peugeot',
    vehicleModel: '308',
    vehicleYear: 2015,
    vehicleEngine: '1.6 HDI',
    description: 'Moteur en excellent état',
    price: 2500.0,
    condition: 'bon',
    images: ['image1.jpg', 'image2.jpg'],
  );

  final tSearchParams = SearchPartAdvertisementsParams(
    query: 'moteur',
    partType: 'moteur',
    city: 'Paris',
    minPrice: 1000.0,
    maxPrice: 5000.0,
    limit: 10,
    offset: 0,
  );

  group('createPartAdvertisement', () {
    test('doit retourner PartAdvertisement quand l\'appel réussit avec connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.createPartAdvertisement(tCreateParams))
          .thenAnswer((_) async => tPartAdvertisementModel);

      // act
      final result = await repository.createPartAdvertisement(tCreateParams);

      // assert
      expect(result, Right(tPartAdvertisement));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.createPartAdvertisement(tCreateParams));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });

    test('doit retourner NetworkFailure quand il n\'y a pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.createPartAdvertisement(tCreateParams);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure quand ServerException est lancée', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.createPartAdvertisement(tCreateParams))
          .thenThrow(const ServerException('Erreur serveur'));

      // act
      final result = await repository.createPartAdvertisement(tCreateParams);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.createPartAdvertisement(tCreateParams));
    });

    test('doit retourner ServerFailure avec message générique pour une exception générale', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.createPartAdvertisement(tCreateParams))
          .thenThrow(Exception('Erreur inattendue'));

      // act
      final result = await repository.createPartAdvertisement(tCreateParams);

      // assert
      expect(result, const Left(ServerFailure('Erreur inconnue: Exception: Erreur inattendue')));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.createPartAdvertisement(tCreateParams));
    });
  });

  group('getPartAdvertisementById', () {
    test('doit retourner PartAdvertisement quand l\'appel réussit avec connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getPartAdvertisementById(tId))
          .thenAnswer((_) async => tPartAdvertisementModel);

      // act
      final result = await repository.getPartAdvertisementById(tId);

      // assert
      expect(result, Right(tPartAdvertisement));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getPartAdvertisementById(tId));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });

    test('doit retourner NetworkFailure quand il n\'y a pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.getPartAdvertisementById(tId);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure quand ServerException est lancée', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getPartAdvertisementById(tId))
          .thenThrow(const ServerException('Annonce non trouvée'));

      // act
      final result = await repository.getPartAdvertisementById(tId);

      // assert
      expect(result, const Left(ServerFailure('Annonce non trouvée')));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getPartAdvertisementById(tId));
    });
  });

  group('getMyPartAdvertisements', () {
    test('doit retourner une liste d\'annonces quand l\'appel réussit', () async {
      // arrange
      final models = [tPartAdvertisementModel];
      final entities = [tPartAdvertisement];
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getMyPartAdvertisements())
          .thenAnswer((_) async => models);

      // act
      final result = await repository.getMyPartAdvertisements();

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (advertisements) => expect(advertisements, entities),
      );
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getMyPartAdvertisements());
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });

    test('doit retourner NetworkFailure quand il n\'y a pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.getMyPartAdvertisements();

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit gérer une liste vide d\'annonces', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getMyPartAdvertisements())
          .thenAnswer((_) async => <PartAdvertisementModel>[]);

      // act
      final result = await repository.getMyPartAdvertisements();

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (advertisements) => expect(advertisements, <PartAdvertisement>[]),
      );
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getMyPartAdvertisements());
    });
  });

  group('searchPartAdvertisements', () {
    test('doit retourner une liste d\'annonces filtrées quand l\'appel réussit', () async {
      // arrange
      final models = [tPartAdvertisementModel];
      final entities = [tPartAdvertisement];
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.searchPartAdvertisements(tSearchParams))
          .thenAnswer((_) async => models);

      // act
      final result = await repository.searchPartAdvertisements(tSearchParams);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (advertisements) => expect(advertisements, entities),
      );
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.searchPartAdvertisements(tSearchParams));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });

    test('doit retourner NetworkFailure quand il n\'y a pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.searchPartAdvertisements(tSearchParams);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit gérer une recherche sans résultats', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.searchPartAdvertisements(tSearchParams))
          .thenAnswer((_) async => <PartAdvertisementModel>[]);

      // act
      final result = await repository.searchPartAdvertisements(tSearchParams);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (advertisements) => expect(advertisements, <PartAdvertisement>[]),
      );
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.searchPartAdvertisements(tSearchParams));
    });
  });

  group('updatePartAdvertisement', () {
    const tUpdates = {'price': 2000.0, 'description': 'Prix négociable'};

    test('doit retourner PartAdvertisement mise à jour quand l\'appel réussit', () async {
      // arrange
      final updatedModel = tPartAdvertisementModel.copyWith(
        price: 2000.0,
        description: 'Prix négociable',
      );
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.updatePartAdvertisement(tId, tUpdates))
          .thenAnswer((_) async => updatedModel);

      // act
      final result = await repository.updatePartAdvertisement(tId, tUpdates);

      // assert
      expect(result, Right(updatedModel.toEntity()));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.updatePartAdvertisement(tId, tUpdates));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });

    test('doit retourner NetworkFailure quand il n\'y a pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.updatePartAdvertisement(tId, tUpdates);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure quand ServerException est lancée', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.updatePartAdvertisement(tId, tUpdates))
          .thenThrow(const ServerException('Mise à jour impossible'));

      // act
      final result = await repository.updatePartAdvertisement(tId, tUpdates);

      // assert
      expect(result, const Left(ServerFailure('Mise à jour impossible')));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.updatePartAdvertisement(tId, tUpdates));
    });
  });

  group('deletePartAdvertisement', () {
    test('doit retourner void quand la suppression réussit', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.deletePartAdvertisement(tId))
          .thenAnswer((_) async {});

      // act
      final result = await repository.deletePartAdvertisement(tId);

      // assert
      expect(result, const Right(null));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.deletePartAdvertisement(tId));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });

    test('doit retourner NetworkFailure quand il n\'y a pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.deletePartAdvertisement(tId);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure quand ServerException est lancée', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.deletePartAdvertisement(tId))
          .thenThrow(const ServerException('Suppression impossible'));

      // act
      final result = await repository.deletePartAdvertisement(tId);

      // assert
      expect(result, const Left(ServerFailure('Suppression impossible')));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.deletePartAdvertisement(tId));
    });
  });

  group('markAsSold', () {
    test('doit retourner void quand le marquage réussit', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.markAsSold(tId))
          .thenAnswer((_) async {});

      // act
      final result = await repository.markAsSold(tId);

      // assert
      expect(result, const Right(null));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.markAsSold(tId));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });

    test('doit retourner NetworkFailure quand il n\'y a pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.markAsSold(tId);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure quand ServerException est lancée', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.markAsSold(tId))
          .thenThrow(const ServerException('Marquage impossible'));

      // act
      final result = await repository.markAsSold(tId);

      // assert
      expect(result, const Left(ServerFailure('Marquage impossible')));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.markAsSold(tId));
    });
  });

  group('incrementViewCount', () {
    test('doit retourner void quand l\'incrémentation réussit', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.incrementViewCount(tId))
          .thenAnswer((_) async {});

      // act
      final result = await repository.incrementViewCount(tId);

      // assert
      expect(result, const Right(null));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.incrementViewCount(tId));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });

    test('doit retourner Right(null) sans erreur quand il n\'y a pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.incrementViewCount(tId);

      // assert
      expect(result, const Right(null));
      verify(mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit retourner Right(null) sans erreur quand une exception est lancée', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.incrementViewCount(tId))
          .thenThrow(Exception('Erreur inattendue'));

      // act
      final result = await repository.incrementViewCount(tId);

      // assert
      expect(result, const Right(null));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.incrementViewCount(tId));
    });
  });

  group('incrementContactCount', () {
    test('doit retourner void quand l\'incrémentation réussit', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.incrementContactCount(tId))
          .thenAnswer((_) async {});

      // act
      final result = await repository.incrementContactCount(tId);

      // assert
      expect(result, const Right(null));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.incrementContactCount(tId));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });

    test('doit retourner Right(null) sans erreur quand il n\'y a pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.incrementContactCount(tId);

      // assert
      expect(result, const Right(null));
      verify(mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit retourner Right(null) sans erreur quand une exception est lancée', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.incrementContactCount(tId))
          .thenThrow(Exception('Erreur inattendue'));

      // act
      final result = await repository.incrementContactCount(tId);

      // assert
      expect(result, const Right(null));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.incrementContactCount(tId));
    });
  });
}