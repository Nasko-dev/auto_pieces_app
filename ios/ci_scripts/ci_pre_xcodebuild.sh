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

# Variables avec chemins Xcode Cloud
FLUTTER_ROOT="$HOME/flutter"

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
cd $CI_WORKSPACE

# 3. Installation des dépendances Flutter
echo "📦 [3/6] Installation des dépendances Flutter..."
$FLUTTER_ROOT/bin/flutter pub get

# 4. Génération du code
echo "🔧 [4/6] Génération du code (build_runner)..."
$FLUTTER_ROOT/bin/dart run build_runner build --delete-conflicting-outputs || {
    echo "⚠️  Génération de code échouée, continuation sans erreur..."
}

# 5. Installation des CocoaPods
echo "🍎 [5/6] Installation des dépendances CocoaPods..."
cd ios
# Mettre à jour les specs CocoaPods
/usr/local/bin/pod repo update --silent || true
# Installer les pods
/usr/local/bin/pod install --repo-update

# 6. Vérification finale
echo "✅ [6/6] Vérification des fichiers générés..."
cd $CI_WORKSPACE

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
echo "   - Workspace: $CI_WORKSPACE"