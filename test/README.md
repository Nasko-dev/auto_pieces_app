# Tests - Pièces d'Occasion

Ce dossier contient l'ensemble des tests pour l'application Pièces d'Occasion, organisés selon les meilleures pratiques Flutter et Clean Architecture.

## 📁 Structure des Tests

```
test/
├── README.md                      # Ce fichier
├── test_helpers.dart              # Utilitaires et helpers pour tous les tests
├── mocks/                         # Mocks réutilisables
├── unit/                          # Tests unitaires
│   ├── core/                      # Tests du core (services, utils, etc.)
│   └── features/                  # Tests des features
│       ├── auth/
│       │   ├── domain/
│       │   │   ├── usecases/      # Tests des use cases
│       │   │   ├── repositories/  # Tests des interfaces repositories
│       │   │   └── entities/      # Tests des entités
│       │   ├── data/
│       │   │   ├── repositories/  # Tests des implémentations repositories
│       │   │   ├── datasources/   # Tests des datasources
│       │   │   └── models/        # Tests des modèles
│       │   └── presentation/
│       │       ├── controllers/   # Tests des controllers
│       │       └── widgets/       # Tests des widgets
│       └── parts/                 # Structure similaire pour parts
├── widget/                        # Tests de widgets
├── integration/                   # Tests d'intégration
└── mocks.dart                     # Mocks générés par Mockito
```

## 🧪 Types de Tests

### Tests Unitaires (`test/unit/`)

Tests isolés qui vérifient le comportement d'une seule unité de code :

- **Use Cases** : Logique métier et validation des paramètres
- **Repositories** : Logique de gestion des données et erreurs
- **Controllers** : Gestion d'état et interactions utilisateur
- **Services** : Services core de l'application

### Tests de Widgets (`test/widget/`)

Tests qui vérifient l'interface utilisateur et les interactions :

- Rendu correct des widgets
- Interactions utilisateur (tap, scroll, etc.)
- États de loading, erreur, succès
- Navigation entre pages

### Tests d'Intégration (`test/integration/`)

Tests end-to-end qui vérifient les flux complets :

- Flux d'authentification complet
- Création et gestion des demandes de pièces
- Communication avec les APIs réelles
- Performance et timeouts

## 🚀 Commandes de Test

### Exécuter tous les tests
```bash
flutter test
```

### Tests unitaires uniquement
```bash
flutter test test/unit/
```

### Tests d'une feature spécifique
```bash
flutter test test/unit/features/auth/
```

### Tests avec couverture
```bash
flutter test --coverage
```

### Tests d'intégration
```bash
flutter test integration_test/
```

### Générer les mocks
```bash
dart run build_runner build
```

## 📊 Couverture de Tests

Objectifs de couverture :

- **Use Cases** : 100% (logique métier critique)
- **Repositories** : 95% (gestion des données)
- **Controllers** : 90% (logique UI)
- **Services** : 95% (services core)
- **Global** : >80%

Pour générer le rapport de couverture :

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 🛠️ Configuration et Helpers

### Test Helpers (`test/test_helpers.dart`)

Utilitaires communs pour tous les tests :

```dart
// Créer un container Riverpod pour les tests
final container = TestHelpers.createContainer();

// Créer des mocks typés
final mockRepository = TestHelpers.createMock<AuthRepository>();

// Lire une valeur async d'un provider
final value = await container.readAsync(myProvider);
```

### Mocks

Nous utilisons **Mockito** pour créer des mocks :

```dart
@GenerateMocks([AuthRepository, NetworkInfo])
void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });
}
```

## 📝 Conventions de Test

### Nomenclature

- Fichiers de test : `nom_classe_test.dart`
- Classes de test : `NomClasseTest`
- Méthodes de test : descriptions en français

### Structure des tests

```dart
group('NomDeLaClasse', () {
  late ClasseSousTest instance;
  late MockDependency mockDependency;

  setUp(() {
    // Configuration avant chaque test
  });

  setUpAll(() {
    // Configuration une seule fois pour tout le groupe
  });

  group('nomDeLaMethode', () {
    test('doit retourner X quand Y', () async {
      // arrange - Préparation des données

      // act - Exécution de l'action

      // assert - Vérification du résultat
    });
  });
});
```

### Assertions

Privilégier des assertions descriptives :

```dart
// ✅ Bon
expect(result.isRight(), true);
expect(result.fold((l) => l, (r) => null), isA<ValidationFailure>());

// ❌ Éviter
expect(result, anything);
```

## 🎯 Tests Prioritaires

### À tester en priorité :

1. **Use Cases** - Logique métier critique
2. **Auth Controllers** - Sécurité et état utilisateur
3. **Repository Implementations** - Gestion des données
4. **Navigation** - Flux utilisateur

### Scénarios critiques :

- Authentification (succès, échec, validation)
- Création de demandes de pièces
- Gestion des erreurs réseau
- États de loading et erreur
- Validation des formulaires

## 🐛 Debug et Troubleshooting

### Tests qui échouent

1. Vérifier que les mocks sont correctement configurés
2. S'assurer que `setUp()` est appelé
3. Vérifier les imports et dépendances
4. Exécuter `dart run build_runner build` si nécessaire

### Mocks non générés

```bash
# Nettoyer et régénérer
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Tests lents

- Éviter les vraies connexions réseau dans les tests unitaires
- Utiliser des mocks pour toutes les dépendances externes
- Paralléliser l'exécution avec `--concurrency=4`

## 🔧 Configuration CI/CD

Les tests doivent passer dans la CI avant tout merge :

```yaml
# .github/workflows/tests.yml
- name: Run tests
  run: flutter test --coverage

- name: Check coverage
  run: |
    dart pub global activate coverage
    dart pub global run coverage:format_coverage \
      --lcov --in=coverage --out=coverage/lcov.info
```

## 📚 Ressources

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Riverpod Testing](https://riverpod.dev/docs/cookbooks/testing)
- [Clean Architecture Testing](https://blog.cleancoder.com/uncle-bob/2017/05/05/TestDefinitions.html)

---

**Dernière mise à jour :** ${DateTime.now().toString().split(' ')[0]}

Pour toute question sur les tests, consulter ce README ou contacter l'équipe de développement.