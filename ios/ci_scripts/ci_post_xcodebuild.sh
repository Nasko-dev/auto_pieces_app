#!/bin/bash

# Script de post-build pour Xcode Cloud
# Exécuté après chaque build Xcode Cloud pour nettoyage et vérification

set -e

echo "🧹 [Xcode Cloud] Script de post-build démarré"

# 1. Vérification du build
echo "✅ [1/3] Vérification du build réussi..."
if [ "$CI_XCODEBUILD_EXIT_CODE" = "0" ]; then
    echo "✅ Build réussi avec code de sortie : $CI_XCODEBUILD_EXIT_CODE"
else
    echo "❌ Build échoué avec code de sortie : $CI_XCODEBUILD_EXIT_CODE"
fi

# 2. Informations sur l'artefact
echo "📦 [2/3] Informations sur l'artefact..."
echo "   - Produit : $CI_PRODUCT"
echo "   - Version : $CI_BUNDLE_VERSION"
echo "   - Build : $CI_BUILD_NUMBER"
echo "   - Schéma : $CI_XCODEBUILD_SCHEME"

# 3. Nettoyage (optionnel)
echo "🗑️  [3/3] Nettoyage des fichiers temporaires..."
cd $CI_WORKSPACE
# Nettoyer les fichiers de cache Flutter si nécessaire
rm -rf .dart_tool/build || true
rm -rf build/ios/intermediates || true

echo "🎉 [Xcode Cloud] Post-build terminé !"