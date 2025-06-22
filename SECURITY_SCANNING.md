# Security Scanning Setup

This directory contains scripts for comprehensive security scanning of Docker images using multiple industry-standard tools.

## Quick Start

1. **Install all security tools:**
   ```bash
   ./bin/install-all-security-tools.sh
   ```

2. **Build your Docker image:**
   ```bash
   ./bin/build-image.sh
   ```

3. **Run all security scans:**
   ```bash
   ./bin/security-scan.sh
   ```

## Tools Included

### Trivy
- **Purpose**: Comprehensive vulnerability scanner
- **Scans**: OS packages, language dependencies, secrets, misconfigurations
- **SBOMs**: Generates Software Bill of Materials in CycloneDX and SPDX formats
- **Install**: `./bin/install-trivy.sh`
- **Scan**: `./bin/security-scan.sh trivy`

### Docker Scout
- **Purpose**: Built-in Docker security scanning
- **Scans**: Vulnerabilities, base image recommendations
- **Install**: `./bin/install-docker-scout.sh` (checks Docker version)
- **Scan**: `./bin/security-scan.sh docker-scout`

### Snyk
- **Purpose**: Developer-first security scanning
- **Scans**: Known vulnerabilities, licensing issues
- **Install**: `./bin/install-snyk.sh`
- **Setup**: Run `snyk auth` after installation
- **Scan**: `./bin/security-scan.sh snyk`

### Grype
- **Purpose**: Container and filesystem vulnerability scanner
- **Scans**: OS and language vulnerabilities
- **Install**: `./bin/install-grype.sh`
- **Scan**: `./bin/security-scan.sh grype`

## Scripts Overview

### Installation Scripts
- `install-all-security-tools.sh` - Install all tools at once
- `install-trivy.sh` - Install Trivy
- `install-docker-scout.sh` - Check Docker Scout availability
- `install-snyk.sh` - Install Snyk CLI
- `install-grype.sh` - Install Grype

### Build and Scan Scripts
- `build-image.sh` - Build Docker image for scanning
- `security-scan.sh` - Main scanning script

## Usage Examples

### Build and scan with default settings:
```bash
./bin/build-image.sh
./bin/security-scan.sh
```

### Scan specific image with specific tool:
```bash
./bin/security-scan.sh -i myapp:v1.0 trivy
```

### Run all scans on custom image:
```bash
./bin/security-scan.sh -i myapp:latest all
```

### Custom output directory:
```bash
./bin/security-scan.sh -o ./custom-reports all
```

## Report Formats

Reports are generated in the `./security-reports/` directory (configurable) with timestamps:

- **Trivy**: JSON + human-readable summary + SBOMs (CycloneDX & SPDX)
- **Docker Scout**: SARIF + summary
- **Snyk**: JSON + summary  
- **Grype**: JSON + summary

Example report files:
```
security-reports/
├── trivy_20240622_143022.json
├── trivy_20240622_143022_summary.txt
├── trivy_20240622_143022_sbom.cdx
├── trivy_20240622_143022_sbom.spdx.json
├── docker-scout_20240622_143045.json
├── docker-scout_20240622_143045_summary.txt
├── snyk_20240622_143110.json
├── snyk_20240622_143110_summary.txt
├── grype_20240622_143135.json
└── grype_20240622_143135_summary.txt
```

## Requirements

- Docker (for building and scanning images)
- curl (for downloading tools)
- Node.js/npm (for Snyk, auto-installed if needed)
- Internet connection (for downloading tools and vulnerability databases)

## Best Practices

1. **Regular Scanning**: Run scans on every build
2. **Multiple Tools**: Different tools catch different vulnerabilities
3. **Review Reports**: Don't just run scans, analyze the results
4. **Update Tools**: Keep scanning tools updated for latest vulnerability data
5. **CI/CD Integration**: Integrate these scripts into your build pipeline
6. **SBOM Management**: Use generated SBOMs for supply chain security tracking

## Software Bill of Materials (SBOM)

Trivy automatically generates SBOMs in two industry-standard formats:

- **CycloneDX**: Modern, comprehensive SBOM format (`.cdx`)
- **SPDX JSON**: SPDX format in JSON (`.spdx.json`)

SBOMs provide:
- Complete inventory of software components
- License information for compliance
- Supply chain security visibility
- Vulnerability tracking across dependencies

## Troubleshooting

### Snyk Authentication
If Snyk scans fail:
```bash
snyk auth
# Follow the browser authentication flow
```

### Docker Scout Not Available
Update Docker to the latest version:
```bash
# Check Docker version
docker --version

# Update Docker if needed
# Follow: https://docs.docker.com/engine/install/
```

### Tool Installation Issues
- Ensure you have internet connectivity
- Check that curl is installed
- Verify you have write permissions to `/usr/local/bin`
- For Snyk, ensure Node.js/npm are available

### Report Directory Permissions
If reports can't be written:
```bash
mkdir -p ./security-reports
chmod 755 ./security-reports
```
