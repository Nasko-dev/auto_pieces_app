# RAPPORT D'ANALYSE DE COUVERTURE DE CODE

**Date d'analyse :** 24 septembre 2025
**Projet :** Application Pièces d'Occasion
**Objectif :** Atteindre 100% de couverture de code sur tous les fichiers du dossier `lib/src/`

## STATISTIQUES GÉNÉRALES

| Métrique | Valeur |
|----------|--------|
| **Total fichiers Dart dans lib/src/** | 190 |
| **Fichiers avec tests** | 104 |
| **Fichiers sans tests** | 96 |
| **Fichiers avec couverture partielle (<100%)** | 55 |
| **Total fichiers nécessitant du travail** | **151** |
| **Total lignes non couvertes** | **3,263** |

---

## 🔥 PRIORITÉ CRITIQUE - DOMAIN LAYER (16 fichiers)

Ces fichiers contiennent la logique métier centrale et **DOIVENT** être testés en premier.

### Repositories (5 fichiers)
- `lib/src/features/auth/domain/repositories/auth_repository.dart`
- `lib/src/features/auth/domain/repositories/particulier_auth_repository.dart`
- `lib/src/features/auth/domain/repositories/seller_auth_repository.dart`
- `lib/src/features/parts/domain/repositories/conversations_repository.dart`
- `lib/src/features/parts/domain/repositories/part_advertisement_repository.dart`
- `lib/src/features/parts/domain/repositories/part_request_repository.dart`
- `lib/src/features/parts/domain/repositories/seller_settings_repository.dart`
- `lib/src/features/parts/domain/repositories/user_settings_repository.dart`

### Entities (8 fichiers)
- `lib/src/features/parts/domain/entities/conversation_enums.dart`
- `lib/src/features/parts/domain/entities/conversation_group.dart`
- `lib/src/features/parts/domain/entities/particulier_conversation.dart`
- `lib/src/features/parts/domain/entities/particulier_message.dart`
- `lib/src/features/parts/domain/entities/seller_advertisement.dart`
- `lib/src/features/parts/domain/entities/seller_settings.dart`
- `lib/src/features/parts/domain/entities/user_settings.dart`

### Services (1 fichier)
- `lib/src/features/parts/domain/services/conversation_grouping_service.dart`

---

## 🟡 PRIORITÉ IMPORTANTE - DATA LAYER (1 fichier)

### Models (1 fichier)
- `lib/src/features/parts/data/models/seller_response_model.dart`

---

## ⚡ FICHIERS AVEC COUVERTURE PARTIELLE CRITIQUE (0% couverture)

Ces 31 fichiers ont 0% de couverture et nécessitent une attention immédiate :

### Core Services (3,263 lignes non couvertes au total)
| Fichier | Lignes non couvertes |
|---------|---------------------|
| `lib/src/features/parts/data/datasources/part_request_remote_datasource.dart` | 504 |
| `lib/src/features/parts/data/datasources/conversations_remote_datasource.dart` | 352 |
| `lib/src/shared/presentation/widgets/ios_notification_fixed.dart` | 170 |
| `lib/src/core/providers/immatriculation_providers.dart` | 149 |
| `lib/src/features/auth/data/datasources/seller_auth_remote_datasource.dart` | 130 |
| `lib/src/features/parts/data/datasources/user_settings_remote_datasource.dart` | 120 |
| `lib/src/features/parts/data/models/part_advertisement_model.g.dart` | 107 |
| `lib/src/core/services/immatriculation_service.dart` | 95 |
| `lib/src/core/services/realtime_service.dart` | 93 |
| `lib/src/core/config/environment_config.dart` | 91 |

---

## 📊 PLAN DE TESTS PAR PRIORITÉ

### Phase 1 - CRITIQUE (Semaine 1-2)
**16 fichiers Domain Layer** - Tests unitaires obligatoires
- Repositories interfaces : 8 fichiers
- Entities : 8 fichiers
- Services : 1 fichier

### Phase 2 - IMPORTANT (Semaine 2-3)
**Fichiers avec 0% couverture (31 fichiers)**
- Datasources : 6 fichiers majeurs
- Services core : 5 fichiers
- Providers : 8 fichiers

### Phase 3 - OPTIMISATION (Semaine 3-4)
**55 fichiers avec couverture partielle**
- Compléter les tests existants
- Cibler les fichiers avec <50% de couverture

### Phase 4 - FINALISATION (Semaine 4)
**96 fichiers Presentation Layer**
- Tests de widgets
- Tests d'intégration
- Tests de controllers

---

## 🎯 FICHIERS PRIORITAIRES IMMÉDIATS

### TOP 10 - À tester cette semaine

1. **`features/auth/domain/repositories/auth_repository.dart`** - Interface centrale auth
2. **`features/parts/domain/repositories/part_request_repository.dart`** - Logique métier demandes
3. **`features/parts/domain/services/conversation_grouping_service.dart`** - Service critique
4. **`features/parts/data/datasources/part_request_remote_datasource.dart`** - 504 lignes non couvertes
5. **`features/parts/data/datasources/conversations_remote_datasource.dart`** - 352 lignes non couvertes
6. **`features/auth/data/datasources/seller_auth_remote_datasource.dart`** - 130 lignes non couvertes
7. **`core/services/immatriculation_service.dart`** - 95 lignes non couvertes
8. **`core/services/realtime_service.dart`** - 93 lignes non couvertes
9. **`core/config/environment_config.dart`** - 91 lignes non couvertes
10. **`features/parts/data/datasources/user_settings_remote_datasource.dart`** - 120 lignes non couvertes

---

## 📋 STRATÉGIE DE TESTS

### Repositories (Domain)
```dart
// Exemple de tests requis pour chaque repository
- Test des méthodes de base (CRUD)
- Test de gestion des erreurs
- Test des cas limites
- Mocking des datasources
```

### Datasources (Data)
```dart
// Tests d'intégration avec Supabase
- Test des requêtes API
- Test de sérialisation/désérialisation
- Test de gestion des erreurs réseau
- Test des timeouts et retry
```

### Services (Core)
```dart
// Tests unitaires des services
- Test des algorithmes métier
- Test des transformations de données
- Test des validations
- Test des performances
```

---

## 🚀 OBJECTIF FINAL

**Atteindre 100% de couverture sur les 190 fichiers du dossier `lib/src/`**

- ✅ **104 fichiers** déjà testés (à compléter)
- 🔥 **16 fichiers Domain** (priorité critique)
- ⚡ **31 fichiers** à 0% de couverture
- 📱 **96 fichiers Presentation** (tests widgets)

**Estimation temps :** 3-4 semaines avec focus sur Domain Layer en priorité absolue.

---

*Ce rapport doit être mis à jour après chaque session de tests pour suivre les progrès.*