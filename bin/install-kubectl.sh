#!/usr/bin/env bash

# Install kubectl - Kubernetes command-line tool
# 
# PURPOSE: Prepares the development environment for Kubernetes deployment
# This script installs kubectl as preparation for deploying the containerized
# ASP.NET Core application to Kubernetes clusters.
#
# DEPLOYMENT PIPELINE:
# 1. ✅ Docker containerization (completed)
# 2. ✅ Docker Compose local deployment (completed) 
# 3. 🔄 kubectl installation (this script)
# 4. 🚀 Kubernetes manifests creation (next phase)
# 5. 🚀 K8s cluster deployment (future)
#
# Use this when you're ready to move from Docker Compose to Kubernetes deployment.

set -e

TOOL_NAME="kubectl"
INSTALL_DIR="/usr/local/bin"

echo "Checking for $TOOL_NAME installation..."

if command -v $TOOL_NAME &> /dev/null; then
    echo "$TOOL_NAME is already installed:"
    $TOOL_NAME version --client
    exit 0
fi

echo "Installing $TOOL_NAME..."

# Detect architecture
ARCH=$(uname -m)
case $ARCH in
    "x86_64"|"amd64")
        KUBECTL_ARCH="amd64"
        ;;
    "aarch64"|"arm64")
        KUBECTL_ARCH="arm64"
        ;;
    "armv7l")
        KUBECTL_ARCH="arm"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        echo "Defaulting to amd64..."
        KUBECTL_ARCH="amd64"
        ;;
esac

echo "Detected architecture: $ARCH -> kubectl-$KUBECTL_ARCH"

# Get latest stable version
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
echo "Installing kubectl version: $KUBECTL_VERSION"

# Download and install kubectl
curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/$KUBECTL_ARCH/kubectl"
curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/$KUBECTL_ARCH/kubectl.sha256"

# Verify checksum
echo "Verifying checksum..."
if ! echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check; then
    echo "Checksum verification failed!"
    rm -f kubectl kubectl.sha256
    exit 1
fi

# Install kubectl
chmod +x kubectl
mv kubectl $INSTALL_DIR/
rm -f kubectl.sha256

# Verify installation
if command -v $TOOL_NAME &> /dev/null; then
    echo "$TOOL_NAME installed successfully:"
    $TOOL_NAME version --client
    echo ""
    echo "✅ kubectl installation complete!"
    echo ""
    echo "🚀 NEXT STEPS for Kubernetes deployment:"
    echo "  1. Create Kubernetes manifests in deployments/k8s/"
    echo "  2. Set up a Kubernetes cluster (minikube, kind, or cloud provider)"
    echo "  3. Deploy the application: kubectl apply -f deployments/k8s/"
    echo ""
    echo "📋 Current kubectl commands for verification:"
    echo "  kubectl version --client    # Verify kubectl installation"
    echo "  kubectl cluster-info        # Check cluster connectivity (when available)"
    echo "  kubectl config get-contexts # List available clusters"
else
    echo "Failed to install $TOOL_NAME"
    exit 1
fi
