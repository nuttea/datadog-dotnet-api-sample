#!/bin/bash

# .NET API Sample - Test Script

set -e

BASE_URL="http://localhost:5000"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "======================================"
echo " Testing .NET 8 API"
echo "======================================"
echo ""

# Function to test endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local description=$3
    local data=$4
    
    echo -e "${BLUE}Testing:${NC} $description"
    echo -e "${YELLOW}$method $endpoint${NC}"
    
    if [ -z "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo -e "${GREEN}✅ Success (HTTP $http_code)${NC}"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
    else
        echo -e "${RED}❌ Failed (HTTP $http_code)${NC}"
        echo "$body"
    fi
    
    echo ""
    echo "--------------------------------------"
    echo ""
}

# Check if API is running
if ! curl -s "$BASE_URL/health" > /dev/null 2>&1; then
    echo -e "${RED}❌ API is not running or not reachable${NC}"
    echo "Please start the API first with: ./start.sh"
    exit 1
fi

# Run tests
test_endpoint "GET" "/health" "Health Check"

test_endpoint "GET" "/info" "Service Information"

test_endpoint "GET" "/api/weatherforecast" "Get 5-Day Weather Forecast"

test_endpoint "GET" "/api/weatherforecast/1" "Get Weather for Day 1"

test_endpoint "GET" "/api/weatherforecast/365" "Get Weather for Day 365"

test_endpoint "GET" "/api/weatherforecast/999" "Get Weather for Invalid Day (Should Fail)"

test_endpoint "POST" "/api/weatherforecast" "Create Weather Forecast" \
    '{
        "date": "2025-12-25",
        "temperatureC": 20,
        "summary": "Sunny"
    }'

echo ""
echo "======================================"
echo " Test Summary"
echo "======================================"
echo -e "${GREEN}✅ All tests completed${NC}"
echo ""
echo "You can also test interactively at:"
echo "  - Swagger UI: $BASE_URL/swagger"
echo ""
echo "View logs with:"
echo "  docker-compose logs -f dotnet-api"
echo ""

