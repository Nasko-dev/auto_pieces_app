import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/core/network/network_info.dart';
import 'package:cente_pice/src/features/parts/data/datasources/user_settings_remote_datasource.dart';
import 'package:cente_pice/src/features/parts/data/models/user_settings_model.dart';
import 'package:cente_pice/src/features/parts/data/repositories/user_settings_repository_impl.dart';
import 'package:cente_pice/src/features/parts/domain/entities/user_settings.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_settings_repository_impl_test.mocks.dart';

@GenerateMocks([UserSettingsRemoteDataSource, NetworkInfo])
void main() {
  late UserSettingsRepositoryImpl repository;
  late MockUserSettingsRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockUserSettingsRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = UserSettingsRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tUserId = 'user123';

  final tUserSettings = UserSettings(
    userId: tUserId,
    displayName: 'Jean Dupont',
    address: '123 Rue de la Paix',
    city: 'Paris',
    postalCode: '75001',
    country: 'France',
    phone: '+33123456789',
    avatarUrl: 'https://example.com/avatar.jpg',
    notificationsEnabled: true,
    emailNotificationsEnabled: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  );

  final tUserSettingsModel = UserSettingsModel.fromEntity(tUserSettings);

  group('getUserSettings', () {
    test('doit retourner UserSettings quand l\'appel réussit avec connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getUserSettings(tUserId))
          .thenAnswer((_) async => tUserSettingsModel);

      // act
      final result = await repository.getUserSettings(tUserId);

      // assert
      expect(result, Right(tUserSettings));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getUserSettings(tUserId));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });

    test('doit retourner null quand les paramètres n\'existent pas', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getUserSettings(tUserId))
          .thenAnswer((_) async => null);

      // act
      final result = await repository.getUserSettings(tUserId);

      // assert
      expect(result, const Right(null));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getUserSettings(tUserId));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });

    test('doit retourner NetworkFailure quand il n\'y a pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.getUserSettings(tUserId);

      // assert
      expect(result, const Left(NetworkFailure('Aucune connexion internet')));
      verify(mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure quand le datasource lance une ServerFailure', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getUserSettings(tUserId))
          .thenThrow(const ServerFailure('Erreur serveur'));

      // act
      final result = await repository.getUserSettings(tUserId);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getUserSettings(tUserId));
    });

    test('doit retourner ServerFailure quand le datasource lance une exception générique', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getUserSettings(tUserId))
          .thenThrow(Exception('Erreur inattendue'));

      // act
      final result = await repository.getUserSettings(tUserId);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur: Exception: Erreur inattendue')));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getUserSettings(tUserId));
    });

    test('doit déléguer entièrement au datasource quand connecté', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getUserSettings(tUserId))
          .thenAnswer((_) async => tUserSettingsModel);

      // act
      await repository.getUserSettings(tUserId);

      // assert
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getUserSettings(tUserId));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });
  });

  group('saveUserSettings', () {
    test('doit retourner UserSettings sauvegardés quand l\'appel réussit avec connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.saveUserSettings(any))
          .thenAnswer((_) async => tUserSettingsModel);

      // act
      final result = await repository.saveUserSettings(tUserSettings);

      // assert
      expect(result, Right(tUserSettings));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.saveUserSettings(any));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });

    test('doit retourner NetworkFailure quand il n\'y a pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.saveUserSettings(tUserSettings);

      // assert
      expect(result, const Left(NetworkFailure('Aucune connexion internet')));
      verify(mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure quand le datasource lance une ServerFailure', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.saveUserSettings(any))
          .thenThrow(const ServerFailure('Erreur de sauvegarde'));

      // act
      final result = await repository.saveUserSettings(tUserSettings);

      // assert
      expect(result, const Left(ServerFailure('Erreur de sauvegarde')));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.saveUserSettings(any));
    });

    test('doit retourner ServerFailure quand le datasource lance une exception générique', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.saveUserSettings(any))
          .thenThrow(Exception('Erreur inattendue'));

      // act
      final result = await repository.saveUserSettings(tUserSettings);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur: Exception: Erreur inattendue')));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.saveUserSettings(any));
    });

    test('doit convertir l\'entité en modèle avant de l\'envoyer au datasource', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.saveUserSettings(any))
          .thenAnswer((_) async => tUserSettingsModel);

      // act
      await repository.saveUserSettings(tUserSettings);

      // assert
      verify(mockNetworkInfo.isConnected);
      final captured = verify(mockRemoteDataSource.saveUserSettings(captureAny)).captured;
      expect(captured.first, isA<UserSettingsModel>());
      final capturedModel = captured.first as UserSettingsModel;
      expect(capturedModel.userId, tUserSettings.userId);
      expect(capturedModel.displayName, tUserSettings.displayName);
      expect(capturedModel.phone, tUserSettings.phone);
    });

    test('doit déléguer entièrement au datasource quand connecté', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.saveUserSettings(any))
          .thenAnswer((_) async => tUserSettingsModel);

      // act
      await repository.saveUserSettings(tUserSettings);

      // assert
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.saveUserSettings(any));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });
  });

  group('deleteUserSettings', () {
    test('doit retourner void quand la suppression réussit avec connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.deleteUserSettings(tUserId))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.deleteUserSettings(tUserId);

      // assert
      expect(result, const Right(null));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.deleteUserSettings(tUserId));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });

    test('doit retourner NetworkFailure quand il n\'y a pas de connexion', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.deleteUserSettings(tUserId);

      // assert
      expect(result, const Left(NetworkFailure('Aucune connexion internet')));
      verify(mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure quand le datasource lance une ServerFailure', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.deleteUserSettings(tUserId))
          .thenThrow(const ServerFailure('Erreur de suppression'));

      // act
      final result = await repository.deleteUserSettings(tUserId);

      // assert
      expect(result, const Left(ServerFailure('Erreur de suppression')));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.deleteUserSettings(tUserId));
    });

    test('doit retourner ServerFailure quand le datasource lance une exception générique', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.deleteUserSettings(tUserId))
          .thenThrow(Exception('Erreur inattendue'));

      // act
      final result = await repository.deleteUserSettings(tUserId);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur: Exception: Erreur inattendue')));
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.deleteUserSettings(tUserId));
    });

    test('doit déléguer entièrement au datasource quand connecté', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.deleteUserSettings(tUserId))
          .thenAnswer((_) async => {});

      // act
      await repository.deleteUserSettings(tUserId);

      // assert
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.deleteUserSettings(tUserId));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockNetworkInfo);
    });
  });
}