# Documentation Technique - Pièces d'Occasion

Cette documentation complète couvre tous les aspects techniques de notre application Flutter pour la vente de pièces automobiles d'occasion.

## 📂 Structure de la Documentation

```
docs/
├── README.md                    # ← Vous êtes ici
├── tests/                      # Documentation des tests
│   ├── README.md              # Vue d'ensemble des tests
│   ├── core-services.md       # Tests des services fondamentaux
│   ├── auth-tests.md          # Tests d'authentification
│   ├── parts-tests.md         # Tests gestion pièces
│   ├── widget-tests.md        # Tests interface utilisateur
│   └── integration-tests.md   # Tests end-to-end
└── workflows/                  # Documentation CI/CD
    ├── README.md              # Vue d'ensemble workflows
    ├── quick-check-workflow.md # Workflow développement rapide
    ├── fast-tests-workflow.md # Workflow PR optimisé
    └── full-ci-workflow.md    # Workflow production complet
```

## 🎯 Points d'Entrée par Rôle

### 👨‍💻 Développeur
**Vous codez au quotidien :**
- [Tests des Services Core](./tests/core-services.md) - DeviceService, RateLimiterService
- [Quick Check Workflow](./workflows/quick-check-workflow.md) - Feedback rapide (< 3 min)
- [Tests d'Authentification](./tests/auth-tests.md) - Login, register, logout

### 🔧 DevOps / CI/CD
**Vous gérez l'infrastructure :**
- [Vue d'ensemble Workflows](./workflows/README.md) - Architecture complète
- [Workflow Quick Check](./workflows/quick-check-workflow.md) - Optimisations développement
- [Standards Industrie](./workflows/README.md#🏢-standards-de-lindustrie) - Comparaison Google/Microsoft

### 🧪 QA / Testeur
**Vous validez la qualité :**
- [Vue d'ensemble Tests](./tests/README.md) - 996 tests, 53% couverture
- [Tests Widgets](./tests/widget-tests.md) - Interface utilisateur
- [Tests Intégration](./tests/integration-tests.md) - Flux complets

### 📊 Product Manager
**Vous pilotez le produit :**
- [Couverture de Code](./tests/README.md#📊-statistiques-actuelles) - Métriques qualité
- [Performance CI/CD](./workflows/README.md#📈-performance-et-optimisations) - Vélocité équipe

## 📊 État Actuel du Projet

### Tests & Qualité
- ✅ **996 tests** (100% de réussite)
- ✅ **53.11% de couverture** de code
- ✅ **0 problème** d'analyse statique
- ✅ **4 types de tests** : Unit, Widget, Integration, E2E

### CI/CD & Performance
- ⚡ **< 3 minutes** : Feedback développement (Quick Check)
- 🚀 **< 10 minutes** : Validation PR (Tests Fast)
- 📊 **< 20 minutes** : Tests complets production
- 🔄 **3 workflows** parallèles optimisés

### Couverture par Module
| Module | Couverture | Statut |
|--------|------------|---------|
| Services Core | 90%+ | ✅ Excellent |
| Authentification | 70% | 🟡 Bon |
| Gestion Pièces | 60% | 🟡 À améliorer |
| Interface Widgets | 45% | 🔴 Critique |

## 🎯 Objectifs Court Terme

### Tests (Priorité 1)
- [ ] Augmenter couverture interface à 60%
- [ ] Ajouter tests performance services
- [ ] Compléter tests d'intégration paiement
- [ ] Tests d'accessibilité

### CI/CD (Priorité 2)
- [ ] Optimiser cache workflows (gain 30%)
- [ ] Ajouter tests sécurité automatisés
- [ ] Intégration Sonar pour qualité code
- [ ] Tests de charge automatisés

## 🚀 Commandes Rapides

### Tests
```bash
# Tous les tests
flutter test

# Tests rapides (core services)
flutter test test/unit/core/

# Avec couverture
flutter test --coverage

# Test spécifique
flutter test test/unit/core/services/device_service_test.dart
```

### CI/CD Local
```bash
# Simulation Quick Check
git diff --name-only HEAD~1 HEAD | grep '\.dart$'
flutter analyze $(git diff --name-only HEAD~1 HEAD | grep '\.dart$')

# Génération mocks
dart run build_runner build

# Analyse statique
flutter analyze
```

### Métriques
```bash
# Coverage HTML
genhtml coverage/lcov.info -o coverage/html

# Statistiques tests
find test/ -name "*_test.dart" | wc -l

# Lignes de code
find lib/ -name "*.dart" | xargs wc -l
```

## 📚 Ressources Externes

### Standards Industrie
- [Google Engineering Practices](https://google.github.io/eng-practices/)
- [Microsoft DevOps Patterns](https://docs.microsoft.com/en-us/azure/devops/)
- [Flutter Testing Guide](https://flutter.dev/docs/testing)

### Outils Utilisés
- **Flutter 3.27.0** - Framework
- **Mockito 5.4.4** - Mocks pour tests
- **GitHub Actions** - CI/CD
- **Codecov** - Couverture de code
- **Riverpod** - State management

### Badges du Projet
[![codecov](https://codecov.io/gh/Nasko-dev/auto_pieces_app/graph/badge.svg?token=2fd97141-39a0-41e5-b98f-0bea5fa8a5b9)](https://codecov.io/gh/Nasko-dev/auto_pieces_app)
[![Flutter Tests](https://github.com/Nasko-dev/auto_pieces_app/actions/workflows/flutter_tests.yml/badge.svg)](https://github.com/Nasko-dev/auto_pieces_app/actions)

## 🤝 Contribution

### Ajout de Tests
1. Créer fichier `*_test.dart`
2. Suivre pattern AAA (Arrange, Act, Assert)
3. Documenter le test dans cette doc
4. Vérifier couverture > seuil module

### Modification Workflows
1. Tester changements localement
2. Documenter dans `docs/workflows/`
3. Respecter timeouts (3 min Quick Check)
4. Maintenir compatibilité cache

### Documentation
1. Format Markdown avec emojis
2. Explications claires pour humains
3. Exemples concrets et réels
4. Mise à jour badges et métriques

---

**Dernière mise à jour :** 20/09/2025
**Mainteneur principal :** Équipe de développement
**Questions/Suggestions :** Créer une issue GitHub