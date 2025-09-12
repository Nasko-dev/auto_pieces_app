#!/bin/bash

# Configuration TecAlliance API (CORRECT)
BASE_URL="https://vehicle-identification.tecalliance.services"
PROVIDER_ID="25200"
API_KEY="2BeBXg6RC5myrQufHsxH8BsjG4BuhvU2Z1zn9fBukD4argoKAzJC"
TEST_PLATE="AB123CD"
COUNTRY_CODE="FR"  # France

echo "🔍 Test avec les paramètres corrects TecAlliance"
echo "=============================================="

# Endpoint correct selon la doc
ENDPOINT="/api/v1/vehicles"

echo "🧪 Test: $BASE_URL$ENDPOINT"
echo "Plaque: $TEST_PLATE"
echo "Pays: $COUNTRY_CODE"
echo ""

# Test 1: X-API-Key header
echo "📡 Method 1: X-API-Key header"
curl -s -w "\nHTTP %{http_code}\n" \
     -X GET "$BASE_URL$ENDPOINT?countryCode=$COUNTRY_CODE&registrationNumber=$TEST_PLATE" \
     -H "X-API-Key: $API_KEY" \
     -H "Accept: application/json"
echo "-------------------"

# Test 2: X-Provider header
echo "📡 Method 2: X-Provider header"
curl -s -w "\nHTTP %{http_code}\n" \
     -X GET "$BASE_URL$ENDPOINT?countryCode=$COUNTRY_CODE&registrationNumber=$TEST_PLATE" \
     -H "X-Provider: $PROVIDER_ID" \
     -H "Accept: application/json"
echo "-------------------"

# Test 3: Les deux headers
echo "📡 Method 3: X-API-Key + X-Provider"
curl -s -w "\nHTTP %{http_code}\n" \
     -X GET "$BASE_URL$ENDPOINT?countryCode=$COUNTRY_CODE&registrationNumber=$TEST_PLATE" \
     -H "X-API-Key: $API_KEY" \
     -H "X-Provider: $PROVIDER_ID" \
     -H "Accept: application/json"
echo "-------------------"

# Test 4: POST avec JSON body
echo "📡 Method 4: POST avec JSON"
curl -s -w "\nHTTP %{http_code}\n" \
     -X POST "$BASE_URL$ENDPOINT" \
     -H "X-API-Key: $API_KEY" \
     -H "X-Provider: $PROVIDER_ID" \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d "{\"countryCode\":\"$COUNTRY_CODE\",\"registrationNumber\":\"$TEST_PLATE\"}"
echo "-------------------"

# Test 5: Variantes des noms de paramètres
echo "📡 Method 5: Paramètres alternatifs"
curl -s -w "\nHTTP %{http_code}\n" \
     -X GET "$BASE_URL$ENDPOINT?country=$COUNTRY_CODE&plate=$TEST_PLATE" \
     -H "X-API-Key: $API_KEY" \
     -H "X-Provider: $PROVIDER_ID" \
     -H "Accept: application/json"
echo "-------------------"

# Test 6: Vérifier si /api/v1/swagger.json existe
echo "📡 Method 6: Test Swagger JSON"
curl -s -w "\nHTTP %{http_code}\n" "$BASE_URL/api/v1/swagger.json"

echo ""
echo "✅ Tests avec paramètres corrects terminés."