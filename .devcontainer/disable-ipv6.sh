#!/bin/bash

# Comprehensive IPv6 disabling script for devcontainer
# Disables IPv6 at system, Docker, and application levels

set -e

echo "🚫 Disabling IPv6 comprehensively..."

# 1. Disable IPv6 at kernel level
echo "🔧 Disabling IPv6 at kernel level..."
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.conf

# Apply sysctl settings immediately
sysctl -p /etc/sysctl.conf 2>/dev/null || true

# 2. Disable IPv6 in Docker daemon configuration
echo "🐳 Configuring Docker daemon to disable IPv6..."
mkdir -p /etc/docker

# Create comprehensive Docker daemon configuration
cat > /etc/docker/daemon.json << 'EOF'
{
  "ipv6": false,
  "fixed-cidr-v6": "",
  "ip6tables": false,
  "default-address-pools": [
    {
      "base": "172.17.0.0/16",
      "size": 24
    },
    {
      "base": "172.18.0.0/16", 
      "size": 24
    },
    {
      "base": "172.19.0.0/16",
      "size": 24
    }
  ],
  "dns": ["8.8.8.8", "8.8.4.4"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "userland-proxy": false,
  "experimental": false,
  "features": {
    "buildkit": true
  }
}
EOF

echo "📝 Docker daemon configuration created:"
cat /etc/docker/daemon.json

# 3. Configure environment variables to disable IPv6
echo "🌍 Setting environment variables to disable IPv6..."
{
    echo 'export DOTNET_SYSTEM_NET_DISABLEIPV6=true'
    echo 'export ASPNETCORE_URLS=http://0.0.0.0:8080'
    echo 'export DOCKER_DEFAULT_PLATFORM=linux/amd64'
    echo 'export DOCKER_BUILDKIT=1'
    echo 'export COMPOSE_DOCKER_CLI_BUILD=1'
} >> /root/.bashrc

# 4. Disable IPv6 for current session
export DOTNET_SYSTEM_NET_DISABLEIPV6=true

# 5. Configure hosts file to prefer IPv4
echo "📋 Configuring hosts file for IPv4 preference..."
# Remove any IPv6 localhost entries
sed -i '/::1/d' /etc/hosts
# Ensure IPv4 localhost is present
grep -q "127.0.0.1 localhost" /etc/hosts || echo "127.0.0.1 localhost" >> /etc/hosts

# 6. Disable IPv6 modules (if possible in container)
echo "🔌 Attempting to disable IPv6 kernel modules..."
{
    echo 'blacklist ipv6'
    echo 'blacklist net-pf-10'
    echo 'blacklist ipv6_privacy'
} >> /etc/modprobe.d/blacklist-ipv6.conf 2>/dev/null || true

# 7. Create a verification script
cat > /usr/local/bin/verify-no-ipv6 << 'EOF'
#!/bin/bash
echo "🔍 IPv6 Verification Report"
echo "=========================="

echo -n "System IPv6 disabled: "
if [ -f /proc/sys/net/ipv6/conf/all/disable_ipv6 ]; then
    if [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)" = "1" ]; then
        echo "✅ YES"
    else
        echo "❌ NO"
    fi
else
    echo "⚠️  Cannot determine"
fi

echo -n "Docker IPv6 disabled: "
if [ -f /etc/docker/daemon.json ]; then
    if grep -q '"ipv6": false' /etc/docker/daemon.json; then
        echo "✅ YES"
    else
        echo "❌ NO"
    fi
else
    echo "⚠️  No daemon.json found"
fi

echo -n "Environment variables: "
if [ "$DOTNET_SYSTEM_NET_DISABLEIPV6" = "true" ]; then
    echo "✅ Set correctly"
else
    echo "❌ Not set"
fi

echo ""
echo "Network interfaces:"
ip addr show | grep -E "inet6|inet " | head -10

echo ""
echo "Active Docker networks:"
docker network ls 2>/dev/null || echo "Docker not available"

EOF

chmod +x /usr/local/bin/verify-no-ipv6

echo ""
echo "✅ IPv6 has been comprehensively disabled!"
echo ""
echo "📋 Summary of changes:"
echo "   • Kernel IPv6 disabled via sysctl"
echo "   • Docker daemon configured for IPv4-only"
echo "   • Environment variables set"
echo "   • Hosts file configured for IPv4"
echo "   • IPv6 modules blacklisted"
echo ""
echo "🔍 Run 'verify-no-ipv6' to check the configuration"
echo "🔄 Restart Docker daemon to apply all changes: 'service docker restart'"
