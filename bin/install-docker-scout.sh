#!/usr/bin/env bash

set -e

TOOL_NAME="docker scout"

echo "Checking for Docker Scout..."

# Docker Scout is built into Docker Desktop and newer Docker Engine versions
if docker scout --help &> /dev/null; then
    echo "Docker Scout is already available:"
    docker scout version 2>/dev/null || echo "Docker Scout is installed and ready"
    exit 0
fi

echo "Docker Scout not found. Checking Docker version..."
docker --version

echo ""
echo "Docker Scout requires Docker Engine 24.0+ or Docker Desktop."
echo "Please update Docker to the latest version to use Docker Scout."
echo ""
echo "To install/update Docker:"
echo "  - On Ubuntu: https://docs.docker.com/engine/install/ubuntu/"
echo "  - Docker Desktop: https://www.docker.com/products/docker-desktop/"
echo ""
echo "After updating Docker, Docker Scout should be available automatically."

exit 1
