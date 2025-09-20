#!/bin/bash

# 🚀 Script de configuration production
# Usage: ./scripts/setup_production.sh

set -e  # Arrêter en cas d'erreur

echo "🚀 Configuration Production - Pièces d'Occasion"
echo "================================================="

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# FONCTIONS UTILITAIRES
# =============================================================================

print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérifier qu'une commande existe
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 n'est pas installé"
        exit 1
    fi
}

# =============================================================================
# VÉRIFICATIONS PRÉREQUIS
# =============================================================================

print_step "Vérification des prérequis..."

# Vérifier Flutter
check_command "flutter"
FLUTTER_VERSION=$(flutter --version | head -n 1)
print_success "Flutter détecté: $FLUTTER_VERSION"

# Vérifier Git
check_command "git"
print_success "Git disponible"

# Vérifier que nous sommes dans un projet Flutter
if [ ! -f "pubspec.yaml" ]; then
    print_error "Ce script doit être exécuté depuis la racine du projet Flutter"
    exit 1
fi

# =============================================================================
# CONFIGURATION ENVIRONNEMENT
# =============================================================================

print_step "Configuration des environnements..."

# Créer le fichier .env s'il n'existe pas
if [ ! -f ".env" ]; then
    print_warning "Fichier .env manquant"
    echo "Voulez-vous créer un fichier .env à partir du template ? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        cp .env.example .env
        print_success "Fichier .env créé à partir du template"
        print_warning "⚠️  IMPORTANT: Modifiez le fichier .env avec vos vraies clés !"
    else
        print_error "Configuration annulée - fichier .env requis"
        exit 1
    fi
fi

# =============================================================================
# CONFIGURATION SUPABASE
# =============================================================================

print_step "Configuration Supabase..."

# Vérifier que les variables Supabase sont définies
if grep -q "your-.*-project.supabase.co" .env; then
    print_warning "Variables Supabase non configurées dans .env"
    echo "Configurez vos URLs Supabase dans le fichier .env avant de continuer"
    echo "1. Créez 3 projets Supabase (dev, staging, prod)"
    echo "2. Remplacez les URLs dans .env"
    echo "3. Relancez ce script"
    exit 1
fi

print_success "Configuration Supabase OK"

# =============================================================================
# CONFIGURATION FIREBASE
# =============================================================================

print_step "Configuration Firebase..."

# Vérifier si les fichiers de configuration Firebase existent
FIREBASE_ANDROID="android/app/google-services.json"
FIREBASE_IOS="ios/Runner/GoogleService-Info.plist"

if [ ! -f "$FIREBASE_ANDROID" ]; then
    print_warning "Fichier Firebase Android manquant: $FIREBASE_ANDROID"
    echo "Téléchargez google-services.json depuis Firebase Console"
fi

if [ ! -f "$FIREBASE_IOS" ]; then
    print_warning "Fichier Firebase iOS manquant: $FIREBASE_IOS"
    echo "Téléchargez GoogleService-Info.plist depuis Firebase Console"
fi

# =============================================================================
# GÉNÉRATION CERTIFICATS
# =============================================================================

print_step "Configuration des certificats..."

# Créer le dossier keys s'il n'existe pas
mkdir -p keys
echo "keys/" >> .gitignore

# Android Keystore
ANDROID_KEYSTORE="keys/release.keystore"
if [ ! -f "$ANDROID_KEYSTORE" ]; then
    print_warning "Keystore Android manquant"
    echo "Voulez-vous générer un keystore de release ? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Entrez le mot de passe du keystore:"
        read -s KEYSTORE_PASSWORD
        echo "Entrez l'alias de la clé:"
        read KEY_ALIAS

        keytool -genkey -v -keystore "$ANDROID_KEYSTORE" \
                -alias "$KEY_ALIAS" \
                -keyalg RSA \
                -keysize 2048 \
                -validity 10000 \
                -storepass "$KEYSTORE_PASSWORD" \
                -keypass "$KEYSTORE_PASSWORD"

        # Créer le fichier de configuration
        cat > android/key.properties << EOF
storePassword=$KEYSTORE_PASSWORD
keyPassword=$KEYSTORE_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=../../$ANDROID_KEYSTORE
EOF

        print_success "Keystore Android généré"
    fi
fi

# =============================================================================
# CONFIGURATION BUILD ANDROID
# =============================================================================

print_step "Configuration build Android..."

# Vérifier build.gradle
GRADLE_FILE="android/app/build.gradle"
if ! grep -q "signingConfigs" "$GRADLE_FILE"; then
    print_warning "Configuration de signature manquante dans build.gradle"
    cat << 'EOF' >> "$GRADLE_FILE"

// Configuration de signature
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
EOF
    print_success "Configuration de signature ajoutée"
fi

# =============================================================================
# CONFIGURATION BUILD iOS
# =============================================================================

print_step "Configuration build iOS..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Vérifier Xcode
    if command -v xcodebuild &> /dev/null; then
        print_success "Xcode disponible"

        # Ouvrir Xcode pour configuration manuelle
        echo "Voulez-vous ouvrir Xcode pour configurer les certificats ? (y/n)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            open ios/Runner.xcworkspace
            print_warning "Configurez manuellement dans Xcode:"
            echo "1. Signing & Capabilities"
            echo "2. Team et Bundle Identifier"
            echo "3. Provisioning Profile"
        fi
    else
        print_warning "Xcode non installé (requis pour iOS)"
    fi
else
    print_warning "Système non-macOS - build iOS non disponible"
fi

# =============================================================================
# INSTALLATION DÉPENDANCES
# =============================================================================

print_step "Installation des dépendances..."

# Flutter packages
flutter pub get
print_success "Packages Flutter installés"

# Code generation
flutter packages pub run build_runner build --delete-conflicting-outputs
print_success "Code généré"

# =============================================================================
# VALIDATION CONFIGURATION
# =============================================================================

print_step "Validation de la configuration..."

# Test de compilation
print_step "Test de compilation Android..."
flutter build apk --debug
if [ $? -eq 0 ]; then
    print_success "Compilation Android OK"
else
    print_error "Erreur de compilation Android"
    exit 1
fi

# Test d'analyse
print_step "Analyse statique du code..."
flutter analyze
if [ $? -eq 0 ]; then
    print_success "Analyse statique OK"
else
    print_warning "Problèmes détectés par l'analyse statique"
fi

# =============================================================================
# CONFIGURATION CI/CD
# =============================================================================

print_step "Configuration CI/CD..."

# Vérifier les secrets GitHub
if [ -d ".github" ]; then
    print_success "Workflows GitHub Actions détectés"
    echo "Configurez ces secrets dans GitHub:"
    echo "- SUPABASE_URL_PROD"
    echo "- SUPABASE_ANON_KEY_PROD"
    echo "- TECALLIANCE_API_KEY"
    echo "- FIREBASE_CONFIG (Base64)"
    echo "- ANDROID_KEYSTORE (Base64)"
    echo "- KEYSTORE_PASSWORD"
fi

# =============================================================================
# RÉSUMÉ FINAL
# =============================================================================

echo ""
echo "🎉 Configuration Production Terminée !"
echo "======================================"
echo ""
print_success "Configuration de base terminée"
echo ""
echo "📋 PROCHAINES ÉTAPES MANUELLES:"
echo ""
echo "1. 🔐 SÉCURITÉ:"
echo "   - Modifiez .env avec vos vraies clés API"
echo "   - Ajoutez les secrets dans GitHub Actions"
echo "   - Configurez les certificats iOS dans Xcode"
echo ""
echo "2. 🚀 DÉPLOIEMENT:"
echo "   - Testez: flutter build apk --release"
echo "   - Configurez Play Console et App Store Connect"
echo "   - Lancez le premier déploiement staging"
echo ""
echo "3. 📊 MONITORING:"
echo "   - Configurez Sentry pour les crashs"
echo "   - Ajoutez Google Analytics"
echo "   - Configurez les alertes de monitoring"
echo ""
echo "4. 🔧 FINALISATION:"
echo "   - Testez toutes les fonctionnalités en staging"
echo "   - Documentez le processus de déploiement"
echo "   - Formez l'équipe aux nouvelles procédures"
echo ""
print_warning "⚠️  N'oubliez pas de tester en staging avant la production !"
echo ""
echo "🔗 Ressources utiles:"
echo "   - Documentation: docs/SETUP_PRODUCTION.md"
echo "   - Variables: .env.example"
echo "   - Workflows: .github/workflows/"
echo ""