# Documentation des Tests - Pièces d'Occasion

Cette documentation explique tous les tests présents dans notre application Flutter pour la vente de pièces automobiles d'occasion.

## 📊 Statistiques Actuelles

- **Total de tests :** 996 tests
- **Taux de réussite :** 100%
- **Couverture de code :** 53.11%
- **Dernière mise à jour :** 20/09/2025

## 📂 Structure des Tests

```
test/
├── unit/                    # Tests unitaires (logique métier)
│   ├── core/               # Services centraux
│   └── features/           # Fonctionnalités métier
├── widget/                 # Tests d'interface utilisateur
├── integration/            # Tests d'intégration end-to-end
└── docs/                   # Cette documentation
```

## 🎯 Types de Tests

### 1. Tests Unitaires (Unit Tests)
- Testent des fonctions/classes isolées
- Très rapides à exécuter
- Utilisent des mocks pour les dépendances
- **Localisation :** `test/unit/`

### 2. Tests de Widgets
- Testent l'interface utilisateur
- Simulent les interactions utilisateur
- Vérifient l'affichage des composants
- **Localisation :** `test/widget/`

### 3. Tests d'Intégration
- Testent les flux complets utilisateur
- Utilisent de vraies connexions
- Plus lents mais plus réalistes
- **Localisation :** `test/integration/`

## 🔍 Navigation dans cette Documentation

- [Tests des Services Core](./core-services.md) - DeviceService, RateLimiterService, etc.
- [Tests d'Authentification](./auth-tests.md) - Login, register, logout
- [Tests des Pièces Automobiles](./parts-tests.md) - Recherche, demandes, réponses
- [Tests des Widgets](./widget-tests.md) - Interface utilisateur
- [Tests d'Intégration](./integration-tests.md) - Flux complets

## ⚡ Commandes Rapides

```bash
# Exécuter tous les tests
flutter test

# Tests unitaires seulement
flutter test test/unit/

# Tests widgets seulement
flutter test test/widget/

# Tests avec couverture
flutter test --coverage

# Test d'un fichier spécifique
flutter test test/unit/core/services/device_service_test.dart
```

## 📈 Objectifs de Couverture

| Module | Couverture Actuelle | Objectif |
|--------|-------------------|----------|
| Services Core | 90%+ | Maintenir |
| Authentification | 70% | → 85% |
| Gestion Pièces | 60% | → 80% |
| Interface (Widgets) | 45% | → 60% |

## 🛠 Ajout de Nouveaux Tests

1. **Créer le fichier test :** `nom_fichier_test.dart`
2. **Suivre la convention :** [Arrange, Act, Assert](https://docs.flutter.dev/testing/unit-testing)
3. **Utiliser les mocks :** Pour isoler les dépendances
4. **Tester les cas limites :** Erreurs, valeurs nulles, etc.
5. **Documenter :** Expliquer ce que teste chaque test

## 🔧 Génération des Mocks

```bash
# Générer tous les mocks
dart run build_runner build

# Forcer la régénération
dart run build_runner build --delete-conflicting-outputs
```

## 📋 Bonnes Pratiques

- ✅ **Noms explicites :** `doit retourner utilisateur quand ID valide`
- ✅ **Tests indépendants :** Chaque test peut tourner seul
- ✅ **Assertions claires :** Une seule chose testée par test
- ✅ **Setup/Teardown :** Nettoyer après chaque test
- ❌ **Tests fragiles :** Éviter les dépendances externes
- ❌ **Tests lents :** Utiliser des mocks pour la rapidité