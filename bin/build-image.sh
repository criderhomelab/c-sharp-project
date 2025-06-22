#!/usr/bin/env bash

set -e

# Configuration
IMAGE_NAME="mywebapp:latest"
DOCKERFILE="Dockerfile"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Build Docker image for security scanning"
    echo ""
    echo "OPTIONS:"
    echo "  -t, --tag TAG       Docker image tag (default: $IMAGE_NAME)"
    echo "  -f, --file FILE     Dockerfile path (default: $DOCKERFILE)"
    echo "  -h, --help          Show this help message"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--tag)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -f|--file)
            DOCKERFILE="$2"
            shift 2
            ;;
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

# Check if Dockerfile exists
if [[ ! -f "$DOCKERFILE" ]]; then
    echo "Error: Dockerfile not found at $DOCKERFILE"
    exit 1
fi

log_info "Building Docker image: $IMAGE_NAME"
log_info "Using Dockerfile: $DOCKERFILE"

# Build the image
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" .

log_success "Docker image built successfully: $IMAGE_NAME"

# Show image details
echo ""
docker images "$IMAGE_NAME"

echo ""
log_info "Image is ready for security scanning. Run:"
echo "  ./bin/security-scan.sh -i $IMAGE_NAME"
