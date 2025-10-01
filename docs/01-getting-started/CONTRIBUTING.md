# Guide de Contribution - Pièces d'Occasion

## 👋 Bienvenue Contributeur !

Merci de votre intérêt pour contribuer à **Pièces d'Occasion**. Ce guide vous aidera à soumettre des contributions de qualité.

---

## 🚀 Quick Start

```bash
# 1. Fork le projet
# 2. Clone votre fork
git clone https://github.com/YOUR_USERNAME/auto_pieces_app.git
cd auto_pieces_app

# 3. Créer une branche
git checkout -b feature/ma-super-feature

# 4. Installer dépendances
flutter pub get
dart run build_runner build

# 5. Développer + Tests
flutter test

# 6. Commit
git commit -m "ajout: ma super feature"

# 7. Push
git push origin feature/ma-super-feature

# 8. Créer Pull Request sur GitHub
```

---

## 🌳 Git Workflow

### Branches

```
main          Production (protégée)
  ↑
dev           Développement principal (protégée)
  ↑
feature/*     Nouvelles fonctionnalités
bugfix/*      Corrections de bugs
hotfix/*      Corrections urgentes production
```

### Règles de Nommage

```bash
# Features
feature/messaging-system
feature/seller-dashboard
feature/advanced-search

# Bugfixes
bugfix/login-crash-on-ios
bugfix/conversation-scroll-issue

# Hotfixes (production uniquement)
hotfix/critical-security-patch
hotfix/payment-gateway-error
```

### Commits Conventionnels

**Format** : `type: description`

```bash
# Types
ajout: Nouvelle fonctionnalité
correction: Bug fix
refactorisation: Refactoring (pas de changement fonctionnel)
docs: Documentation
style: Formatage, points-virgules, etc.
test: Ajout ou modification de tests
tâche: Configuration, build, CI/CD

# Exemples
git commit -m "ajout: système de notifications push"
git commit -m "correction: crash au démarrage sur Android 12"
git commit -m "refactorisation: simplification du ConversationController"
git commit -m "docs: ajout documentation API Supabase"
git commit -m "test: couverture AuthController à 90%"
```

**Signature** :
```bash
# Tous les commits doivent être signés
git commit -m "ajout: feature X" --signoff
```

---

## 📝 Pull Requests

### Template PR

```markdown
## 📋 Description

[Décrivez les changements en quelques phrases]

## 🎯 Type de changement

- [ ] Nouvelle fonctionnalité (feature)
- [ ] Correction de bug (bugfix)
- [ ] Refactoring
- [ ] Documentation
- [ ] Tests

## ✅ Checklist

- [ ] Code suit les [standards du projet](./CODE_STANDARDS.md)
- [ ] Tests ajoutés/mis à jour (couverture maintenue)
- [ ] `flutter analyze` sans warnings
- [ ] `dart format` appliqué
- [ ] Documentation mise à jour si nécessaire
- [ ] Pas de secrets hardcodés
- [ ] PR liée à une issue (#123)

## 🧪 Tests

[Décrivez comment vous avez testé les changements]

- [ ] Tests unitaires
- [ ] Tests widgets
- [ ] Tests manuels sur simulateur/device
- [ ] Tests sur iOS
- [ ] Tests sur Android

## 📸 Screenshots (si UI)

[Ajouter captures d'écran avant/après]

## 📚 Documentation

- Issue liée : #123
- Docs mises à jour : Oui/Non

## 🔗 Liens

- Figma : [lien si applicable]
- Ticket Jira : [lien si applicable]
```

### Processus de Review

1. **Auto-Review** : Relire votre code avant de soumettre
2. **CI Checks** : Tous les checks doivent passer (tests, analyze, format)
3. **Peer Review** : Minimum 1 approbation requise
4. **Changes Requested** : Adresser tous les commentaires
5. **Approval** : PR approuvée → Merge dans `dev`

### Merge Strategy

```bash
# dev → feature : Rebase
git checkout feature/my-feature
git rebase dev

# feature → dev : Squash and Merge (via GitHub)
# dev → main : Merge (releases seulement)
```

---

## 🏗️ Standards de Code

**Voir [CODE_STANDARDS.md](./CODE_STANDARDS.md) pour détails complets**

### Checklist Rapide

- [ ] Clean Architecture respectée (Presentation → Domain → Data)
- [ ] Widgets const où possible
- [ ] Null safety (pas de `!` non sécurisés)
- [ ] DartDoc pour fonctions publiques
- [ ] Gestion d'erreurs avec Either<Failure, Success>
- [ ] Pas de `print()` (utiliser `AppLogger`)
- [ ] Tests avec AAA pattern (Arrange-Act-Assert)

---

## 🧪 Tests Requis

### Couverture Minimale

| Type de code | Couverture requise |
|--------------|-------------------|
| Use Cases | 90% |
| Repositories | 80% |
| Controllers | 75% |
| Services | 85% |

### Écrire des Tests

```dart
// test/features/auth/domain/usecases/login_test.dart
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
      when(mockRepo.login(any, any))
          .thenAnswer((_) async => Right(mockUser));

      // Act
      final result = await useCase('test@test.com', 'password');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (user) => expect(user.email, 'test@test.com'),
      );
      verify(mockRepo.login('test@test.com', 'password')).called(1);
    });

    test('should return NetworkFailure when offline', () async {
      // Arrange
      when(mockRepo.login(any, any))
          .thenThrow(NetworkException());

      // Act
      final result = await useCase('test@test.com', 'password');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should fail'),
      );
    });
  });
}
```

---

## 📚 Documentation

### Quand Documenter ?

- ✅ **Nouvelles features** : Ajouter dans docs approprié
- ✅ **API changes** : Mettre à jour API_REFERENCE.md
- ✅ **Architecture changes** : Mettre à jour ARCHITECTURE.md
- ✅ **Breaking changes** : Documenter dans CHANGELOG.md

### DartDoc

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
class RealtimeService {
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

---

## 🐛 Reporting Bugs

### Template Issue

```markdown
## 🐛 Description du Bug

[Description claire du problème]

## 📱 Environnement

- OS : iOS 17.1 / Android 14
- Device : iPhone 15 Pro / Pixel 8
- Version app : 1.2.0

## 🔄 Étapes pour Reproduire

1. Ouvrir l'app
2. Aller dans Conversations
3. Cliquer sur une conversation
4. Crash

## ✅ Comportement Attendu

[Ce qui devrait se passer]

## ❌ Comportement Actuel

[Ce qui se passe réellement]

## 📸 Screenshots / Logs

[Ajouter si applicable]

## 💡 Solutions Potentielles

[Si vous avez des idées]
```

---

## 💡 Feature Requests

### Template

```markdown
## 💡 Feature Request

[Décrivez la fonctionnalité souhaitée]

## 🎯 Problème Résolu

[Quel problème utilisateur cela résout-il ?]

## 📝 Solution Proposée

[Comment implémenteriez-vous cela ?]

## 🌟 Alternatives Considérées

[Autres approches possibles]

## 📊 Impact Utilisateur

- Utilisateurs concernés : [Tous / Vendeurs / Particuliers]
- Priorité : [Haute / Moyenne / Basse]
```

---

## 🎨 UI/UX Contributions

### Design System

- Respecter [Figma designs](lien-figma)
- Utiliser composants du design system (`shared/presentation/widgets/`)
- Couleurs : `AppColors` uniquement
- Typography : `Theme.of(context).textTheme`

### Accessibilité

```dart
// ✅ Toujours ajouter des Semantics
Semantics(
  label: 'Bouton de connexion',
  child: ElevatedButton(
    onPressed: login,
    child: const Text('Se connecter'),
  ),
);

// ✅ Contraste suffisant (WCAG AA)
// ✅ Taille minimale touche : 48x48dp
// ✅ Support navigation clavier/screen reader
```

---

## 🔐 Sécurité

### Reporting Vulnerabilities

**NE PAS créer d'issue publique**

Envoyer email à : security@piecesdoccasion.fr

Inclure :
- Description de la vulnérabilité
- Étapes pour reproduire
- Impact potentiel
- Solution proposée (optionnel)

### Secure Coding

- ❌ Jamais de secrets dans le code
- ✅ Validation input côté client ET serveur
- ✅ Parameterized queries (pas de SQL injection)
- ✅ HTTPS uniquement
- ✅ Encryption données sensibles

---

## 📞 Support

### Channels de Communication

| Canal | Usage | Réponse |
|-------|-------|---------|
| **GitHub Issues** | Bugs, features, questions techniques | 1-2 jours |
| **GitHub Discussions** | Questions générales, idées | Variable |
| **Slack #dev-pieces-occasion** | Discussion temps réel (équipe interne) | Immédiat |
| **Email dev@piecesdoccasion.fr** | Questions privées | 2-3 jours |

### Code of Conduct

- ✅ Respecter les autres contributeurs
- ✅ Communication constructive et professionnelle
- ✅ Accepter la critique avec ouverture
- ❌ Harcèlement, discrimination, comportement toxique

**Toute violation sera sanctionnée (warning → ban)**

---

## 🏆 Reconnaissance

### Contributors Hall of Fame

Les contributeurs significatifs seront :
- Mentionnés dans le CHANGELOG
- Ajoutés à la section Contributors du README
- Invités aux événements équipe (si local)

### Types de Contributions Valorisées

- 🐛 Bug fixes
- ✨ Nouvelles features
- 📚 Documentation
- 🧪 Tests
- 🎨 Améliorations UI/UX
- ⚡ Optimisations performance
- 🔒 Améliorations sécurité

---

## 📋 Checklist Avant Soumission

- [ ] Branche créée depuis `dev` à jour
- [ ] Code respecte [CODE_STANDARDS.md](./CODE_STANDARDS.md)
- [ ] `flutter analyze` passe sans warnings
- [ ] `dart format` appliqué
- [ ] Tests écrits et passent
- [ ] Couverture maintenue/améliorée
- [ ] Documentation mise à jour
- [ ] Commits bien formatés et signés
- [ ] PR description complète
- [ ] Screenshots ajoutés (si UI)
- [ ] Pas de secrets hardcodés

---

## 🚀 Processus de Release

**Contributeurs externes** : Vos PRs seront mergées dans `dev`.

**Releases** (équipe core uniquement) :
1. `dev` → `main` après sprint de 2 semaines
2. Tag version (ex: `v1.2.0`)
3. Génération CHANGELOG
4. Déploiement iOS/Android/Web
5. Annonce release notes

---

## 📚 Ressources

### Documentation Projet
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Architecture détaillée
- [CODE_STANDARDS.md](./CODE_STANDARDS.md) - Standards de code
- [API_REFERENCE.md](./API_REFERENCE.md) - API Reference
- [ONBOARDING.md](./ONBOARDING.md) - Guide développeur

### Ressources Externes
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://flutter.dev/docs/perf/best-practices)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod Documentation](https://riverpod.dev)

---

**Merci de contribuer à Pièces d'Occasion ! 🎉**

**Dernière mise à jour** : 30/09/2025
**Mainteneur** : Équipe Core
**Version** : 1.0.0