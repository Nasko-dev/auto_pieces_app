import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/core/network/network_info.dart';
import 'package:cente_pice/src/features/parts/data/datasources/seller_settings_remote_datasource.dart';
import 'package:cente_pice/src/features/parts/data/models/seller_settings_model.dart';
import 'package:cente_pice/src/features/parts/data/repositories/seller_settings_repository_impl.dart';
import 'package:cente_pice/src/features/parts/domain/entities/seller_settings.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'seller_settings_repository_impl_test.mocks.dart';

@GenerateMocks([SellerSettingsRemoteDataSource, NetworkInfo])
void main() {
  late SellerSettingsRepositoryImpl repository;
  late MockSellerSettingsRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockSellerSettingsRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = SellerSettingsRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
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

  final tSellerSettingsModel = SellerSettingsModel.fromEntity(tSellerSettings);

  group('getSellerSettings', () {
    test('doit retourner SellerSettings quand l\'appel réussit avec connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getSellerSettings(tSellerId))
          .thenAnswer((_) async => tSellerSettingsModel);

      // act
      final result = await repository.getSellerSettings(tSellerId);

      // assert
      expect(result, Right(tSellerSettings));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getSellerSettings(tSellerId));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });

    test('doit retourner null quand les paramètres n\'existent pas', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getSellerSettings(tSellerId))
          .thenAnswer((_) async => null);

      // act
      final result = await repository.getSellerSettings(tSellerId);

      // assert
      expect(result, const Right(null));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getSellerSettings(tSellerId));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });

    test('doit retourner ServerFailure quand il n\'y a pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.getSellerSettings(tSellerId);

      // assert
      expect(result, const Left(ServerFailure('Pas de connexion internet')));
      verify(mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure quand le datasource lance une ServerFailure', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getSellerSettings(tSellerId))
          .thenThrow(const ServerFailure('Erreur serveur'));

      // act
      final result = await repository.getSellerSettings(tSellerId);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getSellerSettings(tSellerId));
    });

    test('doit déléguer entièrement au datasource quand connecté', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getSellerSettings(tSellerId))
          .thenAnswer((_) async => tSellerSettingsModel);

      // act
      await repository.getSellerSettings(tSellerId);

      // assert
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getSellerSettings(tSellerId));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });
  });

  group('saveSellerSettings', () {
    test('doit retourner SellerSettings sauvegardés quand l\'appel réussit avec connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.saveSellerSettings(any))
          .thenAnswer((_) async => tSellerSettingsModel);

      // act
      final result = await repository.saveSellerSettings(tSellerSettings);

      // assert
      expect(result, Right(tSellerSettings));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.saveSellerSettings(any));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });

    test('doit retourner ServerFailure quand il n\'y a pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.saveSellerSettings(tSellerSettings);

      // assert
      expect(result, const Left(ServerFailure('Pas de connexion internet')));
      verify(mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure quand le datasource lance une ServerFailure', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.saveSellerSettings(any))
          .thenThrow(const ServerFailure('Erreur de sauvegarde'));

      // act
      final result = await repository.saveSellerSettings(tSellerSettings);

      // assert
      expect(result, const Left(ServerFailure('Erreur de sauvegarde')));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.saveSellerSettings(any));
    });

    test('doit convertir l\'entité en modèle avant de l\'envoyer au datasource', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.saveSellerSettings(any))
          .thenAnswer((_) async => tSellerSettingsModel);

      // act
      await repository.saveSellerSettings(tSellerSettings);

      // assert
      verify(mockNetworkInfo.isConnected);
      final captured = verify(mockRemoteDataSource.saveSellerSettings(captureAny)).captured;
      expect(captured.first, isA<SellerSettingsModel>());
      final capturedModel = captured.first as SellerSettingsModel;
      expect(capturedModel.sellerId, tSellerSettings.sellerId);
      expect(capturedModel.email, tSellerSettings.email);
    });

    test('doit déléguer entièrement au datasource quand connecté', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.saveSellerSettings(any))
          .thenAnswer((_) async => tSellerSettingsModel);

      // act
      await repository.saveSellerSettings(tSellerSettings);

      // assert
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.saveSellerSettings(any));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });
  });

  group('deleteSellerSettings', () {
    test('doit retourner Unit quand la suppression réussit avec connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.deleteSellerSettings(tSellerId))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.deleteSellerSettings(tSellerId);

      // assert
      expect(result, const Right(unit));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.deleteSellerSettings(tSellerId));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });

    test('doit retourner ServerFailure quand il n\'y a pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.deleteSellerSettings(tSellerId);

      // assert
      expect(result, const Left(ServerFailure('Pas de connexion internet')));
      verify(mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure quand le datasource lance une ServerFailure', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.deleteSellerSettings(tSellerId))
          .thenThrow(const ServerFailure('Erreur de suppression'));

      // act
      final result = await repository.deleteSellerSettings(tSellerId);

      // assert
      expect(result, const Left(ServerFailure('Erreur de suppression')));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.deleteSellerSettings(tSellerId));
    });

    test('doit déléguer entièrement au datasource quand connecté', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.deleteSellerSettings(tSellerId))
          .thenAnswer((_) async => {});

      // act
      await repository.deleteSellerSettings(tSellerId);

      // assert
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.deleteSellerSettings(tSellerId));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });
  });
}