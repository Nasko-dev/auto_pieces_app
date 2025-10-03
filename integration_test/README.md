# Tests d'Intégration

## ⚠️ Important

Les tests d'intégration **ne peuvent pas être exécutés avec `flutter test`** car ils nécessitent :
- Un appareil physique ou un émulateur en cours d'exécution
- L'initialisation complète de l'application (Supabase, OneSignal, etc.)
- L'interaction réelle avec l'UI

Ces tests ont été déplacés dans `integration_test/` pour ne pas bloquer l'exécution des tests unitaires.

## 📊 Contenu

- **42 tests d'intégration E2E** couvrant les 5 flows critiques
- **Couverture moyenne : ~76%** des parcours utilisateur
- **Durée estimée : 4-6 minutes** (tous les tests)

## 🚀 Comment Exécuter

### Prérequis
1. Lancer un émulateur ou connecter un appareil physique
2. Vérifier la connexion : `flutter devices`

### Exécution des Tests

#### Tous les tests
```bash
flutter test integration_test
```

#### Un fichier spécifique
```bash
flutter test integration_test/seller_flow_integration_test.dart
```

#### Avec flutter drive (recommandé)
```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/seller_flow_integration_test.dart
```

## 📁 Fichiers

1. **auth_flow_test.dart** - Tests d'authentification
2. **particulier_auth_flow_integration_test.dart** - Auth particulier (3 tests)
3. **part_search_flow_integration_test.dart** - Recherche (7 tests)
4. **conversations_flow_integration_test.dart** - Messagerie (10 tests)
5. **navigation_flow_integration_test.dart** - Navigation (10 tests)
6. **seller_flow_integration_test.dart** - Flow vendeur (12 tests)
