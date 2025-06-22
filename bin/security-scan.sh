#!/usr/bin/env bash

set -e

# Configuration
IMAGE_NAME="mywebapp:latest"
REPORTS_DIR="./security-reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BIN_DIR="./bin"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 [OPTIONS] [TOOL]"
    echo ""
    echo "Security scanning tool for Docker images"
    echo ""
    echo "OPTIONS:"
    echo "  -i, --image IMAGE    Docker image to scan (default: $IMAGE_NAME)"
    echo "  -o, --output DIR     Output directory for reports (default: $REPORTS_DIR)"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "TOOL:"
    echo "  trivy               Run Trivy scan only"
    echo "  docker-scout        Run Docker Scout scan only"
    echo "  snyk                Run Snyk scan only"
    echo "  grype               Run Grype scan only"
    echo "  all                 Run all available scanners (default)"
    echo ""
    echo "Examples:"
    echo "  $0                          # Run all scanners on default image"
    echo "  $0 trivy                    # Run only Trivy"
    echo "  $0 -i myapp:v1.0 all       # Run all scanners on specific image"
}

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

ensure_tool_installed() {
    local tool=$1
    local install_script="$BIN_DIR/install-$tool.sh"
    
    if [[ -f "$install_script" ]]; then
        log_info "Ensuring $tool is installed..."
        bash "$install_script"
    else
        log_error "Install script not found: $install_script"
        return 1
    fi
}

check_image_exists() {
    if ! docker image inspect "$IMAGE_NAME" &> /dev/null; then
        log_error "Docker image '$IMAGE_NAME' not found. Please build the image first:"
        echo "  docker build -t $IMAGE_NAME ."
        exit 1
    fi
}

create_reports_dir() {
    mkdir -p "$REPORTS_DIR"
    log_info "Reports will be saved to: $REPORTS_DIR"
}

run_trivy_scan() {
    log_info "Running Trivy scan..."
    ensure_tool_installed "trivy"
    
    local report_file="$REPORTS_DIR/trivy_${TIMESTAMP}.json"
    local summary_file="$REPORTS_DIR/trivy_${TIMESTAMP}_summary.txt"
    local sbom_cyclonedx_file="$REPORTS_DIR/trivy_${TIMESTAMP}_sbom.cdx"
    local sbom_spdx_file="$REPORTS_DIR/trivy_${TIMESTAMP}_sbom.spdx.json"
    
    # Run comprehensive scan with JSON output
    trivy image --format json --output "$report_file" "$IMAGE_NAME"
    
    # Generate human-readable summary
    trivy image --format table "$IMAGE_NAME" > "$summary_file"
    
    # Generate SBOM in CycloneDX format
    trivy image --format cyclonedx --output "$sbom_cyclonedx_file" "$IMAGE_NAME"
    
    # Generate SBOM in SPDX JSON format
    trivy image --format spdx-json --output "$sbom_spdx_file" "$IMAGE_NAME"
    
    log_success "Trivy scan completed. Reports saved:"
    echo "  - JSON: $report_file"
    echo "  - Summary: $summary_file"
    echo "  - SBOM (CycloneDX): $sbom_cyclonedx_file"
    echo "  - SBOM (SPDX JSON): $sbom_spdx_file"
}

run_docker_scout_scan() {
    log_info "Running Docker Scout scan..."
    ensure_tool_installed "docker-scout"
    
    local report_file="$REPORTS_DIR/docker-scout_${TIMESTAMP}.json"
    local summary_file="$REPORTS_DIR/docker-scout_${TIMESTAMP}_summary.txt"
    
    # Run Docker Scout scan
    if docker scout cves --format sarif --output "$report_file" "$IMAGE_NAME" 2>/dev/null; then
        docker scout cves "$IMAGE_NAME" > "$summary_file" 2>/dev/null || true
        log_success "Docker Scout scan completed. Reports saved:"
        echo "  - SARIF: $report_file"
        echo "  - Summary: $summary_file"
    else
        log_warning "Docker Scout scan failed or not available"
        return 1
    fi
}

run_snyk_scan() {
    log_info "Running Snyk scan..."
    ensure_tool_installed "snyk"
    
    local report_file="$REPORTS_DIR/snyk_${TIMESTAMP}.json"
    local summary_file="$REPORTS_DIR/snyk_${TIMESTAMP}_summary.txt"
    
    # Check if user is authenticated
    if ! snyk auth --version &> /dev/null; then
        log_warning "Snyk authentication required. Please run 'snyk auth' first."
        return 1
    fi
    
    # Run container scan
    if snyk container test --json "$IMAGE_NAME" > "$report_file" 2>/dev/null; then
        snyk container test "$IMAGE_NAME" > "$summary_file" 2>/dev/null || true
        log_success "Snyk scan completed. Reports saved:"
        echo "  - JSON: $report_file"
        echo "  - Summary: $summary_file"
    else
        log_warning "Snyk container scan failed"
        return 1
    fi
}

run_grype_scan() {
    log_info "Running Grype scan..."
    ensure_tool_installed "grype"
    
    local report_file="$REPORTS_DIR/grype_${TIMESTAMP}.json"
    local summary_file="$REPORTS_DIR/grype_${TIMESTAMP}_summary.txt"
    
    # Run Grype scan
    grype -o json "$IMAGE_NAME" > "$report_file"
    grype "$IMAGE_NAME" > "$summary_file"
    
    log_success "Grype scan completed. Reports saved:"
    echo "  - JSON: $report_file"
    echo "  - Summary: $summary_file"
}

# Parse command line arguments
TOOL="all"
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--image)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -o|--output)
            REPORTS_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        trivy|docker-scout|snyk|grype|all)
            TOOL="$1"
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Main execution
log_info "Starting security scan for image: $IMAGE_NAME"

check_image_exists
create_reports_dir

case $TOOL in
    trivy)
        run_trivy_scan
        ;;
    docker-scout)
        run_docker_scout_scan
        ;;
    snyk)
        run_snyk_scan
        ;;
    grype)
        run_grype_scan
        ;;
    all)
        log_info "Running all available security scanners..."
        echo ""
        
        # Run all scanners, but don't fail if one fails
        run_trivy_scan || log_warning "Trivy scan failed"
        echo ""
        run_docker_scout_scan || log_warning "Docker Scout scan failed"
        echo ""
        run_snyk_scan || log_warning "Snyk scan failed"
        echo ""
        run_grype_scan || log_warning "Grype scan failed"
        ;;
esac

echo ""
log_success "Security scanning completed! Check reports in: $REPORTS_DIR"
echo ""
echo "Report files generated:"
ls -la "$REPORTS_DIR/"*"$TIMESTAMP"* 2>/dev/null || echo "No reports found"
