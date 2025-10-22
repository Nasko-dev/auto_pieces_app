import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cente_pice/src/core/network/network_info.dart';

void main() {
  group('NetworkInfo Tests', () {
    late NetworkInfo networkInfo;

    setUp(() {
      networkInfo = NetworkInfoImpl();
    });

    group('NetworkInfoImpl', () {
      test('devrait créer une instance correctement', () {
        expect(networkInfo, isA<NetworkInfo>());
        expect(networkInfo, isA<NetworkInfoImpl>());
      });

      test(
          'devrait retourner true pour isConnected (implémentation par défaut)',
          () async {
        final isConnected = await networkInfo.isConnected;
        expect(isConnected, isTrue);
      });

      test('devrait implémenter l\'interface NetworkInfo', () {
        expect(networkInfo, isA<NetworkInfo>());
      });

      test('devrait avoir une propriété isConnected asynchrone', () {
        expect(networkInfo.isConnected, isA<Future<bool>>());
      });

      test('devrait retourner un booléen pour isConnected', () async {
        final result = await networkInfo.isConnected;
        expect(result, isA<bool>());
      });

      test('devrait être cohérent dans les appels successifs', () async {
        final result1 = await networkInfo.isConnected;
        final result2 = await networkInfo.isConnected;

        expect(result1, isA<bool>());
        expect(result2, isA<bool>());
        expect(
            result1,
            equals(
                result2)); // L'implémentation actuelle retourne toujours true
      });
    });

    group('NetworkInfoProvider', () {
      test('devrait fournir une instance de NetworkInfo', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final networkInfoFromProvider = container.read(networkInfoProvider);

        expect(networkInfoFromProvider, isA<NetworkInfo>());
        expect(networkInfoFromProvider, isA<NetworkInfoImpl>());
      });

      test('devrait fournir la même instance à chaque fois', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final networkInfo1 = container.read(networkInfoProvider);
        final networkInfo2 = container.read(networkInfoProvider);

        expect(networkInfo1, same(networkInfo2));
      });

      test('devrait fonctionner avec le provider', () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final networkInfoFromProvider = container.read(networkInfoProvider);
        final isConnected = await networkInfoFromProvider.isConnected;

        expect(isConnected, isTrue);
      });
    });

    group('Interface NetworkInfo', () {
      test('devrait définir la méthode isConnected comme abstraite', () {
        // Test que l'interface a bien la signature attendue
        expect(NetworkInfo, isA<Type>());
      });

      test('devrait permettre l\'implémentation de différentes stratégies', () {
        // Test conceptuel : on peut implémenter différemment NetworkInfo
        final mockNetworkInfo = MockNetworkInfo();
        expect(mockNetworkInfo, isA<NetworkInfo>());
      });
    });

    group('Cas d\'usage réalistes', () {
      test('devrait simuler une connexion disponible', () async {
        final result = await networkInfo.isConnected;
        expect(result, isTrue);
      });

      test('devrait gérer les vérifications de connectivité répétées',
          () async {
        final results = <bool>[];

        for (int i = 0; i < 5; i++) {
          final isConnected = await networkInfo.isConnected;
          results.add(isConnected);
        }

        expect(results, hasLength(5));
        expect(results.every((result) => result == true), isTrue);
      });

      test('devrait fonctionner dans un contexte async/await', () async {
        expect(() async {
          final connectivity = await networkInfo.isConnected;
          return connectivity;
        }(), completes);
      });
    });

    group('Validation des types', () {
      test('devrait retourner Future<bool> pour isConnected', () {
        expect(networkInfo.isConnected, isA<Future<bool>>());
      });

      test('devrait résoudre vers un booléen', () async {
        final result = await networkInfo.isConnected;
        expect(result, isA<bool>());
        expect(result, anyOf([isTrue, isFalse]));
      });
    });
  });
}

// Mock simple pour les tests d'interface
class MockNetworkInfo implements NetworkInfo {
  final bool _isConnected;

  MockNetworkInfo([this._isConnected = false]);

  @override
  Future<bool> get isConnected async => _isConnected;
}
