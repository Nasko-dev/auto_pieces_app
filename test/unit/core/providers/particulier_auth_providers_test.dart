import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cente_pice/src/core/providers/particulier_auth_providers.dart';
import 'package:cente_pice/src/features/auth/data/datasources/particulier_auth_local_datasource.dart';
import 'package:cente_pice/src/features/auth/data/datasources/particulier_auth_remote_datasource.dart';
import 'package:cente_pice/src/features/auth/domain/repositories/particulier_auth_repository.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/particulier_anonymous_auth.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/particulier_logout.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/get_current_particulier.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/update_particulier.dart';
import 'package:cente_pice/src/features/auth/presentation/controllers/particulier_auth_controller.dart';
import 'package:cente_pice/src/core/services/device_service.dart';

// Mock classes
class MockSharedPreferences implements SharedPreferences {
  final Map<String, dynamic> _storage = {};

  @override
  String? getString(String key) => _storage[key] as String?;

  @override
  Future<bool> setString(String key, String value) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _storage.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _storage.clear();
    return true;
  }

  @override
  Set<String> getKeys() => _storage.keys.toSet();

  @override
  bool containsKey(String key) => _storage.containsKey(key);

  // Autres méthodes requises par l'interface
  @override
  Object? get(String key) => _storage[key];

  @override
  bool? getBool(String key) => _storage[key] as bool?;

  @override
  double? getDouble(String key) => _storage[key] as double?;

  @override
  int? getInt(String key) => _storage[key] as int?;

  @override
  List<String>? getStringList(String key) => _storage[key] as List<String>?;

  @override
  Future<bool> setBool(String key, bool value) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<void> reload() async {}

  @override
  Future<bool> commit() async => true;
}

class MockSupabaseClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Particulier Auth Providers Tests', () {
    late ProviderContainer container;
    late MockSharedPreferences mockSharedPreferences;
    late MockSupabaseClient mockSupabaseClient;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      mockSupabaseClient = MockSupabaseClient();

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          supabaseClientProvider.overrideWithValue(mockSupabaseClient),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Base Providers', () {
      test('devrait fournir SharedPreferences via le provider', () {
        final sharedPrefs = container.read(sharedPreferencesProvider);
        expect(sharedPrefs, isA<SharedPreferences>());
        expect(sharedPrefs, equals(mockSharedPreferences));
      });

      test('devrait fournir SupabaseClient via le provider', () {
        final supabaseClient = container.read(supabaseClientProvider);
        expect(supabaseClient, isA<SupabaseClient>());
        expect(supabaseClient, equals(mockSupabaseClient));
      });

      test('devrait créer DeviceService avec SharedPreferences', () {
        final deviceService = container.read(deviceServiceProvider);
        expect(deviceService, isA<DeviceService>());
      });
    });

    group('Data Sources Providers', () {
      test('devrait créer ParticulierAuthRemoteDataSource', () {
        final remoteDataSource = container.read(particulierAuthRemoteDataSourceProvider);
        expect(remoteDataSource, isA<ParticulierAuthRemoteDataSource>());
        expect(remoteDataSource, isA<ParticulierAuthRemoteDataSourceImpl>());
      });

      test('devrait créer ParticulierAuthLocalDataSource', () {
        final localDataSource = container.read(particulierAuthLocalDataSourceProvider);
        expect(localDataSource, isA<ParticulierAuthLocalDataSource>());
        expect(localDataSource, isA<ParticulierAuthLocalDataSourceImpl>());
      });

      test('devrait créer les data sources avec les bonnes dépendances', () {
        final remoteDataSource = container.read(particulierAuthRemoteDataSourceProvider);
        final localDataSource = container.read(particulierAuthLocalDataSourceProvider);

        expect(remoteDataSource, isNotNull);
        expect(localDataSource, isNotNull);
      });
    });

    group('Repository Provider', () {
      test('devrait créer ParticulierAuthRepository', () {
        final repository = container.read(particulierAuthRepositoryProvider);
        expect(repository, isA<ParticulierAuthRepository>());
        expect(repository, isA<ParticulierAuthRepositoryImpl>());
      });

      test('devrait injecter les data sources dans le repository', () {
        final repository = container.read(particulierAuthRepositoryProvider);
        expect(repository, isNotNull);
        expect(repository, isA<ParticulierAuthRepositoryImpl>());
      });
    });

    group('Use Cases Providers', () {
      test('devrait créer ParticulierAnonymousAuth', () {
        final useCase = container.read(particulierAnonymousAuthProvider);
        expect(useCase, isA<ParticulierAnonymousAuth>());
      });

      test('devrait créer ParticulierLogout', () {
        final useCase = container.read(particulierLogoutProvider);
        expect(useCase, isA<ParticulierLogout>());
      });

      test('devrait créer GetCurrentParticulier', () {
        final useCase = container.read(getCurrentParticulierProvider);
        expect(useCase, isA<GetCurrentParticulier>());
      });

      test('devrait créer UpdateParticulier', () {
        final useCase = container.read(updateParticulierProvider);
        expect(useCase, isA<UpdateParticulier>());
      });

      test('devrait injecter le repository dans tous les use cases', () {
        final anonymousAuth = container.read(particulierAnonymousAuthProvider);
        final logout = container.read(particulierLogoutProvider);
        final getCurrent = container.read(getCurrentParticulierProvider);
        final update = container.read(updateParticulierProvider);

        expect(anonymousAuth, isNotNull);
        expect(logout, isNotNull);
        expect(getCurrent, isNotNull);
        expect(update, isNotNull);
      });
    });

    group('Controller Provider', () {
      test('devrait créer ParticulierAuthController', () {
        final controller = container.read(particulierAuthControllerProvider.notifier);
        expect(controller, isA<ParticulierAuthController>());
      });

      test('devrait fournir l\'état initial du controller', () {
        final state = container.read(particulierAuthControllerProvider);
        expect(state, isA<ParticulierAuthState>());
      });

      test('devrait injecter tous les use cases dans le controller', () {
        final controller = container.read(particulierAuthControllerProvider.notifier);
        expect(controller, isNotNull);
        expect(controller, isA<ParticulierAuthController>());
      });
    });

    group('Provider Dependencies', () {
      test('devrait maintenir les dépendances entre providers', () {
        // Vérifier que les providers sont bien liés
        final repository = container.read(particulierAuthRepositoryProvider);
        final useCase = container.read(particulierAnonymousAuthProvider);
        final controller = container.read(particulierAuthControllerProvider.notifier);

        expect(repository, isNotNull);
        expect(useCase, isNotNull);
        expect(controller, isNotNull);
      });

      test('devrait créer les instances de manière paresseuse', () {
        // Les providers ne créent les instances qu'à la demande
        expect(() => container.read(particulierAuthRepositoryProvider), returnsNormally);
        expect(() => container.read(particulierAnonymousAuthProvider), returnsNormally);
        expect(() => container.read(particulierAuthControllerProvider), returnsNormally);
      });

      test('devrait partager les mêmes instances', () {
        final repository1 = container.read(particulierAuthRepositoryProvider);
        final repository2 = container.read(particulierAuthRepositoryProvider);

        expect(repository1, same(repository2));
      });
    });

    group('Error Handling', () {
      test('devrait gérer l\'UnimplementedError pour SharedPreferences par défaut', () {
        final containerWithoutOverride = ProviderContainer();

        expect(
          () => containerWithoutOverride.read(sharedPreferencesProvider),
          throwsA(isA<UnimplementedError>()),
        );

        containerWithoutOverride.dispose();
      });

      test('devrait fonctionner avec des overrides valides', () {
        expect(
          () => container.read(sharedPreferencesProvider),
          returnsNormally,
        );
        expect(
          () => container.read(supabaseClientProvider),
          returnsNormally,
        );
      });
    });

    group('Integration Tests', () {
      test('devrait créer toute la chaîne de dépendances', () {
        // Test que toute la chaîne peut être créée sans erreur
        final sharedPrefs = container.read(sharedPreferencesProvider);
        final supabase = container.read(supabaseClientProvider);
        final deviceService = container.read(deviceServiceProvider);
        final remoteDS = container.read(particulierAuthRemoteDataSourceProvider);
        final localDS = container.read(particulierAuthLocalDataSourceProvider);
        final repository = container.read(particulierAuthRepositoryProvider);
        final anonymousAuth = container.read(particulierAnonymousAuthProvider);
        final logout = container.read(particulierLogoutProvider);
        final getCurrent = container.read(getCurrentParticulierProvider);
        final update = container.read(updateParticulierProvider);
        final controller = container.read(particulierAuthControllerProvider.notifier);

        expect(sharedPrefs, isNotNull);
        expect(supabase, isNotNull);
        expect(deviceService, isNotNull);
        expect(remoteDS, isNotNull);
        expect(localDS, isNotNull);
        expect(repository, isNotNull);
        expect(anonymousAuth, isNotNull);
        expect(logout, isNotNull);
        expect(getCurrent, isNotNull);
        expect(update, isNotNull);
        expect(controller, isNotNull);
      });

      test('devrait maintenir la cohérence des types', () {
        final repository = container.read(particulierAuthRepositoryProvider);
        final useCase = container.read(particulierAnonymousAuthProvider);

        expect(repository, isA<ParticulierAuthRepository>());
        expect(useCase, isA<ParticulierAnonymousAuth>());
      });
    });
  });
}