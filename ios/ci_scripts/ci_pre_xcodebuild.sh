#!/bin/bash

# Script de pré-build pour Xcode Cloud
# Exécuté avant chaque build Xcode Cloud pour préparer Flutter et CocoaPods

set -e  # Arrêter en cas d'erreur

echo "🚀 [Xcode Cloud] Script de pré-build Flutter/CocoaPods démarré"
echo "📂 Répertoire de travail : $(pwd)"
echo "🔧 Variables d'environnement:"
echo "   - HOME: $HOME"
echo "   - CI_WORKSPACE: $CI_WORKSPACE"
echo "   - PATH: $PATH"
echo "   - PUB_CACHE: $PUB_CACHE (local)"

# Variables avec chemins Xcode Cloud
FLUTTER_ROOT="$HOME/flutter"
PUB_CACHE="$HOME/.pub-cache"

# Créer les répertoires nécessaires
mkdir -p "$PUB_CACHE"
export PUB_CACHE="$PUB_CACHE"

# 1. Installation de Flutter si nécessaire
echo "📱 [1/6] Vérification/Installation de Flutter..."
if [ ! -d "$FLUTTER_ROOT" ]; then
    echo "⬇️  Téléchargement de Flutter (stable)..."
    cd $HOME
    /usr/bin/git clone https://github.com/flutter/flutter.git -b stable --depth 1
    export PATH="$FLUTTER_ROOT/bin:$PATH"
    $FLUTTER_ROOT/bin/flutter --version
else
    echo "✅ Flutter déjà installé"
    export PATH="$FLUTTER_ROOT/bin:$PATH"
    $FLUTTER_ROOT/bin/flutter --version
fi

# 2. Retour au répertoire du projet
echo "📂 [2/6] Navigation vers le répertoire du projet..."
if [ -z "$CI_WORKSPACE" ]; then
    # Fallback si CI_WORKSPACE est vide
    PROJECT_ROOT="/Volumes/workspace/repository"
    echo "⚠️  CI_WORKSPACE vide, utilisation du fallback: $PROJECT_ROOT"
else
    PROJECT_ROOT="$CI_WORKSPACE"
fi

cd "$PROJECT_ROOT"
echo "✅ Répertoire de travail : $(pwd)"

# 3. Mise à jour du numéro de build avec CI_BUILD_NUMBER d'Xcode Cloud
echo "🔢 [3/8] Mise à jour du numéro de build..."
if [ ! -z "$CI_BUILD_NUMBER" ]; then
    echo "   Utilisation du build number Xcode Cloud: $CI_BUILD_NUMBER"
    # Lire la version actuelle
    CURRENT_VERSION=$(grep 'version:' pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
    # Mettre à jour avec le nouveau build number
    sed -i.bak "s/version: .*/version: $CURRENT_VERSION+$CI_BUILD_NUMBER/" pubspec.yaml
    echo "   Version mise à jour: $CURRENT_VERSION+$CI_BUILD_NUMBER"
else
    echo "   ⚠️  CI_BUILD_NUMBER non défini, utilisation de la version existante"
fi

# 4. Installation des dépendances Flutter
echo "📦 [4/8] Installation des dépendances Flutter..."
$FLUTTER_ROOT/bin/flutter pub get

# 5. Génération du code
echo "🔧 [5/8] Génération du code (build_runner)..."
$FLUTTER_ROOT/bin/dart run build_runner build --delete-conflicting-outputs || {
    echo "⚠️  Génération de code échouée, continuation sans erreur..."
}

# 6. Préparation iOS et installation des CocoaPods
echo "🍎 [6/8] Préparation des artefacts iOS..."
$FLUTTER_ROOT/bin/flutter precache --ios

echo "📦 [7/8] Installation des dépendances CocoaPods..."
cd ios
# Mettre à jour les specs CocoaPods
/usr/local/bin/pod repo update --silent || true
# Installer les pods
/usr/local/bin/pod install --repo-update

# 8. Vérification finale
echo "✅ [8/8] Vérification des fichiers générés..."
cd "$PROJECT_ROOT"

# Vérifier que les fichiers critiques existent
if [ -f "ios/Flutter/Generated.xcconfig" ]; then
    echo "✅ Generated.xcconfig trouvé"
else
    echo "❌ Generated.xcconfig manquant - Tentative de régénération..."
    $FLUTTER_ROOT/bin/flutter build ios --debug --no-codesign
fi

if [ -f "ios/Podfile.lock" ]; then
    echo "✅ Podfile.lock trouvé"
else
    echo "❌ Podfile.lock manquant - Problème avec CocoaPods"
    exit 1
fi

echo "🎉 [Xcode Cloud] Pré-build terminé avec succès !"
echo "📊 Résumé :"
echo "   - Flutter: $($FLUTTER_ROOT/bin/flutter --version | head -n1)"
echo "   - CocoaPods: $(/usr/local/bin/pod --version)"
echo "   - Project Root: $PROJECT_ROOT"