#!/bin/bash

# .NET API Sample - Stop Script

echo "Stopping .NET API and Datadog Agent..."
docker compose down

echo ""
echo "To remove volumes as well, run:"
echo "  docker compose down -v"
echo ""

