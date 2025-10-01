# Guide de Déploiement - Pièces d'Occasion

## 🎯 Vue d'Ensemble

Ce guide couvre le déploiement complet de l'application **Pièces d'Occasion** sur les trois plateformes : **iOS**, **Android**, et **Web**.

**Environnements** :
- 🧪 **Development** : Tests internes
- 🚀 **Staging** : Pre-production
- ✅ **Production** : Utilisateurs finaux

---

## 📋 Pré-requis

### Outils Requis

```bash
# Flutter SDK
flutter --version  # >= 3.27.0

# Dart SDK
dart --version     # >= 3.6.0

# Xcode (macOS uniquement pour iOS)
xcodebuild -version  # >= 15.0

# Android Studio / Android SDK
android --version    # SDK >= 34

# Firebase CLI
firebase --version   # >= 13.0.0

# Fastlane (CI/CD)
fastlane --version   # >= 2.220.0
```

### Comptes Nécessaires

- ✅ **Apple Developer Account** ($99/an) - Pour iOS
- ✅ **Google Play Console** ($25 one-time) - Pour Android
- ✅ **Firebase Project** (gratuit) - Pour notifications
- ✅ **Supabase Project** (gratuit jusqu'à 500MB) - Backend
- ✅ **OneSignal Account** (gratuit) - Push notifications

---

## 🔐 Configuration des Environnements

### 1. Variables d'Environnement

Créer les fichiers `.env` :

**`.env.development`**
```env
# Supabase
SUPABASE_URL=https://dev-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...dev-key
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...dev-service-key

# TecAlliance API
TECALLIANCE_API_KEY=dev-api-key-123
TECALLIANCE_BASE_URL=https://vehicle-identification.tecalliance.services/

# OneSignal
ONESIGNAL_APP_ID=dev-onesignal-app-id

# Environment
ENVIRONMENT=development
DEBUG_MODE=true
```

**`.env.staging`**
```env
# Mêmes clés avec valeurs staging
ENVIRONMENT=staging
DEBUG_MODE=false
```

**`.env.production`**
```env
# Mêmes clés avec valeurs production
ENVIRONMENT=production
DEBUG_MODE=false
```

### 2. Secrets Management

**JAMAIS committer les fichiers `.env` dans Git !**

```bash
# .gitignore
.env
.env.*
!.env.example
```

**Pour CI/CD** : Utiliser GitHub Secrets, GitLab Variables, etc.

---

## 📱 Déploiement iOS

### Pré-requis iOS

1. **Certificats Apple** :
   - Development Certificate
   - Distribution Certificate
   - Push Notification Certificate

2. **Provisioning Profiles** :
   - Development Profile
   - App Store Distribution Profile

3. **App Store Connect** :
   - App ID configuré
   - Bundle Identifier : `com.piecesdoccasion.app`

### Configuration Xcode

```bash
# Ouvrir le projet iOS
open ios/Runner.xcworkspace
```

**Dans Xcode** :

1. **Signing & Capabilities**
   - Team : Sélectionner votre équipe Apple Developer
   - Bundle Identifier : `com.piecesdoccasion.app`
   - Signing : Automatic

2. **Info.plist** (ios/Runner/Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Nous avons besoin d'accéder à votre caméra pour prendre des photos de pièces.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Nous avons besoin d'accéder à vos photos pour sélectionner des images.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Nous utilisons votre localisation pour trouver des pièces près de chez vous.</string>
```

### Build iOS

#### Development Build

```bash
# Clean
flutter clean
flutter pub get

# Build iOS en mode debug
flutter build ios --debug --flavor development -t lib/main_development.dart

# Installer sur simulateur
flutter run --debug --flavor development -t lib/main_development.dart
```

#### Production Build

```bash
# Build iOS en mode release
flutter build ios --release --flavor production -t lib/main_production.dart

# Créer archive Xcode
cd ios
xcodebuild archive \
  -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath build/Runner.xcarchive

# Exporter IPA
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportPath build/ipa \
  -exportOptionsPlist ExportOptions.plist
```

### Upload vers App Store

#### Méthode 1 : Xcode

1. Ouvrir `ios/Runner.xcworkspace`
2. Product → Archive
3. Distribute App → App Store Connect
4. Upload

#### Méthode 2 : CLI (Recommandé CI/CD)

```bash
# Avec Fastlane
cd ios
fastlane beta  # TestFlight
fastlane release  # Production
```

#### Méthode 3 : Transporter App

1. Télécharger [Transporter](https://apps.apple.com/app/transporter/id1450874784)
2. Drag & drop le fichier `.ipa`
3. Deliver

### App Store Connect - Configuration

1. **App Information**
   - Nom : Pièces d'Occasion
   - Catégorie : Shopping
   - Sous-catégorie : Automotive

2. **Pricing**
   - Gratuit

3. **App Privacy**
   - Renseigner les données collectées (email, localisation, etc.)

4. **Screenshots** (obligatoire)
   - iPhone 6.7" : 1290x2796px
   - iPhone 6.5" : 1242x2688px
   - iPhone 5.5" : 1242x2208px
   - iPad Pro 12.9" : 2048x2732px

5. **App Review Information**
   - Compte de test avec identifiants
   - Notes pour les reviewers

### TestFlight (Beta Testing)

```bash
# Upload vers TestFlight
flutter build ipa --release
xcrun altool --upload-app --type ios --file build/ios/ipa/*.ipa \
  --username "your@email.com" --password "app-specific-password"
```

---

## 🤖 Déploiement Android

### Configuration Gradle

**`android/app/build.gradle`**

```gradle
android {
    namespace "com.piecesdoccasion.app"
    compileSdk 34

    defaultConfig {
        applicationId "com.piecesdoccasion.app"
        minSdk 24
        targetSdk 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

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
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    flavorDimensions "environment"
    productFlavors {
        development {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
        }
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
        }
        production {
            dimension "environment"
        }
    }
}
```

### Génération de Keystore

```bash
# Créer keystore de production
keytool -genkey -v \
  -keystore ~/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload \
  -storetype JKS

# Sauvegarder les infos dans android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>/upload-keystore.jks
```

**IMPORTANT** : Sauvegarder le keystore en lieu sûr ! Impossible de publier des mises à jour sans.

### Build Android

#### Development Build

```bash
flutter clean
flutter pub get

# APK Debug
flutter build apk --debug --flavor development -t lib/main_development.dart

# Installer sur émulateur/device
flutter run --debug --flavor development -t lib/main_development.dart
```

#### Production Build

```bash
# App Bundle (recommandé pour Play Store)
flutter build appbundle --release --flavor production -t lib/main_production.dart

# APK (pour distribution directe)
flutter build apk --release --flavor production -t lib/main_production.dart --split-per-abi
```

**Résultat** :
- App Bundle : `build/app/outputs/bundle/productionRelease/app-production-release.aab`
- APKs : `build/app/outputs/flutter-apk/app-production-release.apk`

### Upload vers Google Play Console

#### 1. Création de l'Application

1. Aller sur [Google Play Console](https://play.google.com/console)
2. Créer application
3. Nom : **Pièces d'Occasion**
4. Langue par défaut : Français
5. Type : Application

#### 2. Configuration Store Listing

**Détails**
- Description courte (80 caractères max)
- Description complète (4000 caractères max)
- Catégorie : Shopping
- Tags : Auto, Pièces, Occasion

**Graphiques**
- Icône : 512x512px (PNG)
- Feature Graphic : 1024x500px
- Screenshots :
  - Minimum 2 par type d'appareil
  - Téléphone : 16:9 ou 9:16
  - Tablette 7" : Optionnel
  - Tablette 10" : Optionnel

#### 3. Configuration du Contenu

**Classification du contenu** :
- Questionnaire Google Play
- Indiquer : Shopping, pas de contenu mature

**Pays de distribution** :
- Sélectionner : France, Belgique, Suisse, Luxembourg

**Tarification** :
- Gratuit

#### 4. Release Management

**Track de Test (Internal/Closed/Open)**

```bash
# Upload vers Internal Testing
cd android
./gradlew bundleProductionRelease

# Ou avec Fastlane
fastlane android beta
```

**Production Release**

1. Aller dans "Release" → "Production"
2. Créer nouvelle version
3. Upload `.aab`
4. Notes de version (multilingues)
5. Enregistrer
6. Review → "Envoyer pour examen"

**Délai de review** : 1-7 jours généralement

---

## 🌐 Déploiement Web

### Configuration Web

**`web/index.html`**

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">

  <!-- SEO -->
  <title>Pièces d'Occasion - Trouvez vos pièces auto</title>
  <meta name="description" content="Marketplace de pièces automobiles d'occasion entre particuliers et professionnels">
  <meta name="keywords" content="pièces auto, occasion, automobile, marketplace">

  <!-- Open Graph -->
  <meta property="og:title" content="Pièces d'Occasion">
  <meta property="og:description" content="Marketplace de pièces automobiles d'occasion">
  <meta property="og:image" content="/assets/images/og-image.jpg">

  <!-- PWA -->
  <link rel="manifest" href="/manifest.json">
  <meta name="theme-color" content="#007AFF">
  <link rel="apple-touch-icon" href="/icons/Icon-192.png">

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="/favicon.png">
</head>
<body>
  <script src="main.dart.js" type="application/javascript"></script>
</body>
</html>
```

**`web/manifest.json`** (PWA)

```json
{
  "name": "Pièces d'Occasion",
  "short_name": "PiecesOccasion",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#FFFFFF",
  "theme_color": "#007AFF",
  "description": "Marketplace de pièces automobiles d'occasion",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "/icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    },
    {
      "src": "/icons/Icon-maskable-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "maskable"
    },
    {
      "src": "/icons/Icon-maskable-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ]
}
```

### Build Web

```bash
# Build Production
flutter build web --release --web-renderer canvaskit

# Avec dart2js optimizations
flutter build web --release \
  --web-renderer canvaskit \
  --dart2js-optimization=O4

# Build avec source maps (debugging)
flutter build web --profile --source-maps
```

**Résultat** : `build/web/`

### Hosting Options

#### Option 1 : Firebase Hosting (Recommandé)

```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialiser
firebase init hosting

# Sélectionner:
# - Public directory: build/web
# - Single-page app: Yes
# - GitHub workflows: Optional

# Deploy
firebase deploy --only hosting
```

**Configuration** (`firebase.json`) :

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(jpg|jpeg|gif|png|svg|webp)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      },
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

**URL finale** : `https://pieces-occasion.web.app`

#### Option 2 : Vercel

```bash
# Installer Vercel CLI
npm install -g vercel

# Deploy
cd build/web
vercel --prod
```

**Configuration** (`vercel.json`) :

```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ],
  "headers": [
    {
      "source": "/assets/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    }
  ]
}
```

#### Option 3 : Netlify

```bash
# Créer netlify.toml
[build]
  publish = "build/web"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

# Deploy
netlify deploy --prod --dir=build/web
```

#### Option 4 : Custom Server (Nginx)

**`/etc/nginx/sites-available/pieces-occasion`**

```nginx
server {
    listen 80;
    server_name pieces-occasion.fr www.pieces-occasion.fr;

    root /var/www/pieces-occasion/build/web;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### PWA - Service Worker

**Générer service worker** :

```bash
# Le service worker est généré automatiquement par Flutter
# Fichier: build/web/flutter_service_worker.js
```

**Activer PWA** :

Dans `web/index.html` :

```html
<script>
  if ('serviceWorker' in navigator) {
    window.addEventListener('flutter-first-frame', function () {
      navigator.serviceWorker.register('flutter_service_worker.js');
    });
  }
</script>
```

---

## 🚀 CI/CD - GitHub Actions

### Workflow iOS

**`.github/workflows/ios-deploy.yml`**

```yaml
name: Deploy iOS

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  deploy-ios:
    runs-on: macos-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '15.0'

      - name: Import certificates
        env:
          CERTIFICATE_BASE64: ${{ secrets.IOS_CERTIFICATE_BASE64 }}
          CERTIFICATE_PASSWORD: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
        run: |
          echo $CERTIFICATE_BASE64 | base64 --decode > certificate.p12
          security create-keychain -p "" build.keychain
          security import certificate.p12 -k ~/Library/Keychains/build.keychain -P $CERTIFICATE_PASSWORD -T /usr/bin/codesign
          security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/build.keychain

      - name: Build iOS
        run: flutter build ios --release --no-codesign

      - name: Build & Upload to TestFlight
        run: |
          cd ios
          fastlane beta
        env:
          FASTLANE_USER: ${{ secrets.APPLE_ID }}
          FASTLANE_PASSWORD: ${{ secrets.APPLE_PASSWORD }}
```

### Workflow Android

**`.github/workflows/android-deploy.yml`**

```yaml
name: Deploy Android

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  deploy-android:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Decode keystore
        env:
          KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
        run: echo $KEYSTORE_BASE64 | base64 --decode > android/app/upload-keystore.jks

      - name: Create key.properties
        env:
          KEYSTORE_PASSWORD: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
        run: |
          echo "storePassword=$KEYSTORE_PASSWORD" > android/key.properties
          echo "keyPassword=$KEY_PASSWORD" >> android/key.properties
          echo "keyAlias=$KEY_ALIAS" >> android/key.properties
          echo "storeFile=upload-keystore.jks" >> android/key.properties

      - name: Build App Bundle
        run: flutter build appbundle --release

      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}
          packageName: com.piecesdoccasion.app
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: production
          status: completed
```

### Workflow Web

**`.github/workflows/web-deploy.yml`**

```yaml
name: Deploy Web

on:
  push:
    branches:
      - main

jobs:
  deploy-web:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Build Web
        run: flutter build web --release --web-renderer canvaskit

      - name: Deploy to Firebase Hosting
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: pieces-occasion
```

---

## 📊 Monitoring Post-Déploiement

### Crashlytics (Firebase)

```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}
```

### Analytics (Firebase)

```dart
// Track events
FirebaseAnalytics.instance.logEvent(
  name: 'app_opened',
  parameters: {'platform': Platform.operatingSystem},
);
```

### Performance Monitoring

```dart
// Trace custom metrics
final trace = FirebasePerformance.instance.newTrace('fetch_conversations');
await trace.start();
await fetchConversations();
trace.stop();
```

---

## 🔗 Checklist Finale Pre-Launch

### iOS

- [ ] Certificats et Provisioning Profiles valides
- [ ] Screenshots pour toutes les tailles d'écran
- [ ] Description App Store en français
- [ ] Privacy Policy URL configurée
- [ ] Support URL configuré
- [ ] Compte de test fourni aux reviewers
- [ ] Version de test uploadée sur TestFlight
- [ ] Beta testing effectué (minimum 10 testeurs)

### Android

- [ ] Keystore sauvegardé en lieu sûr
- [ ] Screenshots pour téléphones et tablettes
- [ ] Description Play Store en français
- [ ] Privacy Policy URL configurée
- [ ] Classification du contenu complétée
- [ ] Internal testing effectué
- [ ] Closed beta testing effectué (minimum 20 testeurs)

### Web

- [ ] SEO configuré (meta tags, sitemap)
- [ ] PWA fonctionnel (service worker)
- [ ] SSL/HTTPS activé
- [ ] Performance Lighthouse > 90
- [ ] Responsive design testé
- [ ] Analytics configuré
- [ ] CDN pour assets statiques

---

## 📚 Ressources

- [Flutter Deployment Guide](https://docs.flutter.dev/deployment)
- [Apple App Store Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play Launch Checklist](https://developer.android.com/distribute/best-practices/launch/launch-checklist)
- [Firebase Hosting Docs](https://firebase.google.com/docs/hosting)
- [Fastlane Documentation](https://docs.fastlane.tools/)

---

**Dernière mise à jour** : 30/09/2025
**Mainteneur** : Équipe DevOps
**Version** : 1.0.0