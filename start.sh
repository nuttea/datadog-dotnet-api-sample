#!/bin/bash

# .NET API Sample - Quick Start Script

set -e

echo "======================================"
echo " .NET 8 API Sample - Quick Start"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker is running${NC}"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file not found. Creating from example...${NC}"
    cat > .env << EOF
# Datadog Configuration
DD_API_KEY=your_datadog_api_key_here
DD_SITE=datadoghq.com

# Application Configuration
ASPNETCORE_ENVIRONMENT=Production
EOF
    echo -e "${YELLOW}⚠️  Please edit .env and add your Datadog API key${NC}"
    echo -e "${YELLOW}   Or run without Datadog by commenting out DD_API_KEY${NC}"
fi

echo ""
echo "Building and starting services..."
echo ""

# Build and start
docker compose up -d --build

echo ""
echo -e "${GREEN}✅ Services started successfully!${NC}"
echo ""
echo "======================================"
echo " Service URLs"
echo "======================================"
echo -e "${GREEN}API Base:${NC}        http://localhost:5000"
echo -e "${GREEN}Swagger UI:${NC}      http://localhost:5000/swagger"
echo -e "${GREEN}Health Check:${NC}    http://localhost:5000/health"
echo -e "${GREEN}Info Endpoint:${NC}   http://localhost:5000/info"
echo ""
echo "======================================"
echo " Useful Commands"
echo "======================================"
echo "View logs:           docker compose logs -f"
echo "Stop services:       docker compose down"
echo "Restart API:         docker compose restart dotnet-api"
echo "Check health:        curl http://localhost:5000/health"
echo "Test API:            ./test.sh"
echo ""

# Wait for service to be healthy
echo "Waiting for API to be ready..."
for i in {1..30}; do
    if curl -s http://localhost:5000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ API is ready!${NC}"
        break
    fi
    echo -n "."
    sleep 1
done

echo ""
echo "Run './test.sh' to test the API endpoints"
echo ""

