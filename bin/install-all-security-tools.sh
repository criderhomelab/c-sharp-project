#!/usr/bin/env bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

BIN_DIR="$(dirname "$0")"
TOOLS=("trivy" "docker-scout" "snyk" "grype")

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Install all security scanning tools"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "This script will install:"
    for tool in "${TOOLS[@]}"; do
        echo "  - $tool"
    done
}

install_tool() {
    local tool=$1
    local install_script="$BIN_DIR/install-$tool.sh"
    
    echo ""
    log_info "Installing $tool..."
    
    if [[ -f "$install_script" ]]; then
        if bash "$install_script"; then
            log_success "$tool installation completed"
        else
            log_error "$tool installation failed"
            return 1
        fi
    else
        log_error "Install script not found: $install_script"
        return 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

log_info "Installing all security scanning tools..."

# Install each tool
FAILED_TOOLS=()
for tool in "${TOOLS[@]}"; do
    if ! install_tool "$tool"; then
        FAILED_TOOLS+=("$tool")
    fi
done

echo ""
echo "==========================================="
log_info "Installation Summary"
echo "==========================================="

if [[ ${#FAILED_TOOLS[@]} -eq 0 ]]; then
    log_success "All tools installed successfully!"
else
    log_warning "Some tools failed to install:"
    for tool in "${FAILED_TOOLS[@]}"; do
        echo "  - $tool"
    done
fi

echo ""
log_info "Next steps:"
echo "1. Build your Docker image: ./bin/build-image.sh"
echo "2. Run security scans: ./bin/security-scan.sh"
echo ""
echo "For Snyk, you may need to authenticate: snyk auth"
