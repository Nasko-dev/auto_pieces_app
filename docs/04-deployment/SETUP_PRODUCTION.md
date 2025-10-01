# 🚀 Guide de Configuration Production

## 📋 Vue d'ensemble

Ce guide détaille **étape par étape** comment configurer ton projet pour la production. Tu vas passer d'un projet de développement à une application prête pour les stores !

---

## 🎯 Ce qu'on va faire

### ✅ Configuration complète production
1. **Variables d'environnement** sécurisées
2. **Certificats et signatures** iOS/Android
3. **Firebase** pour push notifications
4. **Supabase** environnements multiples
5. **Monitoring** erreurs et analytics
6. **Scripts de déploiement** automatisés

---

## 📂 Fichiers créés pour toi

J'ai créé ces fichiers essentiels :

### 🔧 `.env.example`
Template complet avec toutes les variables nécessaires :
- Supabase (dev/staging/prod)
- Firebase (Android/iOS/Web)
- TecAlliance API
- Stripe paiements
- Sentry monitoring
- Google Analytics

### ⚙️ `lib/src/core/config/environment_config.dart`
Classe Dart qui gère automatiquement la configuration selon l'environnement.

### 🚀 `scripts/setup_production.sh`
Script automatisé qui configure tout en une fois.

---

## 🛠️ Étapes de Configuration

### **Étape 1 : Variables d'environnement**

#### 1.1 Copier le template
```bash
cp .env.example .env
```

#### 1.2 Configurer tes vraies valeurs
Ouvre `.env` et remplace toutes les valeurs `your-*` par tes vraies clés :

```env
# Exemple de ce que tu dois remplir
SUPABASE_URL_PROD=https://ton-projet-prod.supabase.co
SUPABASE_ANON_KEY_PROD=eyJhbGciOiJIUzI1NiIs...
TECALLIANCE_API_KEY=ta-vraie-cle-tecalliance
FIREBASE_ANDROID_API_KEY=AIzaSyB...
```

### **Étape 2 : Supabase Multi-Environnements**

#### 2.1 Créer 3 projets Supabase
1. **Development** : `ton-projet-dev`
2. **Staging** : `ton-projet-staging`
3. **Production** : `ton-projet-prod`

#### 2.2 Configuration chaque projet
Pour chaque projet Supabase :

```sql
-- 1. Copier ton schema de dev vers staging/prod
-- 2. Configurer RLS (Row Level Security)
-- 3. Configurer les webhooks si nécessaire
-- 4. Tester la connectivité
```

#### 2.3 Récupérer les clés
Dans chaque projet Supabase → Settings → API :
- URL du projet
- Clé `anon` (publique)
- Clé `service_role` (secrète - pour serveur uniquement)

### **Étape 3 : Firebase Configuration**

#### 3.1 Créer projet Firebase
1. Aller sur [Firebase Console](https://console.firebase.google.com)
2. Créer un nouveau projet `pieces-occasion`
3. Activer Authentication, Analytics, Crashlytics

#### 3.2 Configurer Android
```bash
# Dans Firebase Console
1. Ajouter une app Android
2. Package name: com.piecesdoccasion.app
3. Télécharger google-services.json
4. Placer dans android/app/google-services.json
```

#### 3.3 Configurer iOS
```bash
# Dans Firebase Console
1. Ajouter une app iOS
2. Bundle ID: com.piecesdoccasion.app
3. Télécharger GoogleService-Info.plist
4. Placer dans ios/Runner/GoogleService-Info.plist
```

### **Étape 4 : Certificats Android**

#### 4.1 Générer le keystore
```bash
keytool -genkey -v -keystore android/app/release.keystore \
        -alias pieces-occasion \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000
```

#### 4.2 Configurer build.gradle
Créer `android/key.properties` :
```properties
storePassword=ton-mot-de-passe
keyPassword=ton-mot-de-passe
keyAlias=pieces-occasion
storeFile=release.keystore
```

#### 4.3 Modifier android/app/build.gradle
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### **Étape 5 : Certificats iOS**

#### 5.1 Configuration Xcode (Mac uniquement)
```bash
# Ouvrir le projet iOS
open ios/Runner.xcworkspace

# Dans Xcode, configurer :
1. Signing & Capabilities
2. Team (ton Apple Developer Account)
3. Bundle Identifier: com.piecesdoccasion.app
4. Provisioning Profile
```

#### 5.2 Créer App Store Connect
1. Aller sur [App Store Connect](https://appstoreconnect.apple.com)
2. Créer nouvelle app
3. Bundle ID : `com.piecesdoccasion.app`
4. Configurer métadonnées

### **Étape 6 : Configuration CI/CD**

#### 6.1 Secrets GitHub
Aller dans ton repo GitHub → Settings → Secrets :

```yaml
# Variables de production
SUPABASE_URL_PROD: https://ton-projet-prod.supabase.co
SUPABASE_ANON_KEY_PROD: eyJhbGciOiJIUzI1NiIs...
TECALLIANCE_API_KEY: ta-cle-tecalliance

# Firebase (encoder en base64)
FIREBASE_CONFIG_ANDROID: <base64 de google-services.json>
FIREBASE_CONFIG_IOS: <base64 de GoogleService-Info.plist>

# Android signing
ANDROID_KEYSTORE: <base64 du fichier .keystore>
KEYSTORE_PASSWORD: ton-mot-de-passe
KEY_ALIAS: pieces-occasion

# Monitoring
SENTRY_DSN: https://...@sentry.io/...
```

#### 6.2 Modifier les workflows
Les workflows GitHub Actions sont déjà optimisés ! Il faut juste :
1. Ajouter les secrets ci-dessus
2. Tester un push sur `main`
3. Vérifier que ça compile en production

### **Étape 7 : Monitoring Production**

#### 7.1 Sentry (Crash Reporting)
```bash
# 1. Créer compte sur sentry.io
# 2. Créer projet Flutter
# 3. Récupérer DSN
# 4. Ajouter dans .env
SENTRY_DSN=https://...@sentry.io/...
```

#### 7.2 Google Analytics
```bash
# 1. Créer propriété GA4
# 2. Récupérer Measurement ID
# 3. Ajouter dans .env
GA_MEASUREMENT_ID=G-XXXXXXXXXX
```

---

## 🚀 Script Automatisé

Pour simplifier, lance le script que j'ai créé :

```bash
# Rendre exécutable
chmod +x scripts/setup_production.sh

# Lancer la configuration
./scripts/setup_production.sh
```

Ce script va :
- ✅ Vérifier tous les prérequis
- ✅ Configurer les environnements
- ✅ Générer les certificats
- ✅ Tester la compilation
- ✅ Valider la configuration

---

## 🧪 Tests de Validation

### Test 1 : Compilation Release
```bash
# Android
flutter build apk --release

# iOS (Mac uniquement)
flutter build ios --release
```

### Test 2 : Variables d'environnement
```dart
// Ajouter dans main.dart temporairement
import 'package:cente_pice/src/core/config/environment_config.dart';

void main() {
  EnvironmentConfig.printCurrentConfig();
  EnvironmentConfig.validateConfiguration();
  // ... reste du code
}
```

### Test 3 : Connexion Supabase
```bash
# Tester les 3 environnements
flutter test test/integration/supabase_connection_test.dart
```

---

## 📊 Monitoring Production

### Dashboard à surveiller :
1. **Supabase Dashboard** : Base de données, auth, API calls
2. **Firebase Console** : Crashlytics, Analytics, Performance
3. **Sentry** : Erreurs et exceptions
4. **Google Analytics** : Usage utilisateurs

### Alertes à configurer :
- Taux d'erreur > 1%
- Temps réponse API > 2s
- Crash rate > 0.1%
- Downtime > 1 minute

---

## 🔐 Sécurité Production

### ✅ Checklist sécurité :
- [ ] Variables sensibles dans .env (jamais committées)
- [ ] Row Level Security (RLS) activé sur Supabase
- [ ] Rate limiting configuré
- [ ] HTTPS uniquement
- [ ] Certificats SSL valides
- [ ] Backup automatique base de données
- [ ] Monitoring des accès suspicieux

---

## 🚨 Dépannage

### Problème : "Variables d'environnement non trouvées"
```bash
# Solution
1. Vérifier que .env existe
2. Vérifier le format des variables
3. Redémarrer l'app complètement
```

### Problème : "Erreur de signature Android"
```bash
# Solution
1. Vérifier android/key.properties
2. Vérifier que le keystore existe
3. Tester avec : keytool -list -v -keystore release.keystore
```

### Problème : "Firebase non configuré"
```bash
# Solution
1. Vérifier google-services.json
2. Vérifier GoogleService-Info.plist
3. Clean et rebuild : flutter clean && flutter pub get
```

---

## 🎯 Résultat Final

Une fois tout configuré, tu auras :

### ✅ 3 Environnements complets :
- **Development** : Pour le développement quotidien
- **Staging** : Pour tester avant production
- **Production** : Pour les vrais utilisateurs

### ✅ Déploiement automatisé :
- Push sur `main` → Tests → Build → Deploy staging
- Tag release → Tests → Build → Deploy production

### ✅ Monitoring complet :
- Erreurs tracées avec Sentry
- Usage mesuré avec Analytics
- Performance monitorée avec Firebase

### ✅ Sécurité enterprise :
- Certificats valides
- Variables sécurisées
- Base de données protégée

---

## 📞 Support

Si tu as des problèmes :
1. Vérifie d'abord ce guide
2. Lance `./scripts/setup_production.sh` pour diagnostics
3. Consulte les logs dans les dashboards
4. Teste étape par étape

**Le projet est déjà excellent - cette configuration le rend juste parfait pour la production ! 🚀**