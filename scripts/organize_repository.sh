#!/bin/bash

# 🧹 Script d'organisation du repository GitHub
# Usage: ./scripts/organize_repository.sh

set -e

echo "🧹 ORGANISATION REPOSITORY - Pièces d'Occasion"
echo "=============================================="

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# =============================================================================
# 1. ANALYSE BRANCHES EXISTANTES
# =============================================================================

print_header "Analyse des branches existantes"

echo "📊 Branches locales:"
git branch | sed 's/^/  /'

echo ""
echo "📊 Branches remote:"
git branch -r | sed 's/^/  /'

echo ""
echo "📊 Statistiques:"
LOCAL_COUNT=$(git branch | wc -l)
REMOTE_COUNT=$(git branch -r | grep -v HEAD | wc -l)
echo "  • Branches locales: $LOCAL_COUNT"
echo "  • Branches remote: $REMOTE_COUNT"

# =============================================================================
# 2. IDENTIFICATION BRANCHES OBSOLÈTES
# =============================================================================

print_header "Identification branches obsolètes"

echo "🔍 Branches avec fautes de frappe à renommer:"
echo "  • feathure/* → feature/*"
echo "  • style1 → feature/ui-improvements"

echo ""
echo "🔍 Branches potentiellement obsolètes (anciennes):"
git for-each-ref --format='%(refname:short) %(committerdate)' refs/heads | sort -k2 | head -10

# =============================================================================
# 3. VÉRIFICATION BRANCHES MERGÉES
# =============================================================================

print_header "Vérification branches mergées"

echo "✅ Branches déjà mergées dans develop:"
git checkout develop > /dev/null 2>&1 || echo "Branch develop introuvable"
MERGED_BRANCHES=$(git branch --merged develop | grep -v "develop" | grep -v "main" | xargs || echo "Aucune")
if [ "$MERGED_BRANCHES" != "Aucune" ]; then
    echo "$MERGED_BRANCHES" | sed 's/^/  • /'
else
    echo "  Aucune branche mergée trouvée"
fi

# =============================================================================
# 4. PLAN DE NETTOYAGE
# =============================================================================

print_header "Plan de nettoyage recommandé"

cat << 'EOF'

📋 ACTIONS RECOMMANDÉES:

🗂️  STRUCTURE CIBLE:
    main/              # Production
    develop/           # Développement
    staging/           # Pré-production

    feature/           # Nouvelles fonctionnalités
    bugfix/            # Corrections bugs
    hotfix/            # Corrections urgentes
    release/           # Préparation releases

🧹 NETTOYAGE À FAIRE:

1. RENOMMER (fautes de frappe):
   feathure/Loinding-pro-particulier → feature/loading-pro-particulier
   feathure/demande → feature/request-management
   feathure/déposit-annonce → feature/post-advertisement
   feathure/home-pro → feature/professional-home
   feathure/recherche-piece → feature/parts-search
   style1 → feature/ui-improvements

2. SUPPRIMER (si mergées):
   • Toutes les branches --merged develop
   • Branches de test obsolètes
   • Branches avec noms incohérents

3. CRÉER STRUCTURE:
   • develop (si manquante)
   • staging (si manquante)
   • Protection branches main/develop

4. ORGANISER:
   • Trier par type (feature/, bugfix/, etc.)
   • Standardiser noms en anglais
   • Nettoyer branches remote orphelines

EOF

# =============================================================================
# 5. SCRIPT INTERACTIF
# =============================================================================

print_header "Actions automatiques"

echo "Voulez-vous procéder au nettoyage automatique ? (y/n)"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

    print_info "Création branches principales manquantes..."

    # Créer develop si n'existe pas
    if ! git show-ref --verify --quiet refs/heads/develop; then
        print_warning "Création branch develop depuis main"
        git checkout main
        git checkout -b develop
        git push origin develop
        print_success "Branch develop créée"
    fi

    # Créer staging si n'existe pas
    if ! git show-ref --verify --quiet refs/heads/staging; then
        print_warning "Création branch staging depuis develop"
        git checkout develop
        git checkout -b staging
        git push origin staging
        print_success "Branch staging créée"
    fi

    print_info "Nettoyage branches mergées..."

    # Retour sur develop pour nettoyage
    git checkout develop

    # Supprimer branches locales mergées (sauf main/develop/staging)
    MERGED_TO_DELETE=$(git branch --merged | grep -v -E "main|develop|staging|\*" | xargs)
    if [ -n "$MERGED_TO_DELETE" ]; then
        print_warning "Suppression branches locales mergées: $MERGED_TO_DELETE"
        echo "$MERGED_TO_DELETE" | xargs git branch -d
        print_success "Branches locales nettoyées"
    fi

    # Nettoyer références remote obsolètes
    print_info "Nettoyage références remote..."
    git remote prune origin
    print_success "Références remote nettoyées"

    print_info "Mise à jour toutes les branches..."
    git fetch --all
    print_success "Repository synchronisé"

else
    print_info "Nettoyage annulé - exécution manuelle recommandée"
fi

# =============================================================================
# 6. RAPPORT FINAL
# =============================================================================

print_header "Rapport final"

echo "📊 État après nettoyage:"
echo "  • Branches locales: $(git branch | wc -l)"
echo "  • Branches remote: $(git branch -r | grep -v HEAD | wc -l)"

echo ""
echo "🎯 PROCHAINES ÉTAPES MANUELLES:"
echo ""
echo "1. 🔄 RENOMMER BRANCHES (manuellement):"
echo "   git branch -m feathure/demande feature/request-management"
echo "   git push origin feature/request-management"
echo "   git push origin --delete feathure/demande"
echo ""
echo "2. 🛡️ CONFIGURER PROTECTIONS (GitHub Settings):"
echo "   • main: Require PR + 2 reviews + tests"
echo "   • develop: Require PR + 1 review + tests"
echo ""
echo "3. 📋 CRÉER PR TEMPLATE:"
echo "   • .github/pull_request_template.md"
echo ""
echo "4. 🏷️ STANDARDISER NOMS:"
echo "   • Tout en anglais"
echo "   • Format: type/description-with-dashes"
echo ""

print_success "Organisation repository terminée !"
echo ""
echo "📖 Consultez docs/GIT_STRATEGY.md pour la stratégie complète"
echo ""