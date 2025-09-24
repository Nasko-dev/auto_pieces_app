import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/core/errors/exceptions.dart';
import 'package:cente_pice/src/core/network/network_info.dart';
import 'package:cente_pice/src/features/parts/data/datasources/part_request_remote_datasource.dart';
import 'package:cente_pice/src/features/parts/data/datasources/conversations_remote_datasource.dart';
import 'package:cente_pice/src/features/parts/data/repositories/part_request_repository_impl.dart';
import 'package:cente_pice/src/features/parts/domain/entities/part_request.dart';
import 'package:cente_pice/src/features/parts/data/models/part_request_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'part_request_repository_impl_test.mocks.dart';

@GenerateMocks([PartRequestRemoteDataSource, ConversationsRemoteDataSource, NetworkInfo])
void main() {
  late PartRequestRepositoryImpl repository;
  late MockPartRequestRemoteDataSource mockRemoteDataSource;
  late MockConversationsRemoteDataSource mockConversationsRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockPartRequestRemoteDataSource();
    mockConversationsRemoteDataSource = MockConversationsRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = PartRequestRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      conversationsRemoteDataSource: mockConversationsRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tUserId = 'user123';
  const tRequestId = 'request123';

  final tCreateParams = CreatePartRequestParams(
    vehicleBrand: 'Peugeot',
    vehicleModel: '308',
    vehicleYear: 2018,
    partType: 'engine',
    partNames: ['moteur complet'],
    additionalInfo: 'Bon état',
    isAnonymous: false,
  );

  final tPartRequestModel = PartRequestModel(
    id: tRequestId,
    userId: tUserId,
    vehicleBrand: 'Peugeot',
    vehicleModel: '308',
    vehicleYear: 2018,
    partType: 'engine',
    partNames: ['moteur complet'],
    additionalInfo: 'Bon état',
    status: 'active',
    isAnonymous: false,
    responseCount: 0,
    pendingResponseCount: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now(),
  );

  group('getUserPartRequests', () {
    test('doit retourner une liste de demandes quand l\'appel réussit avec connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getUserPartRequests())
          .thenAnswer((_) async => [tPartRequestModel]);

      // act
      final result = await repository.getUserPartRequests();

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return right'),
        (requests) => expect(requests.length, 1),
      );
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getUserPartRequests());
    });

    test('doit retourner NetworkFailure quand il n\'y a pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.getUserPartRequests();

      // assert
      expect(result, const Left(NetworkFailure('No internet connection')));
      verify(mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit retourner AuthFailure quand unauthorized', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getUserPartRequests())
          .thenThrow(const UnauthorizedException('Not authorized'));

      // act
      final result = await repository.getUserPartRequests();

      // assert
      expect(result, const Left(AuthFailure('User not authenticated')));
      verify(mockRemoteDataSource.getUserPartRequests());
    });

    test('doit retourner ServerFailure quand ServerException', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getUserPartRequests())
          .thenThrow(const ServerException('Erreur serveur'));

      // act
      final result = await repository.getUserPartRequests();

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRemoteDataSource.getUserPartRequests());
    });

    test('doit retourner ServerFailure pour exception générique', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getUserPartRequests())
          .thenThrow(Exception('Erreur inattendue'));

      // act
      final result = await repository.getUserPartRequests();

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (requests) => fail('Should return failure'),
      );
    });
  });

  group('createPartRequest', () {
    test('doit retourner PartRequest créé quand l\'appel réussit', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.createPartRequest(tCreateParams))
          .thenAnswer((_) async => tPartRequestModel);

      // act
      final result = await repository.createPartRequest(tCreateParams);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return right'),
        (request) => expect(request.id, tRequestId),
      );
      verify(mockRemoteDataSource.createPartRequest(tCreateParams));
    });

    test('doit retourner NetworkFailure quand pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.createPartRequest(tCreateParams);

      // assert
      expect(result, const Left(NetworkFailure('No internet connection')));
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit retourner AuthFailure quand unauthorized', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.createPartRequest(tCreateParams))
          .thenThrow(const UnauthorizedException('Not authorized'));

      // act
      final result = await repository.createPartRequest(tCreateParams);

      // assert
      expect(result, const Left(AuthFailure('User not authenticated')));
    });

    test('doit retourner ServerFailure pour ServerException', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.createPartRequest(tCreateParams))
          .thenThrow(const ServerException('Erreur création'));

      // act
      final result = await repository.createPartRequest(tCreateParams);

      // assert
      expect(result, const Left(ServerFailure('Erreur création')));
    });
  });

  group('getPartRequestById', () {
    test('doit retourner PartRequest quand trouvé', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getPartRequestById(tRequestId))
          .thenAnswer((_) async => tPartRequestModel);

      // act
      final result = await repository.getPartRequestById(tRequestId);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return right'),
        (request) => expect(request.id, tRequestId),
      );
      verify(mockRemoteDataSource.getPartRequestById(tRequestId));
    });

    test('doit retourner NetworkFailure quand pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.getPartRequestById(tRequestId);

      // assert
      expect(result, const Left(NetworkFailure('No internet connection')));
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure pour ServerException', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getPartRequestById(tRequestId))
          .thenThrow(const ServerException('Demande non trouvée'));

      // act
      final result = await repository.getPartRequestById(tRequestId);

      // assert
      expect(result, const Left(ServerFailure('Demande non trouvée')));
    });
  });

  group('updatePartRequestStatus', () {
    test('doit retourner PartRequest mis à jour', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.updatePartRequestStatus(tRequestId, 'closed'))
          .thenAnswer((_) async => tPartRequestModel);

      // act
      final result = await repository.updatePartRequestStatus(tRequestId, 'closed');

      // assert
      expect(result.isRight(), true);
      verify(mockRemoteDataSource.updatePartRequestStatus(tRequestId, 'closed'));
    });

    test('doit retourner NetworkFailure quand pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.updatePartRequestStatus(tRequestId, 'closed');

      // assert
      expect(result, const Left(NetworkFailure('No internet connection')));
    });

    test('doit retourner AuthFailure quand unauthorized', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.updatePartRequestStatus(tRequestId, 'closed'))
          .thenThrow(const UnauthorizedException('Not authorized'));

      // act
      final result = await repository.updatePartRequestStatus(tRequestId, 'closed');

      // assert
      expect(result, const Left(AuthFailure('User not authenticated')));
    });
  });

  group('deletePartRequest', () {
    test('doit retourner void quand suppression réussit', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.deletePartRequest(tRequestId))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.deletePartRequest(tRequestId);

      // assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.deletePartRequest(tRequestId));
    });

    test('doit retourner NetworkFailure quand pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.deletePartRequest(tRequestId);

      // assert
      expect(result, const Left(NetworkFailure('No internet connection')));
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit retourner AuthFailure quand unauthorized', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.deletePartRequest(tRequestId))
          .thenThrow(const UnauthorizedException('Not authorized'));

      // act
      final result = await repository.deletePartRequest(tRequestId);

      // assert
      expect(result, const Left(AuthFailure('User not authenticated')));
    });

    test('doit retourner ServerFailure pour ServerException', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.deletePartRequest(tRequestId))
          .thenThrow(const ServerException('Erreur suppression'));

      // act
      final result = await repository.deletePartRequest(tRequestId);

      // assert
      expect(result, const Left(ServerFailure('Erreur suppression')));
    });
  });

  group('searchPartRequests', () {
    test('doit retourner liste filtrée de demandes', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.searchPartRequests(
        partType: 'engine',
        vehicleBrand: 'Peugeot',
        status: 'active',
        limit: 20,
        offset: 0,
      )).thenAnswer((_) async => [tPartRequestModel]);

      // act
      final result = await repository.searchPartRequests(
        partType: 'engine',
        vehicleBrand: 'Peugeot',
        status: 'active',
        limit: 20,
        offset: 0,
      );

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return right'),
        (requests) => expect(requests.length, 1),
      );
    });

    test('doit retourner NetworkFailure quand pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.searchPartRequests();

      // assert
      expect(result, const Left(NetworkFailure('No internet connection')));
    });

    test('doit retourner ServerFailure pour ServerException', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.searchPartRequests(
        partType: null,
        vehicleBrand: null,
        status: null,
        limit: 20,
        offset: 0,
      )).thenThrow(const ServerException('Erreur recherche'));

      // act
      final result = await repository.searchPartRequests();

      // assert
      expect(result, const Left(ServerFailure('Erreur recherche')));
    });
  });

  group('getPartRequestStats', () {
    test('doit retourner statistiques', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      final stats = {'active': 5, 'closed': 10, 'fulfilled': 3};
      when(mockRemoteDataSource.getPartRequestStats())
          .thenAnswer((_) async => stats);

      // act
      final result = await repository.getPartRequestStats();

      // assert
      expect(result, Right(stats));
      verify(mockRemoteDataSource.getPartRequestStats());
    });

    test('doit retourner NetworkFailure quand pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.getPartRequestStats();

      // assert
      expect(result, const Left(NetworkFailure('No internet connection')));
    });

    test('doit retourner AuthFailure quand unauthorized', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getPartRequestStats())
          .thenThrow(const UnauthorizedException('Not authorized'));

      // act
      final result = await repository.getPartRequestStats();

      // assert
      expect(result, const Left(AuthFailure('User not authenticated')));
    });
  });

  group('getActivePartRequestsForSeller', () {
    test('doit retourner demandes actives pour vendeur', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getActivePartRequestsForSeller())
          .thenAnswer((_) async => [tPartRequestModel]);

      // act
      final result = await repository.getActivePartRequestsForSeller();

      // assert
      expect(result.isRight(), true);
      verify(mockRemoteDataSource.getActivePartRequestsForSeller());
    });

    test('doit retourner NetworkFailure quand pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.getActivePartRequestsForSeller();

      // assert
      expect(result, const Left(NetworkFailure('No internet connection')));
    });

    test('doit retourner AuthFailure quand unauthorized', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getActivePartRequestsForSeller())
          .thenThrow(const UnauthorizedException('Not authorized'));

      // act
      final result = await repository.getActivePartRequestsForSeller();

      // assert
      expect(result, const Left(AuthFailure('User not authenticated')));
    });
  });

  group('hasActivePartRequest', () {
    test('doit retourner true quand demande active existe', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.hasActivePartRequest())
          .thenAnswer((_) async => true);

      // act
      final result = await repository.hasActivePartRequest();

      // assert
      expect(result, const Right(true));
    });

    test('doit retourner false quand aucune demande active', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.hasActivePartRequest())
          .thenAnswer((_) async => false);

      // act
      final result = await repository.hasActivePartRequest();

      // assert
      expect(result, const Right(false));
    });

    test('doit retourner NetworkFailure quand pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.hasActivePartRequest();

      // assert
      expect(result, const Left(NetworkFailure('No internet connection')));
    });

    test('doit retourner ServerFailure pour ServerException', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.hasActivePartRequest())
          .thenThrow(const ServerException('Erreur vérification'));

      // act
      final result = await repository.hasActivePartRequest();

      // assert
      expect(result, const Left(ServerFailure('Erreur vérification')));
    });
  });
}