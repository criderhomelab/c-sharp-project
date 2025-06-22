#!/usr/bin/env bash

set -e

TOOL_NAME="trivy"
INSTALL_DIR="/usr/local/bin"

echo "Checking for $TOOL_NAME installation..."

if command -v $TOOL_NAME &> /dev/null; then
    echo "$TOOL_NAME is already installed:"
    $TOOL_NAME --version
    exit 0
fi

echo "Installing $TOOL_NAME..."

# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b $INSTALL_DIR

# Verify installation
if command -v $TOOL_NAME &> /dev/null; then
    echo "$TOOL_NAME installed successfully:"
    $TOOL_NAME --version
else
    echo "Failed to install $TOOL_NAME"
    exit 1
fi
