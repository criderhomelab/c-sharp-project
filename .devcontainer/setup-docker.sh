#!/bin/bash

# Docker setup script with OS detection for devcontainer
# Automatically chooses DooD for Apple Silicon/ARM64 and DinD for x86_64

set -e

echo "🐳 Starting Docker setup with OS detection..."

# Detect architecture
ARCH=$(uname -m)
echo "📋 Detected architecture: $ARCH"

# Detect if we're in a container (devcontainer)
if [ -f /.dockerenv ]; then
    echo "📦 Running inside container (devcontainer)"
    IN_CONTAINER=true
else
    echo "🖥️  Running on host system"
    IN_CONTAINER=false
fi

# Function to install Docker Outside of Docker (DooD)
install_dood() {
    echo "🔗 Installing Docker Outside of Docker (DooD)..."
    echo "   ➤ Better for Apple Silicon/ARM64 - uses host Docker daemon"

    # Install Docker CLI only (connects to host daemon)
    curl -fsSL https://get.docker.com | sh

    # Add user to docker group
    usermod -aG docker root 2>/dev/null || true

    # Install Docker Compose
    COMPOSE_VERSION="v2.24.0"
    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Install Docker Buildx
    BUILDX_VERSION="v0.12.0"
    mkdir -p /root/.docker/cli-plugins
    curl -L "https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-amd64" -o /root/.docker/cli-plugins/docker-buildx
    chmod +x /root/.docker/cli-plugins/docker-buildx

    echo "✅ DooD installation complete"
}

# Function to install Docker in Docker (DinD)
install_dind() {
    echo "🏗️  Installing Docker in Docker (DinD)..."
    echo "   ➤ Better for x86_64 - runs separate Docker daemon"

    # Install Docker with daemon
    curl -fsSL https://get.docker.com | sh

    # Start Docker daemon
    service docker start

    # Enable Docker daemon to start automatically
    systemctl enable docker 2>/dev/null || true

    # Install Docker Compose
    apt-get update
    apt-get install -y docker-compose-plugin

    # Install Docker Buildx
    docker buildx install

    echo "✅ DinD installation complete"
}

# Main logic
case "$ARCH" in
    "aarch64"|"arm64")
        echo "🍎 Apple Silicon/ARM64 detected"
        if [ "$IN_CONTAINER" = true ]; then
            install_dood
        else
            echo "⚠️  Not in container - assuming host Docker available"
        fi
        ;;
    "x86_64"|"amd64")
        echo "🖥️  x86_64 detected"
        install_dind
        ;;
    *)
        echo "❌ Unsupported architecture: $ARCH"
        echo "   Defaulting to DinD installation..."
        install_dind
        ;;
esac

# Configure Docker for AMD64 platform (disable IPv6 implicitly)
echo "🔧 Configuring Docker defaults..."
echo 'export DOCKER_DEFAULT_PLATFORM=linux/amd64' >> /root/.bashrc
echo 'export DOCKER_BUILDKIT=1' >> /root/.bashrc
echo 'export COMPOSE_DOCKER_CLI_BUILD=1' >> /root/.bashrc

# Disable IPv6 in Docker daemon configuration
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << EOF
{
  "ipv6": false,
  "fixed-cidr-v6": "",
  "default-address-pools": [
    {
      "base": "172.17.0.0/16",
      "size": 24
    }
  ],
  "dns": ["8.8.8.8", "8.8.4.4"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

# Restart Docker if DinD was installed
if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
    echo "🔄 Restarting Docker daemon with new configuration..."
    service docker restart || true
fi

echo "🎉 Docker setup complete!"

# Run comprehensive IPv6 disabling
echo ""
echo "🚫 Disabling IPv6 comprehensively..."
/workspaces/.devcontainer/disable-ipv6.sh

echo ""
echo "📋 Configuration summary:"
echo "   • Architecture: $ARCH"
echo "   • Docker type: $([ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ] && echo "DooD (Outside)" || echo "DinD (Inside)")"
echo "   • IPv6: Disabled"
echo "   • Default platform: linux/amd64"
echo ""
echo "🔍 Verify installation:"
echo "   docker --version"
echo "   docker compose version"
echo "   docker buildx version"
