# 🌳 Stratégie Git - Pièces d'Occasion

## 📋 Vue d'ensemble

**Organisation professionnelle** du repository avec une stratégie Git Flow adaptée au développement rapide et au déploiement continu.

---

## 🌿 **STRUCTURE DES BRANCHES**

### **Branches Principales (Permanentes)**

#### 1. `main` - Production 🚀
- **Usage** : Code en production uniquement
- **Protection** : Require PR + Reviews + Tests passing
- **Deploy** : Auto-deploy vers App Store / Play Store
- **Commits** : Uniquement via merge de `release/` branches

#### 2. `develop` - Intégration 🔧
- **Usage** : Branche de développement principale
- **Protection** : Require PR + Tests passing
- **Deploy** : Auto-deploy vers staging environment
- **Commits** : Merge de `feature/` et `bugfix/` branches

#### 3. `staging` - Pré-production 🧪
- **Usage** : Tests finaux avant production
- **Protection** : Require PR + Manual approval
- **Deploy** : Staging environment pour QA
- **Commits** : Cherry-pick depuis `develop`

---

## 🚀 **BRANCHES TEMPORAIRES**

### **Feature Branches** `feature/`
```
feature/nom-fonctionnalite
```

**Exemples corrects :**
- `feature/payment-integration`
- `feature/push-notifications`
- `feature/user-profile-enhancement`

**Règles :**
- Créées depuis `develop`
- Mergées vers `develop` via PR
- Supprimées après merge
- Maximum 2 semaines de vie

### **Bugfix Branches** `bugfix/`
```
bugfix/description-probleme
```

**Exemples :**
- `bugfix/login-validation-error`
- `bugfix/image-upload-timeout`
- `bugfix/navigation-crash-android`

### **Hotfix Branches** `hotfix/`
```
hotfix/urgent-fix-description
```

**Exemples :**
- `hotfix/security-vulnerability`
- `hotfix/payment-failure-ios`
- `hotfix/app-crash-startup`

**Spécial :** Créées depuis `main`, mergées vers `main` ET `develop`

### **Release Branches** `release/`
```
release/v1.2.0
```

**Usage :**
- Préparation nouvelle version
- Tests finaux + corrections mineures
- Mise à jour version numbers
- Merge vers `main` + tag

---

## 🏷️ **CONVENTION DE NOMMAGE**

### **Format Standard**
```
type/description-en-anglais-avec-tirets
```

### **Types autorisés :**
- `feature/` - Nouvelle fonctionnalité
- `bugfix/` - Correction de bug
- `hotfix/` - Correction urgente production
- `release/` - Préparation release
- `docs/` - Documentation uniquement
- `refactor/` - Refactoring sans nouvelle feature
- `perf/` - Optimisations performance
- `test/` - Ajout/modification tests

### **Règles de nommage :**
- ✅ **Anglais uniquement** : `feature/user-authentication`
- ✅ **Tirets** : `feature/push-notification-system`
- ✅ **Descriptif** : `bugfix/cart-total-calculation-error`
- ❌ **Français** : `feature/authentification-utilisateur`
- ❌ **Underscores** : `feature/user_authentication`
- ❌ **Vague** : `feature/fix-stuff`

---

## 🔄 **WORKFLOW DE DÉVELOPPEMENT**

### **1. Nouvelle Fonctionnalité**
```bash
# 1. Partir de develop
git checkout develop
git pull origin develop

# 2. Créer feature branch
git checkout -b feature/payment-integration

# 3. Développer + commits
git add .
git commit -m "feat: add Stripe payment integration"

# 4. Pusher
git push origin feature/payment-integration

# 5. Créer Pull Request vers develop
# 6. Code Review + Tests + Merge
# 7. Supprimer branch
```

### **2. Correction Bug**
```bash
# Même workflow mais avec bugfix/
git checkout -b bugfix/login-validation-error
```

### **3. Release**
```bash
# 1. Créer release branch depuis develop
git checkout develop
git checkout -b release/v1.2.0

# 2. Finaliser version
# - Bump version numbers
# - Tests finaux
# - Documentation

# 3. Merger vers main + develop
git checkout main
git merge release/v1.2.0
git tag v1.2.0
git push origin main --tags

git checkout develop
git merge release/v1.2.0
git push origin develop
```

### **4. Hotfix Urgent**
```bash
# 1. Depuis main
git checkout main
git checkout -b hotfix/security-patch

# 2. Fix rapide
git commit -m "fix: patch critical security vulnerability"

# 3. Merger main ET develop
git checkout main
git merge hotfix/security-patch
git push origin main

git checkout develop
git merge hotfix/security-patch
git push origin develop
```

---

## 🛡️ **PROTECTION DES BRANCHES**

### **Main Branch Protection :**
- ✅ Require pull request reviews (2 reviewers)
- ✅ Require status checks (CI/CD passing)
- ✅ Require branches to be up to date
- ✅ Restrict pushes (admins only)
- ✅ Require linear history

### **Develop Branch Protection :**
- ✅ Require pull request reviews (1 reviewer)
- ✅ Require status checks (tests passing)
- ✅ Allow force pushes (admins only)

---

## 📋 **PULL REQUEST TEMPLATE**

### **Template Standard :**
```markdown
## 🎯 Description
Brief description of changes

## 🔄 Type of Change
- [ ] 🚀 New feature
- [ ] 🐛 Bug fix
- [ ] 📝 Documentation
- [ ] 🔧 Refactoring
- [ ] ⚡ Performance improvement

## ✅ Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## 📱 Screenshots
(if UI changes)

## 🚨 Breaking Changes
(if any)
```

---

## 🧹 **NETTOYAGE BRANCHES**

### **Branches à supprimer :**
```bash
# Locales obsolètes
git branch -d feature/old-feature
git branch -D feature/abandoned-feature

# Remotes obsolètes
git push origin --delete feature/old-feature
```

### **Commandes utiles :**
```bash
# Voir branches mergées
git branch --merged develop

# Nettoyer branches remote supprimées
git remote prune origin

# Voir dernière activité branches
git for-each-ref --sort=-committerdate refs/heads/
```

---

## 📊 **MÉTRIQUES & MONITORING**

### **KPIs à suivre :**
- 📈 Temps moyen PR → Merge
- 🔄 Nombre branches actives simultanées (max 10)
- ✅ Taux de réussite CI/CD (>95%)
- 🐛 Nombre hotfix/mois (max 2)
- 📝 Couverture documentation PRs

### **Outils recommandés :**
- **GitHub Insights** - Statistiques repository
- **Branch Protection Rules** - Sécurité
- **GitHub Actions** - CI/CD automatisé
- **Codecov** - Coverage tracking

---

## 🎯 **OBJECTIFS**

### **Court terme (1 semaine) :**
- ✅ Nettoyer branches obsolètes
- ✅ Créer structure main/develop/staging
- ✅ Configurer protections branches
- ✅ Documenter workflow équipe

### **Moyen terme (1 mois) :**
- 📈 Réduire branches actives (<10)
- 🚀 Automatiser déploiements
- 📊 Mettre en place métriques
- 🔄 Optimiser temps review

### **Long terme (3 mois) :**
- 🏆 Workflow parfaitement huilé
- 📈 Vélocité équipe optimisée
- 🛡️ Sécurité enterprise
- 🚀 Déploiements quotidiens

---

**Cette stratégie transformera ton repository en machine de guerre professionnelle ! 🚀**