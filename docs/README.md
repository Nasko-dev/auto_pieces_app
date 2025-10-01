# 📚 Documentation - Pièces d'Occasion

> Documentation complète et professionnelle de l'application **Pièces d'Occasion**
>
> Marketplace Flutter pour pièces automobiles d'occasion | 100 000+ utilisateurs

**Technologies** : Flutter 3.27.0 | Clean Architecture | Riverpod | Supabase

---

## 🎯 Navigation Rapide

| 🚀 Je suis... | 📖 Par où commencer ? |
|---------------|----------------------|
| **Nouveau développeur** | [01-getting-started/ONBOARDING.md](./01-getting-started/ONBOARDING.md) ← Commencez ici ! |
| **Contributeur externe** | [01-getting-started/CONTRIBUTING.md](./01-getting-started/CONTRIBUTING.md) |
| **Architecte** | [02-architecture/ARCHITECTURE.md](./02-architecture/ARCHITECTURE.md) |
| **DevOps** | [04-deployment/DEPLOYMENT.md](./04-deployment/DEPLOYMENT.md) |
| **QA/Testeur** | [03-development/tests/README.md](./03-development/tests/README.md) |

---

## 📂 Structure de la Documentation

```
docs/
│
├── 📖 README.md                          ← Vous êtes ici
│
├── 📁 01-getting-started/                🚀 Démarrage & Onboarding
│   ├── ONBOARDING.md                     Guide onboarding (< 2h setup)
│   ├── CONTRIBUTING.md                   Guide de contribution
│   └── SECURITY_CHECKLIST.md             Checklist sécurité
│
├── 📁 02-architecture/                   🏗️ Architecture & Design
│   ├── ARCHITECTURE.md                   Clean Architecture complète
│   ├── DATABASE_SCHEMA.md                Schéma BDD PostgreSQL
│   └── API_REFERENCE.md                  API Supabase & Services
│
├── 📁 03-development/                    💻 Développement
│   ├── CODE_STANDARDS.md                 Standards de code
│   ├── tests/                            Documentation des tests
│   │   ├── README.md                     996 tests, 53% couverture
│   │   ├── auth-tests.md                 Tests authentification
│   │   └── core-services.md              Tests services core
│   └── workflows/                        CI/CD Workflows
│       ├── README.md                     Vue d'ensemble
│       └── quick-check-workflow.md       Feedback < 3 min
│
├── 📁 04-deployment/                     🚀 Déploiement
│   ├── DEPLOYMENT.md                     iOS, Android, Web
│   └── SETUP_PRODUCTION.md               Configuration production
│
├── 📁 05-operations/                     ⚙️ Operations & Monitoring
│   └── MONITORING.md                     Observabilité, métriques, alerting
│
├── 📁 06-features/                       🎯 Features Spécifiques
│   ├── authentication/                   Système d'authentification
│   ├── pages/                            Spécifications des pages
│   └── professional/                     Features professionnelles
│
└── 📁 07-archive/                        📦 Archive (référence historique)
    ├── CORRECTIONS_DOCUMENTATION.md
    ├── DOCUMENTATION_GAPS.md
    └── PROJET_PARFAIT_ROADMAP.md
```

---

## 📚 Documentation par Catégorie

### 🚀 01 - Getting Started (Démarrage)

| Document | Description | Temps |
|----------|-------------|-------|
| **[ONBOARDING.md](./01-getting-started/ONBOARDING.md)** | Setup environnement et première contribution | 15 min |
| **[CONTRIBUTING.md](./01-getting-started/CONTRIBUTING.md)** | Git workflow, PR process, standards | 10 min |
| **[SECURITY_CHECKLIST.md](./01-getting-started/SECURITY_CHECKLIST.md)** | Checklist sécurité | 5 min |

**➡️ Commencez par** : [ONBOARDING.md](./01-getting-started/ONBOARDING.md) si vous êtes nouveau !

---

### 🏗️ 02 - Architecture

| Document | Description | Audience |
|----------|-------------|----------|
| **[ARCHITECTURE.md](./02-architecture/ARCHITECTURE.md)** | Clean Architecture avec diagrammes Mermaid | Tech Leads, Devs |
| **[DATABASE_SCHEMA.md](./02-architecture/DATABASE_SCHEMA.md)** | Schéma BDD, tables, RLS, indexes | Backend, DB Engineers |
| **[API_REFERENCE.md](./02-architecture/API_REFERENCE.md)** | API Supabase complète + Services Core | Full-Stack Devs |

---

### 💻 03 - Development

| Document | Description | Audience |
|----------|-------------|----------|
| **[CODE_STANDARDS.md](./03-development/CODE_STANDARDS.md)** | Standards Dart/Flutter, best practices | Tous les devs |
| **[tests/README.md](./03-development/tests/README.md)** | 996 tests, 53% couverture | QA, Devs |
| **[workflows/README.md](./03-development/workflows/README.md)** | CI/CD GitHub Actions | DevOps |

**Métriques qualité** :
- ✅ 996 tests (100% réussite)
- ✅ 53.11% couverture code
- ✅ 0 warnings analyse statique
- ⚡ Feedback dev < 3 min

---

### 🚀 04 - Deployment

| Document | Description | Audience |
|----------|-------------|----------|
| **[DEPLOYMENT.md](./04-deployment/DEPLOYMENT.md)** | Déploiement iOS, Android, Web complet | DevOps, Release Managers |
| **[SETUP_PRODUCTION.md](./04-deployment/SETUP_PRODUCTION.md)** | Configuration environnement production | SysAdmin, DevOps |

**Plateformes** : 📱 iOS | 🤖 Android | 🌐 Web

---

### ⚙️ 05 - Operations

| Document | Description | Audience |
|----------|-------------|----------|
| **[MONITORING.md](./05-operations/MONITORING.md)** | Crashlytics, Analytics, Performance, Alerting | DevOps, SRE, Tech Leads |

**Stack** : Firebase Crashlytics | Analytics | Performance | Supabase Dashboard

---

### 🎯 06 - Features

| Catégorie | Documents | Description |
|-----------|-----------|-------------|
| **Authentication** | [README](./06-features/authentication/README.md), [Particulier Auth](./06-features/authentication/particulier-auth.md), [Password Recovery](./06-features/authentication/password-recovery.md) | Système d'authentification complet |
| **Pages** | [Auth Pages](./06-features/pages/auth-pages.md), [Particulier Pages](./06-features/pages/particulier-pages.md) | Spécifications UI/UX |
| **Professional** | [Dashboard](./06-features/professional/dashboard.md), [Inventory](./06-features/professional/inventory.md), [Messaging](./06-features/professional/messaging.md) | Features vendeurs professionnels |

---

## 🎯 Guides par Rôle

### 👨‍💻 Nouveau Développeur

**Parcours recommandé (2-3 heures)** :

1. [ONBOARDING.md](./01-getting-started/ONBOARDING.md) (1h) - Setup environnement
2. [ARCHITECTURE.md](./02-architecture/ARCHITECTURE.md) (30 min) - Comprendre l'archi
3. [CODE_STANDARDS.md](./03-development/CODE_STANDARDS.md) (20 min) - Standards
4. [CONTRIBUTING.md](./01-getting-started/CONTRIBUTING.md) (10 min) - Première PR

### 🏗️ Architecte / Tech Lead

- [ARCHITECTURE.md](./02-architecture/ARCHITECTURE.md) - Clean Architecture
- [DATABASE_SCHEMA.md](./02-architecture/DATABASE_SCHEMA.md) - Schéma BDD
- [API_REFERENCE.md](./02-architecture/API_REFERENCE.md) - APIs
- [MONITORING.md](./05-operations/MONITORING.md) - Observabilité

### 🔧 DevOps / SRE

- [DEPLOYMENT.md](./04-deployment/DEPLOYMENT.md) - CI/CD complet
- [MONITORING.md](./05-operations/MONITORING.md) - Monitoring
- [SETUP_PRODUCTION.md](./04-deployment/SETUP_PRODUCTION.md) - Config prod
- [workflows/README.md](./03-development/workflows/README.md) - GitHub Actions

### 🧪 QA / Testeur

- [tests/README.md](./03-development/tests/README.md) - 996 tests
- [tests/core-services.md](./03-development/tests/core-services.md) - Tests services
- [tests/auth-tests.md](./03-development/tests/auth-tests.md) - Tests auth
- [CODE_STANDARDS.md](./03-development/CODE_STANDARDS.md) - Standards tests

---

## 📊 État du Projet

### ✅ Qualité & Tests

| Métrique | Valeur | Status |
|----------|--------|--------|
| **Tests totaux** | 996 | ✅ Excellent |
| **Taux de réussite** | 100% | ✅ Parfait |
| **Couverture code** | 53.11% | 🟡 Bon (cible: 80%) |
| **Warnings** | 0 | ✅ Clean |

### 📈 Couverture par Module

| Module | Couverture | Statut | Objectif |
|--------|------------|---------|----------|
| Services Core | 90%+ | ✅ Excellent | Maintenir |
| Authentification | 70% | 🟡 Bon | → 80% |
| Gestion Pièces | 60% | 🟡 Correct | → 75% |
| Interface Widgets | 45% | 🔴 À améliorer | → 60% |

---

## 🚀 Quick Start

```bash
# 1. Cloner le repository
git clone https://github.com/Nasko-dev/auto_pieces_app.git
cd auto_pieces_app

# 2. Installer dépendances
flutter pub get

# 3. Configuration
cp .env.example .env

# 4. Générer code
dart run build_runner build

# 5. Lancer l'app
flutter run
```

**Voir détails** : [ONBOARDING.md](./01-getting-started/ONBOARDING.md)

---

## 🛠️ Commandes Essentielles

```bash
# Development
flutter run              # Lancer app
flutter test            # Exécuter tests
flutter analyze         # Analyse statique
dart format .           # Formatter code

# Build
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android Bundle
flutter build ios --release          # iOS
flutter build web --release          # Web

# Tests
flutter test --coverage                      # Tests avec couverture
genhtml coverage/lcov.info -o coverage/html  # HTML coverage
```

---

## 📊 Badges

[![codecov](https://codecov.io/gh/Nasko-dev/auto_pieces_app/graph/badge.svg)](https://codecov.io/gh/Nasko-dev/auto_pieces_app)
[![Flutter Tests](https://github.com/Nasko-dev/auto_pieces_app/actions/workflows/flutter_tests.yml/badge.svg)](https://github.com/Nasko-dev/auto_pieces_app/actions)
[![Flutter](https://img.shields.io/badge/Flutter-3.27.0-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.6.0-blue.svg)](https://dart.dev)

---

## 🔗 Liens Utiles

### Ressources
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Riverpod Documentation](https://riverpod.dev)
- [Supabase Documentation](https://supabase.com/docs)

### Standards
- [Google Engineering Practices](https://google.github.io/eng-practices/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

---

## 🤝 Support & Contribution

### Communication

| Canal | Usage | Réponse |
|-------|-------|---------|
| **GitHub Issues** | Bugs, features | 1-2 jours |
| **GitHub Discussions** | Questions | Variable |
| **Slack #dev** | Temps réel (interne) | Immédiat |
| **Email** | dev@piecesdoccasion.fr | 2-3 jours |

### Contribuer

Guide complet : [CONTRIBUTING.md](./01-getting-started/CONTRIBUTING.md)

- ✅ Git workflow
- ✅ Standards de code
- ✅ Processus de review
- ✅ Code of conduct

---

## 📄 License

**Proprietary** - © 2025 Pièces d'Occasion. Tous droits réservés.

---

**Dernière mise à jour** : 30/09/2025
**Mainteneur** : Équipe Technique
**Version** : 2.0.0 (nouvelle architecture de documentation)

---

<div align="center">

**🚀 Prêt à contribuer ?**
[Commencez par l'Onboarding](./01-getting-started/ONBOARDING.md) →

</div>