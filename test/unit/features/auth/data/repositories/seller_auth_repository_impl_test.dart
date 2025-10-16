import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/core/network/network_info.dart';
import 'package:cente_pice/src/features/auth/data/datasources/particulier_auth_local_datasource.dart';
import 'package:cente_pice/src/features/auth/data/datasources/seller_auth_remote_datasource.dart';
import 'package:cente_pice/src/features/auth/data/models/seller_model.dart';
import 'package:cente_pice/src/features/auth/data/repositories/seller_auth_repository_impl.dart';
import 'package:cente_pice/src/features/auth/domain/entities/seller.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'seller_auth_repository_impl_test.mocks.dart';

@GenerateMocks([
  SellerAuthRemoteDataSource,
  ParticulierAuthLocalDataSource,
  NetworkInfo,
])
void main() {
  late SellerAuthRepositoryImpl repository;
  late MockSellerAuthRemoteDataSource mockRemoteDataSource;
  late MockParticulierAuthLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockSellerAuthRemoteDataSource();
    mockLocalDataSource = MockParticulierAuthLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = SellerAuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      particulierLocalDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
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

  final tSellerModel = SellerModel.fromEntity(tSeller);

  group('SellerAuthRepositoryImpl', () {
    group('loginSeller', () {
      const tEmail = 'test@example.com';
      const tPassword = 'password123';

      test(
          'doit retourner un Seller quand la connexion réussit avec connexion internet',
          () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.loginSeller(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => tSellerModel);

        // act
        final result = await repository.loginSeller(
          email: tEmail,
          password: tPassword,
        );

        // assert
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.loginSeller(
          email: tEmail,
          password: tPassword,
        ));
        expect(result, Right(tSellerModel));
      });

      test(
          'doit retourner NetworkFailure quand il n\'y a pas de connexion internet',
          () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.loginSeller(
          email: tEmail,
          password: tPassword,
        );

        // assert
        verify(mockNetworkInfo.isConnected);
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, const Left(NetworkFailure('Aucune connexion internet')));
      });

      test('doit retourner AuthFailure quand les identifiants sont incorrects',
          () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.loginSeller(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(const AuthFailure('Identifiants incorrects'));

        // act
        final result = await repository.loginSeller(
          email: tEmail,
          password: tPassword,
        );

        // assert
        expect(result, const Left(AuthFailure('Identifiants incorrects')));
      });

      test('doit retourner ServerFailure pour toute autre exception', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.loginSeller(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(Exception('Erreur inattendue'));

        // act
        final result = await repository.loginSeller(
          email: tEmail,
          password: tPassword,
        );

        // assert
        expect(
            result,
            const Left(
                ServerFailure('Erreur serveur: Exception: Erreur inattendue')));
      });
    });

    group('registerSeller', () {
      const tEmail = 'test@example.com';
      const tPassword = 'password123';
      const tFirstName = 'Test';
      const tLastName = 'User';
      const tCompanyName = 'Test Company';
      const tPhone = '+33123456789';

      test('doit retourner un Seller quand l\'inscription réussit', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.registerSeller(
          email: anyNamed('email'),
          password: anyNamed('password'),
          firstName: anyNamed('firstName'),
          lastName: anyNamed('lastName'),
          companyName: anyNamed('companyName'),
          phone: anyNamed('phone'),
        )).thenAnswer((_) async => tSellerModel);

        // act
        final result = await repository.registerSeller(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          companyName: tCompanyName,
          phone: tPhone,
        );

        // assert
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.registerSeller(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          companyName: tCompanyName,
          phone: tPhone,
        ));
        expect(result, Right(tSellerModel));
      });

      test('doit retourner NetworkFailure sans connexion internet', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.registerSeller(
          email: tEmail,
          password: tPassword,
        );

        // assert
        verify(mockNetworkInfo.isConnected);
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, const Left(NetworkFailure('Aucune connexion internet')));
      });
    });

    group('logoutSeller', () {
      test('doit se déconnecter avec succès et nettoyer le cache', () async {
        // arrange
        when(mockRemoteDataSource.logoutSeller()).thenAnswer((_) async => {});
        when(mockLocalDataSource.clearCache()).thenAnswer((_) async => {});

        // act
        final result = await repository.logoutSeller();

        // assert
        verify(mockRemoteDataSource.logoutSeller());
        verify(mockLocalDataSource.clearCache());
        expect(result, const Right(null));
      });

      test('doit réussir même si le nettoyage du cache échoue', () async {
        // arrange
        when(mockRemoteDataSource.logoutSeller()).thenAnswer((_) async => {});
        when(mockLocalDataSource.clearCache())
            .thenThrow(Exception('Erreur cache'));

        // act
        final result = await repository.logoutSeller();

        // assert
        verify(mockRemoteDataSource.logoutSeller());
        verify(mockLocalDataSource.clearCache());
        expect(result, const Right(null));
      });

      test('doit retourner ServerFailure si la déconnexion échoue', () async {
        // arrange
        when(mockRemoteDataSource.logoutSeller())
            .thenThrow(Exception('Erreur déconnexion'));

        // act
        final result = await repository.logoutSeller();

        // assert
        expect(
            result,
            const Left(ServerFailure(
                'Erreur lors de la déconnexion: Exception: Erreur déconnexion')));
      });
    });

    group('getCurrentSeller', () {
      test('doit retourner le vendeur actuel avec connexion internet',
          () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.getCurrentSeller())
            .thenAnswer((_) async => tSellerModel);

        // act
        final result = await repository.getCurrentSeller();

        // assert
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.getCurrentSeller());
        expect(result, Right(tSellerModel));
      });

      test('doit retourner NetworkFailure sans connexion internet', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.getCurrentSeller();

        // assert
        verify(mockNetworkInfo.isConnected);
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, const Left(NetworkFailure('Aucune connexion internet')));
      });

      test('doit retourner AuthFailure si non authentifié', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.getCurrentSeller())
            .thenThrow(const AuthFailure('Non authentifié'));

        // act
        final result = await repository.getCurrentSeller();

        // assert
        expect(result, const Left(AuthFailure('Non authentifié')));
      });
    });

    group('sendPasswordResetEmail', () {
      const tEmail = 'test@example.com';

      test('doit envoyer l\'email de réinitialisation avec succès', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.sendPasswordResetEmail(any))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.sendPasswordResetEmail(tEmail);

        // assert
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.sendPasswordResetEmail(tEmail));
        expect(result, const Right(null));
      });

      test('doit retourner NetworkFailure sans connexion internet', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.sendPasswordResetEmail(tEmail);

        // assert
        verify(mockNetworkInfo.isConnected);
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, const Left(NetworkFailure('Aucune connexion internet')));
      });
    });

    group('updateSellerProfile', () {
      test('doit mettre à jour le profil avec succès', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.updateSellerProfile(any))
            .thenAnswer((_) async => tSellerModel);

        // act
        final result = await repository.updateSellerProfile(tSeller);

        // assert
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.updateSellerProfile(any));
        expect(result, Right(tSellerModel));
      });

      test('doit retourner NetworkFailure sans connexion internet', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.updateSellerProfile(tSeller);

        // assert
        verify(mockNetworkInfo.isConnected);
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, const Left(NetworkFailure('Aucune connexion internet')));
      });
    });
  });
}
