# Tests des Services Core

Les services core sont les fondations de l'application. Ils fournissent des fonctionnalités essentielles utilisées partout dans l'app.

## 📋 Liste des Services Testés

### 1. DeviceService (device_service_test.dart)

**Rôle :** Gère l'identification unique de l'appareil de l'utilisateur.

**Fonctionnalités testées :**
- ✅ Génération d'ID unique d'appareil
- ✅ Sauvegarde et récupération d'ID existant
- ✅ Gestion des cas d'erreur (lecture/écriture échouée)
- ✅ Format correct de l'ID (timestamp + partie aléatoire)
- ✅ Suppression d'ID et regénération

**Tests critiques :**
```dart
// Test principal : génération d'ID
test('doit générer un nouvel ID si aucun n\'existe', () async {
  // Vérifie qu'un ID est créé la première fois
});

// Test de persistance
test('doit retourner le même ID lors d\'appels multiples', () async {
  // Vérifie que l'ID ne change pas entre les appels
});
```

**Couverture :** 100% (18 tests)
**Importance :** 🔴 Critique - utilisé pour l'authentification anonyme

---

### 2. RateLimiterService (rate_limiter_service_test.dart)

**Rôle :** Protège l'application contre les requêtes trop fréquentes (anti-spam).

**Fonctionnalités testées :**
- ✅ Limitation du nombre de requêtes par minute
- ✅ Réinitialisation automatique après expiration
- ✅ Gestion des différentes actions (login, register, etc.)
- ✅ Sauvegarde des compteurs en local
- ✅ Nettoyage automatique des anciens compteurs

**Tests critiques :**
```dart
// Protection anti-spam
test('doit bloquer après 5 tentatives de login', () async {
  // Simule 5 tentatives rapides, vérifie que la 6ème est bloquée
});

// Réinitialisation
test('doit permettre nouvelles tentatives après 1 minute', () async {
  // Vérifie que le limiteur se remet à zéro
});
```

**Couverture :** 95% (15 tests)
**Importance :** 🔴 Critique - sécurité de l'application

---

### 3. NotificationService (notification_service_test.dart)

**Rôle :** Affiche les messages de succès, erreur et information à l'utilisateur.

**Fonctionnalités testées :**
- ✅ Affichage de notifications de succès
- ✅ Affichage d'erreurs utilisateur
- ✅ Messages spécifiques par action (création pièce, suppression, etc.)
- ✅ Configuration des durées d'affichage
- ✅ Gestion des couleurs et icônes

**Tests principaux :**
```dart
// Test d'affichage
test('doit afficher notification de succès', () {
  // Vérifie que le message apparaît avec la bonne couleur
});

// Test des messages spécialisés
test('doit avoir message spécifique pour création pièce', () {
  // Vérifie le contenu exact du message
});
```

**Couverture :** 85% (12 tests)
**Importance :** 🟡 Important - expérience utilisateur

---

### 4. LocationService (location_service_test.dart)

**Rôle :** Gère la géolocalisation pour trouver des pièces près de l'utilisateur.

**Fonctionnalités testées :**
- ✅ Obtention de la position GPS
- ✅ Conversion coordonnées → adresse
- ✅ Gestion des permissions refusées
- ✅ Gestion des erreurs réseau
- ✅ Format des résultats de géolocalisation

**Tests importants :**
```dart
// Test de géolocalisation
test('doit retourner position valide', () async {
  // Vérifie latitude/longitude dans les bonnes plages
});

// Test de geocoding
test('doit convertir coordonnées en adresse', () async {
  // Vérifie la conversion GPS → adresse lisible
});
```

**Couverture :** 75% (10 tests)
**Importance :** 🟡 Important - fonctionnalité de recherche locale

---

## 🎯 Pourquoi Ces Tests Sont Cruciaux

### Impact Business
- **DeviceService :** Sans lui, pas d'identification utilisateur anonyme
- **RateLimiterService :** Protège contre les attaques et abus
- **NotificationService :** Interface utilisateur claire et professionnelle
- **LocationService :** Recherche géographique de pièces

### Impact Technique
- **Stabilité :** Ces services sont utilisés partout dans l'app
- **Sécurité :** Rate limiting et gestion d'erreurs robuste
- **Performance :** Optimisations mémoire et stockage local

## 🔧 Commandes pour Tester

```bash
# Tous les services core
flutter test test/unit/core/services/

# Service spécifique
flutter test test/unit/core/services/device_service_test.dart

# Avec détails de couverture
flutter test test/unit/core/services/ --coverage
```

## 📈 Historique des Améliorations

- **Décembre 2024 :** Ajout RateLimiterService (protection anti-spam)
- **Décembre 2024 :** Optimisation DeviceService (gestion erreurs)
- **Décembre 2024 :** Tests NotificationService convertis en unit tests
- **Décembre 2024 :** LocationService avec mocks NiceMocks

## ⚠️ Points d'Attention

- **DeviceService :** Dépend de SharedPreferences, bien tester les mocks
- **RateLimiterService :** Logique temporelle complexe, attention aux timestamps
- **LocationService :** Mocks Placemark peuvent avoir des erreurs de génération
- **NotificationService :** Éviter les tests de widgets, privilégier la logique

## 🚀 Améliorations Futures

- [ ] Ajouter tests de performance pour DeviceService
- [ ] Tester RateLimiterService avec vraies conditions réseau
- [ ] LocationService : tests avec vraies coordonnées
- [ ] NotificationService : tests d'accessibilité