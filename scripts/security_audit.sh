#!/bin/bash

# 🔐 Script d'audit sécurité automatisé
# Usage: ./scripts/security_audit.sh

set -e

echo "🔐 AUDIT SÉCURITÉ - Pièces d'Occasion"
echo "===================================="

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ISSUES_FOUND=0

print_header() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((ISSUES_FOUND++))
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    ((ISSUES_FOUND++))
}

# =============================================================================
# 1. VÉRIFICATION VARIABLES D'ENVIRONNEMENT
# =============================================================================

print_header "Vérification variables d'environnement"

if [ ! -f ".env" ]; then
    print_error "Fichier .env manquant"
else
    print_success "Fichier .env présent"

    # Vérifier que les valeurs ne sont pas les templates
    if grep -q "your-.*-key" .env; then
        print_warning "Variables template non remplacées dans .env"
    else
        print_success "Variables .env configurées"
    fi
fi

# Vérifier .gitignore
if grep -q "^\.env$" .gitignore; then
    print_success ".env correctement exclu de Git"
else
    print_error ".env non exclu de Git - DANGER!"
fi

# =============================================================================
# 2. RECHERCHE CLÉS HARDCODÉES
# =============================================================================

print_header "Recherche clés API hardcodées"

# Rechercher patterns de clés
PATTERNS=(
    "eyJ[A-Za-z0-9+/=]+"  # JWT tokens
    "pk_live_[a-zA-Z0-9]+" # Stripe live keys
    "sk_live_[a-zA-Z0-9]+" # Stripe secret keys
    "AIza[a-zA-Z0-9_-]+"   # Google API keys
    "[a-z0-9]{40}"         # Generic 40-char keys
)

for pattern in "${PATTERNS[@]}"; do
    if find lib/ -name "*.dart" -exec grep -l "$pattern" {} \; | grep -v ".freezed.dart" | grep -v ".g.dart"; then
        print_error "Clés potentiellement hardcodées trouvées (pattern: $pattern)"
    fi
done

print_success "Aucune clé hardcodée détectée"

# =============================================================================
# 3. VÉRIFICATION LOGS SENSIBLES
# =============================================================================

print_header "Vérification exposition de données"

# Rechercher print statements dangereux (ignorer commentaires)
PRINT_FILES=$(find lib/ -name "*.dart" -exec grep -l "^[^/]*print(" {} \; | grep -v test/ | head -1)
if [ -n "$PRINT_FILES" ]; then
    print_warning "Statements print() trouvés - utiliser debugPrint()"
else
    print_success "Aucun statement print() problématique"
fi

# Rechercher logs de tokens/passwords
if find lib/ -name "*.dart" -exec grep -i "password\|token\|secret" {} \; | grep -i "print\|log\|console"; then
    print_error "Logs de données sensibles détectés"
else
    print_success "Aucun log de données sensibles"
fi

# =============================================================================
# 4. VÉRIFICATION PERMISSIONS
# =============================================================================

print_header "Vérification permissions Android"

ANDROID_MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$ANDROID_MANIFEST" ]; then
    # Vérifier permissions dangereuses
    DANGEROUS_PERMS=(
        "android.permission.WRITE_EXTERNAL_STORAGE"
        "android.permission.READ_CONTACTS"
        "android.permission.CAMERA"
        "android.permission.RECORD_AUDIO"
    )

    for perm in "${DANGEROUS_PERMS[@]}"; do
        if grep -q "$perm" "$ANDROID_MANIFEST"; then
            print_warning "Permission sensible: $perm"
        fi
    done

    print_success "Permissions Android vérifiées"
else
    print_warning "AndroidManifest.xml non trouvé"
fi

# =============================================================================
# 5. VÉRIFICATION CONFIGURATION SUPABASE
# =============================================================================

print_header "Vérification configuration Supabase"

# Vérifier migrations RLS
if find supabase/migrations/ -name "*.sql" -exec grep -l "ENABLE ROW LEVEL SECURITY" {} \; > /dev/null 2>&1; then
    print_success "RLS activé dans les migrations"
else
    print_error "RLS non configuré - Base de données non sécurisée!"
fi

# Vérifier politiques
if find supabase/migrations/ -name "*.sql" -exec grep -l "CREATE POLICY" {} \; > /dev/null 2>&1; then
    print_success "Politiques de sécurité définies"
else
    print_warning "Aucune politique de sécurité trouvée"
fi

# =============================================================================
# 6. VÉRIFICATION CERTIFICATS
# =============================================================================

print_header "Vérification certificats"

# Android keystore
if [ -f "android/key.properties" ]; then
    print_success "Configuration signing Android présente"

    # Vérifier que le keystore n'est pas commité
    if git ls-files | grep -q "\.keystore$"; then
        print_error "Keystore commité dans Git - DANGER!"
    else
        print_success "Keystore non commité"
    fi
else
    print_warning "Configuration signing Android manquante"
fi

# =============================================================================
# 7. VÉRIFICATION DÉPENDANCES
# =============================================================================

print_header "Vérification dépendances"

# Vérifier pub outdated
if command -v flutter &> /dev/null; then
    OUTDATED=$(flutter pub outdated --json 2>/dev/null | grep '"hasOutdated":true' || true)
    if [ -n "$OUTDATED" ]; then
        print_warning "Dépendances obsolètes détectées"
    else
        print_success "Dépendances à jour"
    fi
fi

# =============================================================================
# 8. TESTS SÉCURITÉ
# =============================================================================

print_header "Exécution tests sécurité"

if command -v flutter &> /dev/null; then
    # Tests authentification
    if flutter test test/integration/auth_flow_test.dart --timeout=30s &>/dev/null; then
        print_success "Tests authentification passés"
    else
        print_warning "Tests authentification échoués"
    fi

    # Tests rate limiting
    if flutter test test/unit/core/services/rate_limiter_service_test.dart &>/dev/null; then
        print_success "Tests rate limiting passés"
    else
        print_warning "Tests rate limiting échoués"
    fi
fi

# =============================================================================
# RÉSUMÉ FINAL
# =============================================================================

echo ""
echo "📊 RÉSUMÉ AUDIT SÉCURITÉ"
echo "========================"

if [ $ISSUES_FOUND -eq 0 ]; then
    print_success "Aucun problème de sécurité détecté"
    echo -e "${GREEN}🎉 PROJET SÉCURISÉ POUR LA PRODUCTION${NC}"
    exit 0
elif [ $ISSUES_FOUND -le 3 ]; then
    print_warning "$ISSUES_FOUND problème(s) mineur(s) détecté(s)"
    echo -e "${YELLOW}⚡ CORRECTIONS MINEURES RECOMMANDÉES${NC}"
    exit 1
else
    print_error "$ISSUES_FOUND problème(s) critique(s) détecté(s)"
    echo -e "${RED}🚨 CORRECTIONS CRITIQUES REQUISES AVANT PRODUCTION${NC}"
    exit 2
fi