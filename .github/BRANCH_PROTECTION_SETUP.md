# Configuration Protection Branche Main

## 🛡️ Instructions pour Protéger la Branche `main`

### 1. Aller dans les Paramètres GitHub
```
https://github.com/Nasko-dev/auto_pieces_app/settings/branches
```

### 2. Créer une Règle de Protection
- Cliquer sur **"Add branch protection rule"**
- **Branch name pattern** : `main`

### 3. Configuration Recommandée

#### ✅ Restrictions de Base
- ☑️ **Require a pull request before merging**
  - ☑️ Require approvals: `1`
  - ☑️ Dismiss stale PR approvals when new commits are pushed
  - ☑️ Require review from code owners (optionnel)

#### ✅ Checks de Statut
- ☑️ **Require status checks to pass before merging**
  - ☑️ Require branches to be up to date before merging
  - **Checks requis** :
    - `analyze` (de flutter_tests_fast.yml)
    - `test-unit` (de flutter_tests_fast.yml)
    - `ios-build` (de ios_deployment.yml)
    - `pre-validation` (de ios_deployment.yml)

#### ✅ Restrictions Avancées
- ☑️ **Require conversation resolution before merging**
- ☑️ **Require signed commits** (recommandé)
- ☑️ **Include administrators** (important !)
- ☑️ **Restrict pushes that create files** (optionnel)

#### ✅ Force Push Protection
- ☑️ **Do not allow bypassing the above settings**
- ☑️ **Restrict force pushes**
- ☑️ **Allow deletions** : ❌ (décoché)

### 4. Règles Spéciales

#### Auto-Merge (Optionnel)
- ☑️ **Allow auto-merge**
- Permet le merge automatique quand tous les checks passent

#### Notifications
- Les règles enverront des notifications automatiques
- Les builds Xcode Cloud apparaîtront comme checks

### 5. Validation de la Configuration

Une fois configuré, tester avec :
```bash
# Ceci devrait échouer
git push origin main

# Message attendu :
# ! [remote rejected] main -> main (protected branch hook declined)
```

### 6. Workflow de Travail Sécurisé

```bash
# ✅ Workflow correct
git checkout dev
git add .
git commit -m "feat: nouvelle fonctionnalité"
git push origin dev

# Créer PR : dev → main sur GitHub
# Attendre validation des checks
# Merge via l'interface GitHub
```

### 7. Checks Automatiques

Avec cette configuration, chaque PR vers `main` déclenchera :

1. **GitHub Actions** :
   - Analyse statique (`flutter analyze`)
   - Tests unitaires (3 shards parallèles)
   - Build iOS de validation
   - Vérification dépendances

2. **Après merge sur main** :
   - Build iOS complet
   - **Xcode Cloud** automatique
   - Déploiement TestFlight
   - Notifications équipe

### 8. Urgences

En cas d'urgence absolue, un admin peut :
- Temporairement désactiver les règles
- Faire un push direct
- **MAIS** : réactiver immédiatement après

### 9. Monitoring

Surveiller dans :
- GitHub Actions (builds automatiques)
- App Store Connect (déploiements TestFlight)
- Xcode Cloud (builds iOS)
- Notifications email/Slack

---

## ⚡ Quick Setup

Pour configurer rapidement :
1. Va sur : https://github.com/Nasko-dev/auto_pieces_app/settings/branches
2. Add protection rule pour `main`
3. Coche toutes les options recommandées ✅ ci-dessus
4. Save changes
5. Test avec une PR dev → main

**🎯 Résultat** : Impossible de push directement sur main, déploiement sécurisé automatique !