# Standards de Code - Pièces d'Occasion

## 🎯 Objectif

Maintenir un code de **qualité professionnelle**, **lisible**, et **maintenable** pour supporter 100 000+ utilisateurs.

---

## 📐 Architecture Standards

### Clean Architecture - Règles Strictes

```dart
// ❌ INTERDIT : UI appelle directement le Repository
class MyPage extends StatelessWidget {
  final repository = PartRepository();  // ❌ NON !

  void loadParts() {
    repository.fetchParts();  // ❌ Skip Use Case
  }
}

// ✅ CORRECT : UI → Controller → Use Case → Repository
class MyController extends StateNotifier<AsyncValue<Parts>> {
  final GetPartsUseCase _getPartsUseCase;

  Future<void> loadParts() async {
    final result = await _getPartsUseCase();  // ✅ Via Use Case
  }
}
```

### Séparation des Responsabilités

| Layer | Responsabilité | Ce qu'il NE DOIT PAS faire |
|-------|---------------|----------------------------|
| **Presentation** | UI, interactions utilisateur | ❌ Logique métier, appels réseau directs |
| **Domain** | Logique métier pure | ❌ Dépendances Flutter/Supabase, JSON |
| **Data** | Accès données, cache | ❌ Logique métier, UI |
| **Core** | Infrastructure partagée | ❌ Logique métier spécifique |

---

## 🏗️ Dart/Flutter Best Practices

### 1. Immutabilité avec Freezed

```dart
// ✅ CORRECT : Entités immuables
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String firstName,
  }) = _User;
}

// ❌ INTERDIT : Classes mutables pour entités
class User {
  String id;
  String email;  // ❌ Mutable !
}
```

### 2. Const Constructors

```dart
// ✅ CORRECT : Optimisation mémoire
const Text('Hello');
const SizedBox(height: 16);
const Icon(Icons.home);

// ❌ ÉVITER : Création d'objets inutiles
Text('Hello');  // ❌ Pas const
SizedBox(height: 16);  // ❌ Pas const
```

### 3. Null Safety

```dart
// ✅ CORRECT : Gestion explicite du null
String? nullableEmail;
String nonNullEmail = nullableEmail ?? 'default@email.com';

if (nullableEmail != null) {
  print(nullableEmail.toUpperCase());  // Safe
}

// ❌ INTERDIT : Force unwrap sans vérification
print(nullableEmail!.toUpperCase());  // ❌ Peut crasher !
```

### 4. Type Safety

```dart
// ✅ CORRECT : Types explicites
final List<User> users = [];
final Map<String, int> scores = {};

// ❌ ÉVITER : var/dynamic sans raison
var users = [];  // ❌ Type ambigu
dynamic scores = {};  // ❌ Perte de type safety
```

---

## 🎨 Naming Conventions

### Variables & Fonctions

```dart
// ✅ CORRECT : lowerCamelCase
final userName = 'John';
void fetchUserData() {}

// ❌ INTERDIT
final user_name = 'John';  // ❌ snake_case
void FetchUserData() {}    // ❌ PascalCase
```

### Classes & Enums

```dart
// ✅ CORRECT : PascalCase
class UserProfile {}
enum UserRole { admin, seller, buyer }

// ❌ INTERDIT
class userProfile {}  // ❌ lowerCamelCase
```

### Constants

```dart
// ✅ CORRECT : lowerCamelCase (Dart style)
const maxRetryAttempts = 3;
const primaryColor = Color(0xFF007AFF);

// ❌ ÉVITER : SCREAMING_CASE (style ancien)
const MAX_RETRY_ATTEMPTS = 3;  // ❌ Style C/Java
```

### Files

```dart
// ✅ CORRECT : snake_case
user_profile.dart
auth_controller.dart
login_as_particulier.dart

// ❌ INTERDIT
UserProfile.dart      // ❌ PascalCase
authController.dart   // ❌ camelCase
```

---

## 📝 Documentation

### DartDoc Format

```dart
/// Service de gestion des conversations en temps réel.
///
/// Gère les connexions WebSocket avec Supabase Realtime,
/// avec reconnexion automatique et gestion d'erreurs.
///
/// Exemple d'utilisation :
/// ```dart
/// final service = RealtimeService();
/// service.subscribeToConversation(
///   conversationId: 'conv-123',
///   onMessage: (message) => print(message.content),
/// );
/// ```
///
/// Voir aussi : [MessageService], [ConversationRepository]
class RealtimeService {
  /// Durée entre chaque tentative de reconnexion.
  ///
  /// Par défaut : 2 secondes
  final Duration reconnectDelay;

  /// S'abonne aux nouveaux messages d'une conversation.
  ///
  /// [conversationId] - ID de la conversation à écouter
  /// [onMessage] - Callback appelé à chaque nouveau message
  ///
  /// Throws [RealtimeException] si la connexion échoue
  void subscribeToConversation({
    required String conversationId,
    required Function(Message) onMessage,
  }) {
    // Implementation
  }
}
```

### Commentaires

```dart
// ✅ CORRECT : Commentaires utiles
// Workaround: Supabase RLS ne fonctionne pas avec batch inserts
// TODO: Retirer quand Supabase corrige le bug
// FIXME: Memory leak détecté ici (voir issue #123)

// ❌ ÉVITER : Commentaires évidents
final user = User();  // Create user  ❌ Redondant
i++;  // Increment i  ❌ Inutile
```

---

## 🧪 Testing Standards

### Test Naming

```dart
// ✅ CORRECT : Description claire
test('should return User when login is successful', () {});
test('should throw NetworkException when offline', () {});

// ❌ ÉVITER : Descriptions vagues
test('login test', () {});  // ❌ Pas assez descriptif
test('test1', () {});       // ❌ Incompréhensible
```

### AAA Pattern (Arrange-Act-Assert)

```dart
test('should return conversations for user', () async {
  // Arrange
  final mockRepo = MockConversationRepository();
  final useCase = GetConversationsUseCase(mockRepo);
  final mockConversations = [Conversation(id: '1')];
  when(mockRepo.getConversations(any))
      .thenAnswer((_) async => Right(mockConversations));

  // Act
  final result = await useCase('user-123');

  // Assert
  expect(result.isRight(), true);
  result.fold(
    (failure) => fail('Should not fail'),
    (conversations) => expect(conversations.length, 1),
  );
  verify(mockRepo.getConversations('user-123')).called(1);
});
```

### Coverage Minimale

| Module | Couverture Minimale |
|--------|---------------------|
| Use Cases | 90% |
| Repositories | 80% |
| Controllers | 75% |
| Services | 85% |
| Widgets | 60% |

---

## ⚡ Performance Standards

### Widgets Optimization

```dart
// ✅ CORRECT : Widget const
class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('Hello');  // ✅ Const
  }
}

// ❌ ÉVITER : Widgets inutilement reconstruits
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Hello');  // ❌ Reconstruit à chaque fois
  }
}
```

### ListView Performance

```dart
// ✅ CORRECT : ListView.builder pour grandes listes
ListView.builder(
  itemCount: 1000,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
);

// ❌ INTERDIT : ListView avec enfants générés (OOM)
ListView(
  children: List.generate(1000, (i) => ListTile(title: Text('Item $i'))),
);  // ❌ Crash avec grandes listes !
```

### Async Best Practices

```dart
// ✅ CORRECT : async/await avec gestion d'erreur
Future<void> loadData() async {
  try {
    state = const AsyncValue.loading();
    final data = await repository.fetchData();
    state = AsyncValue.data(data);
  } catch (e, st) {
    state = AsyncValue.error(e, st);
  }
}

// ❌ INTERDIT : .then() en cascade (callback hell)
repository.fetchData().then((data) {
  process(data).then((result) {
    save(result).then((saved) {
      // ❌ Illisible !
    });
  });
});
```

---

## 🔒 Security Standards

### Secrets Management

```dart
// ✅ CORRECT : Secrets dans .env
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

// ❌ INTERDIT : Secrets hardcodés
const supabaseUrl = 'https://abc123.supabase.co';  // ❌ Jamais !
const apiKey = 'sk-123456789';  // ❌ Dangereux !
```

### Input Validation

```dart
// ✅ CORRECT : Validation côté client ET serveur
class EmailValidator {
  static bool isValid(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}

// ❌ INTERDIT : Validation uniquement UI
if (emailController.text.isNotEmpty) {
  submit();  // ❌ Pas de validation format !
}
```

### SQL Injection Prevention

```dart
// ✅ CORRECT : Parameterized queries (Supabase fait ça automatiquement)
await supabase
    .from('users')
    .select()
    .eq('id', userId);  // ✅ Safe

// ❌ INTERDIT : String concatenation (si vous utilisez raw SQL)
final query = "SELECT * FROM users WHERE id = '$userId'";  // ❌ SQL Injection !
```

---

## 📊 Code Metrics

### Thresholds Acceptables

```dart
// Cyclomatic Complexity < 10
void processOrder(Order order) {
  // ❌ ÉVITER : Trop de if/else imbriqués
  if (order.isPaid) {
    if (order.isShipped) {
      if (order.isDelivered) {
        // ... 10 niveaux de profondeur ❌
      }
    }
  }

  // ✅ CORRECT : Early returns
  if (!order.isPaid) return;
  if (!order.isShipped) return;
  if (!order.isDelivered) return;
  // ... logique principale
}

// Longueur de fonction < 50 lignes
// Si > 50 lignes : refactoriser en fonctions plus petites

// Longueur de fichier < 300 lignes
// Si > 300 lignes : split en fichiers séparés
```

---

## 🛠️ Tools & Automation

### Linting - analysis_options.yaml

```yaml
linter:
  rules:
    - always_declare_return_types
    - avoid_print
    - prefer_const_constructors
    - prefer_const_declarations
    - use_key_in_widget_constructors
    - avoid_unnecessary_containers
    - sized_box_for_whitespace
    - sort_child_properties_last
```

### Pre-commit Hooks

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running Flutter analyze..."
flutter analyze
if [ $? -ne 0 ]; then
  echo "❌ Flutter analyze failed"
  exit 1
fi

echo "Running tests..."
flutter test
if [ $? -ne 0 ]; then
  echo "❌ Tests failed"
  exit 1
fi

echo "Running dart format..."
dart format lib/ test/
git add lib/ test/

echo "✅ All checks passed"
```

### CI/CD Quality Gates

```yaml
# .github/workflows/quality-check.yml
- name: Analyze
  run: flutter analyze

- name: Check formatting
  run: dart format --set-exit-if-changed lib/ test/

- name: Run tests with coverage
  run: flutter test --coverage

- name: Check coverage threshold
  run: |
    lcov --summary coverage/lcov.info | grep "lines" | grep -oP '\d+\.\d+' | awk '{if ($1 < 80) exit 1}'
```

---

## 📚 Ressources

### Documentation Officielle
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://flutter.dev/docs/perf/best-practices)
- [Riverpod Best Practices](https://riverpod.dev/docs/concepts/reading)

### Livres Recommandés
- Clean Architecture - Robert C. Martin
- Clean Code - Robert C. Martin
- Flutter Complete Reference - Alberto Miola

---

## ✅ Code Review Checklist

Avant de soumettre une PR, vérifier :

- [ ] `flutter analyze` sans warnings
- [ ] `dart format` appliqué
- [ ] Tests unitaires écrits (couverture > seuil)
- [ ] Documentation ajoutée (DartDoc)
- [ ] Pas de secrets hardcodés
- [ ] Respect Clean Architecture
- [ ] Widgets const où possible
- [ ] Gestion d'erreurs appropriée
- [ ] Logs structurés (pas de print())
- [ ] Pas de TODO/FIXME sans issue GitHub

---

**Dernière mise à jour** : 30/09/2025
**Mainteneur** : Tech Lead
**Version** : 1.0.0