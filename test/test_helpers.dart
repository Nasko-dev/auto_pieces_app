import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helper class pour créer des mocks et utilitaires de test
class TestHelpers {
  /// Crée un container Riverpod pour les tests avec des overrides
  static ProviderContainer createContainer({
    List<Override> overrides = const [],
  }) {
    return ProviderContainer(
      overrides: overrides,
    );
  }

  /// Mock basique pour les tests
  static T createMock<T extends Object>() {
    return MockClass<T>() as T;
  }
}

/// Classe générique pour créer des mocks
class MockClass<T> extends Mock {}

/// Extensions utiles pour les tests
extension TestExtensions on ProviderContainer {
  /// Helper pour lire un provider et attendre sa valeur
  Future<T> readAsync<T>(ProviderBase<AsyncValue<T>> provider) async {
    final asyncValue = read(provider);
    return asyncValue.when(
      data: (data) => data,
      loading: () => throw StateError('Provider is loading'),
      error: (error, stack) => throw error,
    );
  }
}
