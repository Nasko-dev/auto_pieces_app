# Documentation des Workflows CI/CD

Notre projet utilise GitHub Actions pour automatiser les tests, l'analyse de code et les déploiements. Cette documentation explique chaque workflow et son rôle dans notre processus de développement.

## 🎯 Philosophie de nos Workflows

Nous suivons les **standards de l'industrie** utilisés par Google, Microsoft, Netflix :
- **Feedback rapide** pendant le développement (2-5 min)
- **Validation complète** sur les Pull Requests (10-15 min)
- **Tests exhaustifs** avant production (20-30 min)

## 📂 Structure des Workflows

```
.github/workflows/
├── flutter_quick_check.yml     # ⚡ Ultra-rapide (< 3 min)
├── flutter_tests_fast.yml      # 🚀 Optimisé (< 10 min)
└── flutter_tests.yml           # 📊 Complet (15-20 min)
```

## ⚡ Workflow 1 : Quick Check (Développement)

**Fichier :** `flutter_quick_check.yml`
**Objectif :** Feedback instantané pendant le développement
**Durée :** < 3 minutes GARANTI

### Quand s'exécute-t-il ?
```yaml
on:
  push:
    branches: ['feature/**', 'bugfix/**', 'hotfix/**']
```

**En clair :** À chaque push sur une branche de développement

### Que fait-il ?
1. **Cache intelligent** - Réutilise Flutter/dependencies
2. **Analyse différentielle** - Analyse SEULEMENT vos modifications
3. **Tests ciblés** - Teste SEULEMENT les fichiers que vous avez modifiés
4. **Mode offline** - Utilise le cache en priorité

### Exemple concret
```bash
# Vous modifiez device_service.dart
git add .
git push origin feature/nouvelle-fonctionnalite

# Le workflow :
# ✅ Analyse device_service.dart (30 sec)
# ✅ Teste device_service_test.dart (1 min)
# ✅ Vérifie que ça compile (1 min)
# Total : 2.5 minutes
```

### Optimisations appliquées
- **Cache à 100%** : Évite de retélécharger Flutter
- **Git diff** : Compare seulement avec le commit précédent
- **Skip intelligent** : Pas de tests si pas de code Dart modifié
- **Timeout strict** : 3 minutes maximum, sinon arrêt forcé

---

## 🚀 Workflow 2 : Tests Fast (Pull Requests)

**Fichier :** `flutter_tests_fast.yml`
**Objectif :** Validation optimisée avant merge
**Durée :** 5-10 minutes

### Quand s'exécute-t-il ?
```yaml
on:
  push:
    branches: [main, dev, develop]
  pull_request:
    branches: [main, dev, develop]
```

**En clair :** Sur les Pull Requests et branches principales

### Architecture parallèle
```yaml
strategy:
  matrix:
    shard: [1, 2, 3]  # 3 processus en parallèle !
```

**Division des tests :**
- **Shard 1 :** Tests des services core
- **Shard 2 :** Tests auth + parts
- **Shard 3 :** Tests widgets

### Flux d'exécution
1. **Analyse statique** (2 min) - Lint + analyse de code
2. **Tests parallèles** (3-5 min) - 3 processus simultanés
3. **Coverage** (2 min) - Seulement sur main/dev
4. **Build check** (2 min) - Vérifie compilation Android

### Optimisations avancées
- **Cache en cascade** : Flutter → Dependencies → Build runner
- **Fail-fast** : Arrêt immédiat si analyse échoue
- **Cache des mocks** : Évite de regenerer le code
- **Conditions intelligentes** : Coverage seulement si nécessaire

---

## 📊 Workflow 3 : Tests Complets (Production)

**Fichier :** `flutter_tests.yml`
**Objectif :** Validation exhaustive pour production
**Durée :** 15-20 minutes

### Quand s'exécute-t-il ?
- Merge vers `main`
- Création de releases
- Manuellement si besoin

### Jobs multiples
1. **test** - Tests complets avec coverage
2. **integration_tests** - Tests end-to-end
3. **build_check** - Compilation Android + Web
4. **quality_metrics** - Métriques de qualité

### Fonctionnalités complètes
- **Coverage Codecov** - Upload vers tableau de bord
- **Rapports XML** - Pour commentaires sur PR
- **Build multi-plateforme** - Android + Web
- **Métriques avancées** - Comptage lignes, performance

---

## 🔄 Cycle de Développement Type

### 1. Développement local
```bash
# Vous codez tranquillement
git add .
git commit -m "WIP: nouvelle fonction"
git push origin feature/ma-fonction
```
**→ Déclenche : Quick Check (2-3 min)**

### 2. Tests pendant développement
```bash
# Plusieurs push dans la journée
git push  # Quick Check à chaque fois
git push  # 2-3 minutes à chaque fois
git push  # Feedback rapide garanti
```

### 3. Finalisation
```bash
# Quand votre feature est terminée
gh pr create --title "Nouvelle fonction géniale"
```
**→ Déclenche : Tests Fast (5-10 min)**

### 4. Merge en production
```bash
# Après validation de la PR
git checkout main
git merge feature/ma-fonction
git push origin main
```
**→ Déclenche : Tests Complets (15-20 min)**

---

## 📈 Performance et Optimisations

### Gains de vitesse obtenus

| Situation | Avant | Après | Gain |
|-----------|-------|-------|------|
| Push feature | 10-15 min | 2-3 min | **75% plus rapide** |
| Pull Request | 15-20 min | 5-10 min | **50% plus rapide** |
| Cache chaud | 10 min | 1-2 min | **80% plus rapide** |

### Techniques utilisées

#### Cache Multi-Niveaux
```yaml
# Cache Flutter SDK
path: /opt/hostedtoolcache/flutter

# Cache dependencies pub
path: ~/.pub-cache

# Cache build outputs
path: .dart_tool/build
```

#### Parallélisation Intelligente
```yaml
# Au lieu de 15 minutes séquentielles
analyze → unit → widget → coverage

# Nous faisons 5 minutes en parallèle
analyze | unit-1 | unit-2 | widget | coverage
```

#### Conditions Intelligentes
```yaml
# Coverage seulement sur branches importantes
if: github.ref == 'refs/heads/main'

# Build check seulement sur PR
if: github.event_name == 'pull_request'
```

---

## 🛠 Maintenance des Workflows

### Mise à jour des versions
```yaml
# Versions à maintenir à jour
flutter-version: '3.27.0'  # Version stable
actions/checkout@v4         # Dernière version
codecov/codecov-action@v4   # Dernière version
```

### Monitoring des performances
- Surveiller les durées d'exécution
- Optimiser si > 3 min pour Quick Check
- Ajuster le cache si nécessaire

### Gestion des secrets
```yaml
# Secrets configurés
CODECOV_TOKEN  # Pour les rapports de couverture
GITHUB_TOKEN   # Automatique, pour commentaires PR
```

---

## 🚨 Résolution de Problèmes

### Quick Check trop lent (> 3 min)
1. Vérifier le cache
2. Réduire le scope des tests
3. Optimiser git diff

### Tests Fast échouent
1. Vérifier les mocks générés
2. Problème de parallélisation ?
3. Conflits de dépendances ?

### Coverage ne fonctionne pas
1. Vérifier CODECOV_TOKEN
2. Format lcov correct ?
3. Conversion XML réussie ?

### Cache problématique
```bash
# Forcer la régénération du cache
# Modifier le nom de la clé dans le workflow
key: cache-v2-${{ hashFiles('**/pubspec.lock') }}
```

---

## 📋 Checklist Maintenance

### Hebdomadaire
- [ ] Vérifier durées d'exécution
- [ ] Contrôler taux de succès
- [ ] Surveiller usage GitHub Actions

### Mensuel
- [ ] Mettre à jour Flutter version
- [ ] Vérifier nouvelles versions actions
- [ ] Optimiser cache si nécessaire
- [ ] Analyser métriques de performance

### Lors d'ajout de features
- [ ] Nouveaux tests dans la bonne shard
- [ ] Cache adapté aux nouveaux fichiers
- [ ] Durées toujours respectées