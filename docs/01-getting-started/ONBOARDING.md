# Guide d'Onboarding - Pièces d'Occasion

## 👋 Bienvenue dans l'équipe !

Ce guide vous permettra de devenir opérationnel en **moins de 2 heures** sur le projet **Pièces d'Occasion**.

---

## 🎯 Jour 1 : Setup Environnement (1-2h)

### Étape 1 : Prérequis (30 min)

```bash
# Vérifier les installations
flutter doctor -v
dart --version
git --version

# Cloner le repository
git clone https://github.com/Nasko-dev/auto_pieces_app.git
cd auto_pieces_app

# Installer dépendances
flutter pub get
```

**Versions requises** :
- Flutter : >= 3.27.0
- Dart : >= 3.6.0
- VS Code ou Android Studio

### Étape 2 : Configuration (20 min)

1. **Copier `.env.example` → `.env`**
```bash
cp .env.example .env
```

2. **Remplir les clés** (demander à l'équipe) :
```env
SUPABASE_URL=https://...
SUPABASE_ANON_KEY=...
TECALLIANCE_API_KEY=...
ONESIGNAL_APP_ID=...
```

3. **Générer le code**
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Étape 3 : Premier Lancement (10 min)

```bash
# Lancer l'app
flutter run

# Ou spécifier device
flutter run -d chrome     # Web
flutter run -d emulator   # Android
flutter run -d simulator  # iOS
```

**Vous devriez voir** : L'écran de bienvenue de l'app

---

## 📚 Jour 1-2 : Comprendre l'Architecture (2-3h)

### Lecture Obligatoire

1. **[ARCHITECTURE.md](./ARCHITECTURE.md)** (30 min)
   - Clean Architecture
   - Separation of Concerns
   - Flux de données

2. **[DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md)** (20 min)
   - Structure des tables
   - Relations
   - RLS Policies

3. **[API_REFERENCE.md](./API_REFERENCE.md)** (30 min)
   - Endpoints Supabase
   - Services Core
   - Error Handling

### Explorer le Code (1h)

```bash
# Structure du projet
lib/src/
├── core/           # Services fondamentaux
├── features/       # Fonctionnalités métier
│   ├── auth/       # Authentification
│   └── parts/      # Gestion pièces
└── shared/         # Composants réutilisables

# Fichiers clés à lire
lib/src/core/providers/providers.dart               # Dependency Injection
lib/src/features/auth/presentation/controllers/     # State Management
lib/src/features/parts/domain/usecases/            # Business Logic
```

**Exercice pratique** : Tracer le flux complet d'une authentification du UI au backend.

---

## 🛠️ Jour 2-3 : Première Contribution (3-4h)

### Tâche Guidée : Ajouter un Champ à l'Entité User

**Objectif** : Ajouter un champ `phone` à l'entité `User`

#### 1. Domain Layer (15 min)

```dart
// lib/src/features/auth/domain/entities/user.dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? phone,  // ← NOUVEAU
  }) = _User;
}
```

#### 2. Data Layer (15 min)

```dart
// lib/src/features/auth/data/models/user_model.dart
@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;  // ← NOUVEAU

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  User toEntity() => User(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    phone: phone,  // ← NOUVEAU
  );
}
```

#### 3. Générer Code (2 min)

```bash
dart run build_runner build --delete-conflicting-outputs
```

#### 4. Tests (20 min)

```dart
// test/features/auth/domain/entities/user_test.dart
test('User entity should include phone', () {
  final user = User(
    id: '123',
    email: 'test@test.com',
    firstName: 'John',
    lastName: 'Doe',
    phone: '0601020304',  // ← NOUVEAU
  );

  expect(user.phone, '0601020304');
});
```

#### 5. Commit (5 min)

```bash
git checkout -b feature/add-user-phone
git add .
git commit -m "ajout: champ téléphone à l'entité User"
git push origin feature/add-user-phone
```

#### 6. Pull Request (10 min)

1. Aller sur GitHub
2. Créer Pull Request vers `dev`
3. Remplir description :
   ```markdown
   ## Changements
   - Ajout du champ `phone` à l'entité User
   - Mise à jour du model UserModel
   - Tests ajoutés

   ## Tests
   - [x] Tests unitaires passent
   - [x] Flutter analyze sans erreurs
   ```

---

## 🎓 Jour 3-5 : Approfondissement (variable)

### Patterns à Maîtriser

#### 1. State Management avec Riverpod

```dart
// Provider simple
final myProvider = Provider<MyService>((ref) {
  return MyService();
});

// StateNotifier pour état complexe
class MyController extends StateNotifier<AsyncValue<Data>> {
  MyController(this._useCase) : super(const AsyncValue.loading());

  Future<void> loadData() async {
    state = const AsyncValue.loading();
    try {
      final data = await _useCase();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

#### 2. Use Cases Pattern

```dart
// Un Use Case = Une action métier
class GetConversationsUseCase {
  final ConversationRepository _repository;

  Future<Either<Failure, List<Conversation>>> call(String userId) async {
    return await _repository.getConversations(userId);
  }
}
```

#### 3. Either Pattern (Error Handling)

```dart
final result = await useCase();

result.fold(
  (failure) {
    // Gestion erreur
    if (failure is NetworkFailure) {
      showError('Pas de connexion');
    }
  },
  (data) {
    // Succès
    updateUI(data);
  },
);
```

### Features à Explorer

1. **Authentification** : `lib/src/features/auth/`
2. **Conversations** : `lib/src/features/parts/presentation/pages/conversations/`
3. **Services Core** : `lib/src/core/services/`

---

## 🤝 Workflow de Développement

### Git Workflow

```bash
# 1. Toujours partir de dev à jour
git checkout dev
git pull origin dev

# 2. Créer feature branch
git checkout -b feature/nom-de-la-feature

# 3. Développer, committer régulièrement
git add .
git commit -m "ajout: nouvelle fonctionnalité X"

# 4. Push et créer PR
git push origin feature/nom-de-la-feature

# 5. Code Review → Merge dans dev

# 6. dev → main (releases)
```

### Conventions de Commits

```
ajout: Nouvelle fonctionnalité
correction: Bug fix
refactorisation: Refactoring
docs: Documentation
style: Formatage
test: Tests
tâche: Configuration, build
```

### Code Review

**Votre PR sera reviewée sur** :
- ✅ Respect de l'architecture Clean
- ✅ Tests unitaires présents
- ✅ Pas de warnings `flutter analyze`
- ✅ Code formaté (`dart format`)
- ✅ Documentation des fonctions publiques

---

## 🧪 Tests - Best Practices

### Exécuter les Tests

```bash
# Tous les tests
flutter test

# Tests spécifiques
flutter test test/features/auth/

# Avec couverture
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Écrire un Test

```dart
void main() {
  group('LoginAsParticulierUseCase', () {
    late MockParticulierAuthRepository mockRepo;
    late LoginAsParticulierUseCase useCase;

    setUp(() {
      mockRepo = MockParticulierAuthRepository();
      useCase = LoginAsParticulierUseCase(mockRepo);
    });

    test('should return User on successful login', () async {
      // Arrange
      final mockUser = User(id: '123', email: 'test@test.com', ...);
      when(mockRepo.login(any, any)).thenAnswer((_) async => Right(mockUser));

      // Act
      final result = await useCase('test@test.com', 'password');

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.login('test@test.com', 'password')).called(1);
    });
  });
}
```

---

## 🐛 Debugging

### Outils

```bash
# DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Logs
flutter logs

# Analyse mémoire/performance
flutter run --profile
```

### Breakpoints VS Code

1. Cliquer dans la marge gauche (point rouge)
2. F5 pour lancer en mode debug
3. F10 : Step over
4. F11 : Step into
5. Shift+F11 : Step out

### Logs Structurés

```dart
// Utiliser AppLogger
AppLogger.info('User logged in', metadata: {'userId': user.id});
AppLogger.error('Failed to fetch', error: e, stackTrace: st);
```

---

## 📞 Ressources & Aide

### Documentation Interne

- [ARCHITECTURE.md](./ARCHITECTURE.md) - Architecture détaillée
- [API_REFERENCE.md](./API_REFERENCE.md) - Référence API
- [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md) - Schéma BDD
- [CODE_STANDARDS.md](./CODE_STANDARDS.md) - Standards de code
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Guide de contribution

### Personnes Ressources

- **Architecture** : Tech Lead
- **Backend/Supabase** : Backend Team
- **UI/UX** : Design Team
- **DevOps/CI/CD** : DevOps Team

### Canaux Communication

- **Slack** : #dev-pieces-occasion
- **GitHub** : Issues & Discussions
- **Meetings** : Daily Standup 10h, Sprint Planning bi-hebdomadaire

---

## ✅ Checklist d'Onboarding Complété

- [ ] Environnement configuré et app lancée
- [ ] Documentation architecture lue
- [ ] Code exploré (core, features)
- [ ] Première contribution réussie (PR mergée)
- [ ] Tests écrits et exécutés
- [ ] Git workflow maîtrisé
- [ ] Riverpod patterns compris
- [ ] Use Cases pattern appliqué
- [ ] Code review participé

**Félicitations ! Vous êtes prêt à contribuer pleinement au projet ! 🎉**

---

## 🚀 Prochaines Étapes

### Semaine 1
- Prendre une issue "Good First Issue" sur GitHub
- Participer activement aux code reviews
- Poser des questions (pas de question bête !)

### Mois 1
- Maîtriser une feature complète (auth ou parts)
- Contribuer à la documentation
- Proposer des améliorations

### Mois 3
- Mentorer un nouveau développeur
- Lead une feature complète
- Participer aux décisions d'architecture

---

**Dernière mise à jour** : 30/09/2025
**Mainteneur** : Équipe RH & Tech Lead
**Version** : 1.0.0