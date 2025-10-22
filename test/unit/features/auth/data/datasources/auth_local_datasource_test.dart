import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:cente_pice/src/features/auth/data/models/user_model.dart';

void main() {
  group('AuthLocalDataSource Tests', () {
    late AuthLocalDataSourceImpl dataSource;

    setUp(() {
      dataSource = AuthLocalDataSourceImpl();
    });

    tearDown(() async {
      await dataSource.clearCache();
    });

    group('Cache Operations', () {
      test('devrait retourner null quand aucun utilisateur en cache', () async {
        final result = await dataSource.getCachedUser();
        expect(result, isNull);
      });

      test('devrait cacher et récupérer un utilisateur', () async {
        final user = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          userType: 'particulier',
          createdAt: DateTime.now(),
        );

        await dataSource.cacheUser(user);
        final cachedUser = await dataSource.getCachedUser();

        expect(cachedUser, isNotNull);
        expect(cachedUser!.id, equals('test-id'));
        expect(cachedUser.email, equals('test@example.com'));
        expect(cachedUser.userType, equals('particulier'));
      });

      test('devrait vider le cache correctement', () async {
        final user = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          userType: 'seller',
          createdAt: DateTime.now(),
        );

        await dataSource.cacheUser(user);
        expect(await dataSource.getCachedUser(), isNotNull);

        await dataSource.clearCache();
        expect(await dataSource.getCachedUser(), isNull);
      });

      test('devrait remplacer l\'utilisateur en cache', () async {
        final user1 = UserModel(
          id: 'user-1',
          email: 'user1@example.com',
          userType: 'particulier',
          createdAt: DateTime.now(),
        );

        final user2 = UserModel(
          id: 'user-2',
          email: 'user2@example.com',
          userType: 'seller',
          createdAt: DateTime.now(),
        );

        await dataSource.cacheUser(user1);
        expect((await dataSource.getCachedUser())!.id, equals('user-1'));

        await dataSource.cacheUser(user2);
        expect((await dataSource.getCachedUser())!.id, equals('user-2'));
        expect((await dataSource.getCachedUser())!.userType, equals('seller'));
      });
    });

    group('Static Data Persistence', () {
      test('devrait maintenir les données entre instances', () async {
        final user = UserModel(
          id: 'persistent-user',
          email: 'persistent@example.com',
          userType: 'seller',
          createdAt: DateTime.now(),
        );

        await dataSource.cacheUser(user);

        final newInstance = AuthLocalDataSourceImpl();
        final cachedUser = await newInstance.getCachedUser();

        expect(cachedUser, isNotNull);
        expect(cachedUser!.id, equals('persistent-user'));
        expect(cachedUser.email, equals('persistent@example.com'));
      });
    });

    group('Validation des types', () {
      test('devrait gérer différents types d\'utilisateurs', () async {
        final types = ['particulier', 'seller', 'admin'];

        for (final type in types) {
          final user = UserModel(
            id: 'user-$type',
            email: '$type@example.com',
            userType: type,
            createdAt: DateTime.now(),
          );

          await dataSource.cacheUser(user);
          final cached = await dataSource.getCachedUser();

          expect(cached!.userType, equals(type));
        }
      });

      test('devrait gérer les utilisateurs avec updatedAt', () async {
        final now = DateTime.now();
        final user = UserModel(
          id: 'updated-user',
          email: 'updated@example.com',
          userType: 'particulier',
          createdAt: now,
          updatedAt: now,
        );

        await dataSource.cacheUser(user);
        final cached = await dataSource.getCachedUser();

        expect(cached!.updatedAt, isNotNull);
        expect(cached.updatedAt, equals(now));
      });

      test('devrait gérer les utilisateurs sans email', () async {
        final user = UserModel(
          id: 'no-email-user',
          userType: 'particulier',
          createdAt: DateTime.now(),
        );

        await dataSource.cacheUser(user);
        final cached = await dataSource.getCachedUser();

        expect(cached!.email, isNull);
        expect(cached.id, equals('no-email-user'));
      });
    });
  });
}
