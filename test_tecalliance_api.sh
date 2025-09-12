#!/bin/bash

# Configuration TecAlliance API
BASE_URL="https://vehicle-identification.tecalliance.services"
PROVIDER_ID="25200"
API_KEY="2BeBXg6RC5myrQufHsxH8BsjG4BuhvU2Z1zn9fBukD4argoKAzJC"
TEST_PLATE="AB123CD"

echo "🔍 Test de l'API TecAlliance Vehicle Identification"
echo "================================================"

# Endpoints possibles à tester
endpoints=(
    "/api/v1/vehicles/lookup"
    "/api/vehicles/search"
    "/api/vrm/lookup"
    "/vrm/search"
    "/vehicle-identification"
    "/lookup"
    "/search"
)

# Headers d'authentification possibles
echo "📡 Test des endpoints avec différentes méthodes d'auth..."
echo ""

for endpoint in "${endpoints[@]}"; do
    echo "🧪 Test: $BASE_URL$endpoint"
    
    # Test 1: Query parameters
    echo "   → Method 1: Query params"
    curl -s -w "HTTP %{http_code}" \
         -X GET "$BASE_URL$endpoint?providerId=$PROVIDER_ID&apiKey=$API_KEY&vrm=$TEST_PLATE" \
         -H "Accept: application/json" | head -3
    echo ""
    
    # Test 2: Headers
    echo "   → Method 2: Headers"
    curl -s -w "HTTP %{http_code}" \
         -X GET "$BASE_URL$endpoint?vrm=$TEST_PLATE" \
         -H "X-Provider-Id: $PROVIDER_ID" \
         -H "X-API-Key: $API_KEY" \
         -H "Accept: application/json" | head -3
    echo ""
    
    # Test 3: Bearer token
    echo "   → Method 3: Bearer"
    curl -s -w "HTTP %{http_code}" \
         -X GET "$BASE_URL$endpoint?vrm=$TEST_PLATE" \
         -H "Authorization: Bearer $API_KEY" \
         -H "Accept: application/json" | head -3
    echo ""
    
    # Test 4: POST request
    echo "   → Method 4: POST"
    curl -s -w "HTTP %{http_code}" \
         -X POST "$BASE_URL$endpoint" \
         -H "Content-Type: application/json" \
         -H "Accept: application/json" \
         -d "{\"providerId\":\"$PROVIDER_ID\",\"apiKey\":\"$API_KEY\",\"vrm\":\"$TEST_PLATE\"}" | head -3
    echo ""
    echo "-------------------"
done

echo "✅ Tests terminés. Recherchez les réponses avec HTTP 200 ou des données JSON."