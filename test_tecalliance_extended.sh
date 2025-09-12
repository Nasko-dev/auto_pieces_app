#!/bin/bash

# Configuration TecAlliance API
BASE_URL="https://vehicle-identification.tecalliance.services"
PROVIDER_ID="25200"
API_KEY="2BeBXg6RC5myrQufHsxH8BsjG4BuhvU2Z1zn9fBukD4argoKAzJC"
TEST_PLATE="AB123CD"

echo "🔍 Test étendu de l'API TecAlliance"
echo "=================================="

# Test 1: Endpoints racine et documentation
echo "📋 1. Test des endpoints de base..."
curl -s -w "\nHTTP %{http_code}\n" "$BASE_URL/"
echo ""
curl -s -w "\nHTTP %{http_code}\n" "$BASE_URL/api"
echo ""
curl -s -w "\nHTTP %{http_code}\n" "$BASE_URL/v1"
echo ""

# Test 2: Endpoints avec version dans l'URL
echo "📋 2. Test avec versions..."
versions=("v1" "v2" "api/v1" "api/v2")
for version in "${versions[@]}"; do
    echo "🧪 Test: $BASE_URL/$version/vrm"
    curl -s -w "HTTP %{http_code}" "$BASE_URL/$version/vrm?providerId=$PROVIDER_ID&apiKey=$API_KEY&registrationNumber=$TEST_PLATE" | head -2
    echo ""
done

# Test 3: Test du endpoint VRM simple
echo "📋 3. Test du endpoint VRM..."
echo "🧪 Test: $BASE_URL/vrm"
curl -s -w "\nHTTP %{http_code}\n" \
     -X GET "$BASE_URL/vrm?providerId=$PROVIDER_ID&apiKey=$API_KEY&registrationNumber=$TEST_PLATE" \
     -H "Accept: application/json"
echo ""

# Test 4: Test avec d'autres noms de paramètres
echo "📋 4. Test avec différents noms de paramètres..."
curl -s -w "\nHTTP %{http_code}\n" \
     "$BASE_URL/vrm?provider_id=$PROVIDER_ID&api_key=$API_KEY&registration_number=$TEST_PLATE"
echo ""

curl -s -w "\nHTTP %{http_code}\n" \
     "$BASE_URL/vrm?providerId=$PROVIDER_ID&key=$API_KEY&plate=$TEST_PLATE"
echo ""

# Test 5: Test avec méthode POST sur /vrm
echo "📋 5. Test POST sur /vrm..."
curl -s -w "\nHTTP %{http_code}\n" \
     -X POST "$BASE_URL/vrm" \
     -H "Content-Type: application/json" \
     -d "{\"providerId\":\"$PROVIDER_ID\",\"apiKey\":\"$API_KEY\",\"registrationNumber\":\"$TEST_PLATE\"}"
echo ""

# Test 6: Test des OPTIONS (CORS)
echo "📋 6. Test OPTIONS..."
curl -s -w "\nHTTP %{http_code}\n" \
     -X OPTIONS "$BASE_URL/vrm" \
     -H "Access-Control-Request-Method: GET"
echo ""

echo "✅ Tests étendus terminés."