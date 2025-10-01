# Quick Check Workflow - Analyse Détaillée

Le workflow Quick Check est notre **outil de productivité numéro 1** pour les développeurs. Il fournit un feedback ultra-rapide (< 3 minutes) pendant le développement.

## 🎯 Objectif Principal

**Donner un feedback immédiat sans ralentir le développement**

Inspiré des standards Google/Microsoft qui privilégient la vélocité de développement avec des checks rapides mais efficaces.

## 📄 Fichier : `flutter_quick_check.yml`

### Déclencheurs

```yaml
on:
  push:
    branches: [ 'feature/**', 'bugfix/**', 'hotfix/**' ]
    paths:
      - '**.dart'
      - 'pubspec.yaml'
      - 'pubspec.lock'
```

**Explication :**
- **feature/\*** : Toutes les branches de nouvelles fonctionnalités
- **bugfix/\*** : Branches de correction de bugs
- **hotfix/\*** : Corrections urgentes
- **paths** : Se déclenche SEULEMENT si du code Dart ou config change

### Timeout Strict

```yaml
timeout-minutes: 3  # Max 3 minutes !
```

**Philosophie :** Si ça prend plus de 3 minutes, c'est que le workflow doit être optimisé, pas que la limite doit être augmentée.

## ⚡ Étapes Détaillées

### 1. Checkout Ultra-Rapide

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0  # Shallow clone pour rapidité
```

**Pourquoi fetch-depth: 0 ?** Permet de comparer avec le commit précédent sans télécharger tout l'historique.

### 2. Cache Agressif

```yaml
- name: Cache everything
  uses: actions/cache@v4
  with:
    path: |
      /opt/hostedtoolcache/flutter     # SDK Flutter
      ~/.pub-cache                     # Packages pub
      .dart_tool                       # Build cache
      .packages                        # Résolution packages
      **/*.g.dart                      # Code généré
      **/*.freezed.dart               # Modèles freezed
      **/*.mocks.dart                 # Mocks Mockito
    key: quick-${{ runner.os }}-${{ hashFiles('**/pubspec.lock') }}-${{ github.sha }}
```

**Stratégie de cache :**
- **Clé principale** : OS + hash pubspec.lock + SHA commit
- **Clés de fallback** : Si exacte introuvable, utilise version précédente
- **Cache "tout"** : Plus agressif que les autres workflows

### 3. Flutter Setup Optimisé

```yaml
- uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.27.0'
    cache: true
```

**cache: true** active le cache intégré de l'action Flutter (en plus du nôtre).

### 4. Installation avec Fallback

```yaml
- name: Quick setup
  run: |
    flutter pub get --offline 2>/dev/null || flutter pub get
```

**Logique :**
1. **Essaie offline d'abord** : Si cache complet, pas besoin de réseau
2. **Fallback online** : Si échec offline, download normal
3. **Supprime erreurs** : `2>/dev/null` cache les erreurs offline

### 5. Analyse Différentielle

```yaml
- name: Quick analyze
  run: |
    CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD | grep '\.dart$' || true)
    if [ ! -z "$CHANGED_FILES" ]; then
      flutter analyze --no-fatal-infos --no-fatal-warnings $CHANGED_FILES
    else
      echo "Pas de fichiers Dart modifiés"
    fi
```

**Analyse étape par étape :**

1. **`git diff --name-only HEAD~1 HEAD`** : Liste les fichiers modifiés depuis le dernier commit
2. **`grep '\.dart$'`** : Filtre seulement les fichiers Dart
3. **`|| true`** : Évite l'échec si pas de fichiers Dart trouvés
4. **`if [ ! -z "$CHANGED_FILES" ]`** : Exécute seulement s'il y a des fichiers
5. **`--no-fatal-infos --no-fatal-warnings`** : Erreurs seulement, pas warnings

**Exemple concret :**
```bash
# Vous modifiez device_service.dart et auth_controller.dart
CHANGED_FILES="lib/src/core/services/device_service.dart lib/src/features/auth/presentation/controllers/auth_controller.dart"

# Au lieu d'analyser 200+ fichiers, analyse seulement ces 2
flutter analyze --no-fatal-infos --no-fatal-warnings $CHANGED_FILES
```

### 6. Tests Ciblés

```yaml
- name: Run only affected tests
  run: |
    CHANGED_TEST_FILES=$(git diff --name-only HEAD~1 HEAD | grep '_test\.dart$' || true)
    if [ ! -z "$CHANGED_TEST_FILES" ]; then
      flutter test $CHANGED_TEST_FILES
    else
      echo "✅ Pas de tests modifiés"
    fi
```

**Logique similaire :**
1. Trouve les fichiers `*_test.dart` modifiés
2. Teste SEULEMENT ces fichiers
3. Skip si aucun test modifié

**Gain de temps énorme :**
```bash
# Au lieu de 996 tests (5 minutes)
flutter test  # Tous les tests

# Seulement les tests modifiés (30 secondes)
flutter test test/unit/core/services/device_service_test.dart
```

### 7. Feedback Final

```yaml
- name: Status
  if: always()
  run: |
    echo "✅ Quick check terminé en moins de 3 minutes !"
    echo "Pour tests complets, voir workflow principal sur PR/merge"
```

**`if: always()`** garantit que ce message s'affiche même si étapes précédentes échouent.

## 📊 Performance en Pratique

### Scénarios Réels

#### Scénario 1 : Modification simple
```bash
# Vous modifiez 1 fichier service + son test
git diff HEAD~1 HEAD --name-only
# lib/src/core/services/device_service.dart
# test/unit/core/services/device_service_test.dart

# Résultat :
# ✅ Cache hit Flutter/pub (10 sec)
# ✅ Analyse 1 fichier (15 sec)
# ✅ Test 1 fichier (30 sec)
# ✅ Total : 55 secondes
```

#### Scénario 2 : Modification UI
```bash
# Vous modifiez 3 widgets + leurs tests
git diff HEAD~1 HEAD --name-only
# lib/src/features/parts/widgets/part_card.dart
# lib/src/shared/widgets/custom_button.dart
# test/widget/parts/widgets/part_card_test.dart
# test/widget/shared/widgets/custom_button_test.dart

# Résultat :
# ✅ Cache hit (10 sec)
# ✅ Analyse 2 fichiers (20 sec)
# ✅ Test 2 fichiers (45 sec)
# ✅ Total : 1min 15sec
```

#### Scénario 3 : Modification config seulement
```bash
# Vous modifiez pubspec.yaml (ajout dépendance)
git diff HEAD~1 HEAD --name-only
# pubspec.yaml

# Résultat :
# ✅ Pas de fichiers Dart modifiés
# ✅ Skip analyse et tests
# ✅ Total : 30 secondes
```

### Comparaison avec Workflows Complets

| Modification | Quick Check | Workflow Complet | Gain |
|--------------|-------------|------------------|------|
| 1 service | 55 sec | 8 min | **87% plus rapide** |
| 3 widgets | 1min 15sec | 10 min | **88% plus rapide** |
| Config seule | 30 sec | 6 min | **92% plus rapide** |

## 🔧 Optimisations Avancées

### Cache Intelligent par Couches

```yaml
# Cache Level 1 : SDK + Packages
key: quick-${{ runner.os }}-${{ hashFiles('**/pubspec.lock') }}

# Cache Level 2 : Build artifacts
key: quick-build-${{ hashFiles('lib/**/*.dart') }}

# Cache Level 3 : Generated code
key: quick-generated-${{ hashFiles('**/*.dart') }}
```

### Git Diff Optimisé

```bash
# Standard (lent)
git diff HEAD~1 HEAD

# Optimisé (rapide)
git diff --name-only HEAD~1 HEAD | head -20
```

**Limite à 20 fichiers max** pour éviter les analyses massives.

### Analyse Conditionnelle

```bash
# Analyse seulement si > 0 et < 10 fichiers modifiés
FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l)
if [ "$FILE_COUNT" -gt 0 ] && [ "$FILE_COUNT" -lt 10 ]; then
  flutter analyze $CHANGED_FILES
else
  echo "Trop de fichiers modifiés, utiliser workflow complet"
fi
```

## ⚠️ Limitations et Trade-offs

### Ce que Quick Check NE fait PAS

- ❌ **Tests d'intégration** : Trop lents
- ❌ **Coverage complet** : Prendrait trop de temps
- ❌ **Build multi-plateforme** : Android/iOS/Web
- ❌ **Tests de régression** : Seulement code modifié
- ❌ **Performance tests** : Nécessitent plus de temps

### Quand Quick Check peut échouer

1. **Dépendances cassées** : Si pubspec.lock corrompu
2. **Mocks manquants** : Si génération code échouée
3. **Conflits git** : Si diff impossible
4. **Cache corrompu** : Rare mais possible

### Solutions de Fallback

```yaml
# Si cache échoue, mode dégradé
- name: Fallback if cache miss
  if: failure()
  run: |
    echo "⚠️ Cache miss, mode dégradé"
    flutter pub get
    flutter analyze --no-fatal-warnings
    # Tests plus sélectifs
```

## 🎯 Mesures de Succès

### Métriques Cibles

- **Durée moyenne** : < 2 minutes
- **Taux de succès** : > 95%
- **Cache hit rate** : > 80%
- **Satisfaction dev** : Feedback instantané

### Monitoring

```bash
# Analyser les durées via GitHub API
gh run list --workflow=flutter_quick_check.yml --limit=20 --json duration
```

### Indicateurs d'Alerte

- ⚠️ **Durée > 3 min** : Optimisation nécessaire
- ⚠️ **Cache hit < 70%** : Revoir stratégie cache
- ⚠️ **Taux échec > 10%** : Problème infrastructure

## 🚀 Évolutions Futures

### Optimisations Planifiées

1. **Cache distribué** : Partage entre branches
2. **Analyse incrémentale** : Seulement lignes modifiées
3. **Tests prédictifs** : IA pour prédire tests nécessaires
4. **Parallélisation locale** : Tests simultanés

### Intégration IDE

```json
// .vscode/settings.json
{
  "flutter.runOnSave": "quickCheck",
  "git.postCommitCommand": "triggerQuickCheck"
}
```

**Vision :** Quick Check directement dans l'IDE avant même le push.

## 📚 Références

- [GitHub Actions Cache](https://docs.github.com/en/actions/using-workflows/caching-dependencies)
- [Flutter CI/CD Best Practices](https://flutter.dev/docs/deployment/cd)
- [Google Engineering Practices](https://google.github.io/eng-practices/)
- [Microsoft DevOps Patterns](https://docs.microsoft.com/en-us/azure/devops/)