# Tests d'Authentification

Le système d'authentification permet aux vendeurs et particuliers de se connecter, s'inscrire et gérer leur compte.

## 👥 Types d'Utilisateurs

Notre app gère 2 types d'utilisateurs :
- **Vendeurs :** Professionnels qui vendent des pièces
- **Particuliers :** Clients qui achètent des pièces

## 📋 Tests par Module

### 🏪 Tests Vendeurs (Sellers)

#### seller_login_test.dart
**Rôle :** Connexion des vendeurs professionnels

**Scénarios testés :**
- ✅ Connexion réussie avec email/mot de passe valides
- ✅ Échec avec identifiants incorrects
- ✅ Validation format email
- ✅ Gestion des erreurs réseau
- ✅ Sauvegarde session utilisateur

**Test critique :**
```dart
test('doit connecter vendeur avec identifiants valides', () async {
  // Simule saisie email/password
  // Vérifie que l'utilisateur est bien connecté
  // Vérifie sauvegarde de la session
});
```

#### seller_register_test.dart
**Rôle :** Inscription des nouveaux vendeurs

**Validations testées :**
- ✅ Tous les champs obligatoires remplis
- ✅ Format email valide
- ✅ Mot de passe suffisamment fort
- ✅ Confirmation mot de passe identique
- ✅ Numéro de téléphone au bon format
- ✅ Email unique (pas déjà utilisé)

**Test important :**
```dart
test('doit rejeter inscription si email déjà utilisé', () async {
  // Tente inscription avec email existant
  // Vérifie que l'erreur appropriée est retournée
});
```

#### seller_logout_test.dart
**Rôle :** Déconnexion sécurisée

**Fonctionnalités :**
- ✅ Suppression de la session locale
- ✅ Nettoyage des données sensibles
- ✅ Redirection vers page de connexion
- ✅ Invalidation des tokens

#### seller_forgot_password_test.dart
**Rôle :** Récupération de mot de passe oublié

**Processus testé :**
- ✅ Validation email existant
- ✅ Envoi email de réinitialisation
- ✅ Gestion des emails inexistants
- ✅ Limitation anti-spam (pas trop d'emails)

---

### 👤 Tests Particuliers

#### particulier_anonymous_auth_test.dart
**Rôle :** Connexion anonyme pour navigation sans compte

**Fonctionnalités :**
- ✅ Création utilisateur temporaire
- ✅ ID unique d'appareil
- ✅ Session limitée (lecture seule)
- ✅ Possibilité de créer compte plus tard

**Test spécial :**
```dart
test('doit créer sessions anonymes multiples distinctes', () async {
  // Vérifie que chaque session anonyme a un ID unique
  // Empêche les conflits entre utilisateurs anonymes
});
```

#### login_as_particulier_test.dart
**Rôle :** Connexion des particuliers avec compte

**Différences avec vendeurs :**
- Interface simplifiée
- Moins de données obligatoires
- Processus plus rapide

#### particulier_logout_test.dart
**Rôle :** Déconnexion particuliers

#### update_particulier_test.dart
**Rôle :** Mise à jour profil particulier

**Champs modifiables :**
- ✅ Nom, prénom
- ✅ Adresse de livraison
- ✅ Téléphone
- ✅ Préférences de notification

---

### 🎛️ Tests Controllers

#### seller_auth_controller_test.dart
**Rôle :** Logique métier pour l'authentification vendeurs

**Gestion des états :**
- `isLoading` : Chargement en cours
- `isAuthenticated` : Utilisateur connecté
- `error` : Message d'erreur à afficher
- `currentUser` : Données utilisateur actuel

**Tests d'états :**
```dart
test('doit passer en état loading pendant connexion', () async {
  // Lance la connexion
  // Vérifie que isLoading = true
  // Attend la fin, vérifie isLoading = false
});
```

#### particulier_auth_controller_test.dart
**Rôle :** Équivalent pour les particuliers

---

### 🗄️ Tests Repositories

#### seller_auth_repository_impl_test.dart
**Rôle :** Communication avec l'API Supabase pour vendeurs

**Tests d'intégration :**
- ✅ Appels API réussis
- ✅ Gestion erreurs HTTP (400, 401, 500)
- ✅ Parsing des réponses JSON
- ✅ Transformation données API → modèles Dart

#### particulier_auth_repository_impl_test.dart
**Rôle :** Équivalent pour particuliers

#### auth_repository_impl_test.dart
**Rôle :** Logique d'authentification commune

---

## 🔐 Sécurité Testée

### Validation des Données
- **Email :** Format RFC 5322 respecté
- **Mot de passe :** Minimum 8 caractères, majuscule, chiffre
- **Téléphone :** Format français (+33)

### Protection Anti-Spam
- Maximum 5 tentatives de connexion par minute
- Limitation emails de récupération (1 par heure)
- Blocage temporaire après échecs répétés

### Gestion des Sessions
- Tokens sécurisés
- Expiration automatique
- Nettoyage complet à la déconnexion

## 📊 Statistiques de Couverture

| Module | Tests | Couverture | Statut |
|--------|-------|------------|---------|
| Seller Login | 15 | 90% | ✅ Excellent |
| Seller Register | 18 | 85% | ✅ Bon |
| Particulier Auth | 12 | 80% | ✅ Bon |
| Controllers | 25 | 75% | 🟡 À améliorer |
| Repositories | 20 | 70% | 🟡 À améliorer |

## 🧪 Commandes de Test

```bash
# Tous les tests d'auth
flutter test test/unit/features/auth/

# Tests vendeurs seulement
flutter test test/unit/features/auth/ -t "seller"

# Tests particuliers seulement
flutter test test/unit/features/auth/ -t "particulier"

# Tests d'un use case spécifique
flutter test test/unit/features/auth/domain/usecases/seller_login_test.dart
```

## ⚠️ Points Critiques

### Tests de Sécurité
- **Mots de passe :** Jamais stockés en clair dans les tests
- **Tokens :** Utiliser des valeurs factices
- **API Keys :** Mocks seulement, jamais de vraies clés

### Tests Fragiles
- **Timing :** Tests de session peuvent être sensibles au timing
- **Mocks :** Bien simuler les vrais comportements API
- **États :** Vérifier tous les états de chargement

## 🚀 Améliorations Planifiées

- [ ] Tests de performance (vitesse de connexion)
- [ ] Tests d'accessibilité
- [ ] Tests avec vraies données (environnement de test)
- [ ] Tests de charge (connexions multiples)
- [ ] Tests de sécurité avancés (attaques CSRF, XSS)

## 🔍 Déboguer les Tests d'Auth

```bash
# Test avec logs détaillés
flutter test test/unit/features/auth/ --verbose

# Test d'un cas qui échoue
flutter test test/unit/features/auth/domain/usecases/seller_login_test.dart -t "doit échouer avec email invalide"

# Regenerer les mocks si problème
dart run build_runner build --delete-conflicting-outputs
```