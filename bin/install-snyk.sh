#!/usr/bin/env bash

set -e

TOOL_NAME="snyk"

echo "Checking for $TOOL_NAME installation..."

if command -v $TOOL_NAME &> /dev/null; then
    echo "$TOOL_NAME is already installed:"
    $TOOL_NAME --version
    exit 0
fi

echo "Installing $TOOL_NAME..."

# Check if npm is available
if ! command -v npm &> /dev/null; then
    echo "npm is required to install Snyk. Installing Node.js and npm..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install Snyk globally
npm install -g snyk

# Verify installation
if command -v $TOOL_NAME &> /dev/null; then
    echo "$TOOL_NAME installed successfully:"
    $TOOL_NAME --version
    echo ""
    echo "Note: You'll need to authenticate with 'snyk auth' before first use"
else
    echo "Failed to install $TOOL_NAME"
    exit 1
fi
