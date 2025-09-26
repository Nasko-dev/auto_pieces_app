#!/bin/bash

# Script pour configurer automatiquement la protection de branche main
# Nécessite GitHub CLI (gh) installé et authentifié

set -e

echo "🛡️  Configuration de la protection de branche 'main'"
echo "=================================================="

# Vérifier que gh CLI est installé
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) n'est pas installé"
    echo "📥 Installation : https://cli.github.com/"
    exit 1
fi

# Vérifier l'authentification
if ! gh auth status &> /dev/null; then
    echo "🔐 Authentification GitHub CLI requise"
    gh auth login
fi

REPO="Nasko-dev/auto_pieces_app"
BRANCH="main"

echo "📍 Repository: $REPO"
echo "🌿 Branche à protéger: $BRANCH"

# Configuration de la protection de branche
echo "⚙️  Application des règles de protection..."

gh api \
  --method PUT \
  "/repos/$REPO/branches/$BRANCH/protection" \
  --field required_status_checks='{
    "strict": true,
    "contexts": [
      "analyze",
      "test-unit",
      "ios-build",
      "pre-validation"
    ]
  }' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false
  }' \
  --field restrictions=null \
  --field required_conversation_resolution=true \
  --field allow_force_pushes=false \
  --field allow_deletions=false

echo "✅ Protection de branche configurée avec succès !"

# Vérification
echo "🔍 Vérification de la configuration..."
gh api "/repos/$REPO/branches/$BRANCH/protection" \
  --jq '{
    "required_status_checks": .required_status_checks.contexts,
    "required_reviews": .required_pull_request_reviews.required_approving_review_count,
    "enforce_admins": .enforce_admins.enabled,
    "allow_force_pushes": .allow_force_pushes.enabled,
    "allow_deletions": .allow_deletions.enabled
  }'

echo ""
echo "🎉 Configuration terminée !"
echo ""
echo "📋 Règles appliquées :"
echo "   • Pull Request obligatoire"
echo "   • 1 approbation minimum"
echo "   • Checks automatiques requis"
echo "   • Pas de force push"
echo "   • Pas de suppression"
echo "   • Admins inclus dans les règles"
echo ""
echo "⚠️  IMPORTANT :"
echo "   À partir de maintenant, impossible de push directement sur main"
echo "   Utiliser des Pull Requests : dev → main"
echo ""
echo "🧪 Tester avec :"
echo "   git checkout dev"
echo "   git push origin dev"
echo "   # Créer PR sur GitHub"

# Optionnel : créer une issue de suivi
read -p "📝 Créer une issue de documentation ? (y/N): " create_issue

if [[ $create_issue =~ ^[Yy]$ ]]; then
    gh issue create \
        --title "📋 Protection branche main configurée" \
        --body "✅ Protection de branche main activée

**Règles appliquées :**
- Pull Request obligatoire (1 approbation)
- Checks automatiques : analyze, test-unit, ios-build
- Pas de force push / suppression
- Administrators inclus

**Nouveau workflow :**
1. Développer sur \`dev\`
2. Push vers \`dev\`
3. Créer PR \`dev → main\`
4. Merge automatique après validation

**Liens utiles :**
- [Branch Protection Rules](https://github.com/$REPO/settings/branches)
- [Workflow iOS](https://github.com/$REPO/actions/workflows/ios_deployment.yml)
- [Setup Guide](.github/BRANCH_PROTECTION_SETUP.md)" \
        --label "automation,security"

    echo "📄 Issue créée pour documenter la configuration"
fi

echo ""
echo "🚀 Configuration terminée avec succès !"