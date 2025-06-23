# 🚀 Getting Started Guide

Welcome to the **Secure Cross-Platform ASP.NET Core Application**! This guide will get you up and running quickly using our pre-configured development container.

## 📋 Table of Contents

1. [Prerequisites](#-prerequisites)
2. [Devcontainer Setup](#-devcontainer-setup-recommended)
3. [Environment Configuration](#-environment-configuration)
4. [Running the Application Stack](#-running-the-application-stack)
5. [Development Workflow](#-development-workflow)
6. [Alternative Local Setup](#-alternative-local-setup)
7. [Troubleshooting](#-troubleshooting)

---

## 🛠️ Prerequisites

### Required Software

| Tool | Purpose | Installation |
|------|---------|--------------|
| **Docker Desktop** | Container runtime | [Windows](https://docs.docker.com/desktop/install/windows-install/) \| [Mac](https://docs.docker.com/desktop/install/mac-install/) |
| **VS Code** | IDE with devcontainer support | [Download](https://code.visualstudio.com/) |
| **Dev Containers Extension** | VS Code devcontainer integration | [Install from Marketplace](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) |
| **Git** | Version control | [Windows](https://git-scm.com/download/win) \| Mac: `brew install git` |

### System Requirements

- **Memory**: 8GB RAM minimum (16GB recommended)
- **Storage**: 10GB free space
- **Network**: Internet connection for Docker image downloads

### Docker Configuration Notes

#### Windows Users (DinD vs DooD)
- **Docker-in-Docker (DinD)**: Default setup - Docker Desktop runs containers inside WSL2
- **Docker-outside-of-Docker (DooD)**: Advanced setup - Share Docker socket with host
- **Recommended**: Use default DinD setup unless you have specific requirements

#### Mac Users (DinD vs DooD)
- **Docker-in-Docker (DinD)**: Default setup - Docker Desktop manages containers
- **Docker-outside-of-Docker (DooD)**: Share Docker socket with host system
- **Recommended**: Use default DinD setup for better isolation

> **💡 Most users should use the default Docker Desktop configuration (DinD). Advanced users who need to share Docker daemon state between host and containers can configure DooD by mounting the Docker socket.**

---

## 📦 Devcontainer Setup (Recommended)

### Step 1: Get the Code

```bash
# Clone the repository
git clone <repository-url>
cd <repository-name>
```

### Step 2: Open in VS Code

```bash
# Open the project in VS Code
code .
```

### Step 3: Start the Devcontainer

When VS Code opens, you'll see a notification:
> **"Folder contains a Dev Container configuration file."**

**Click "Reopen in Container"**

Alternatively, use the Command Palette:
- **Windows**: `Ctrl+Shift+P`
- **Mac**: `Cmd+Shift+P`
- Type: `Dev Containers: Reopen in Container`

### Step 4: Wait for Container Build

The first time will take 2-5 minutes as it:
- Downloads the base container image
- Installs all development tools (Make, .NET SDK, etc.)
- Configures the environment

### Step 5: Verify Devcontainer Setup

Once the container is ready, open a new terminal in VS Code and verify:

```bash
# Check that tools are available
make --version     # Should show make version
docker --version   # Should show Docker version  
dotnet --version   # Should show .NET SDK version

# Verify you're in the container
whoami            # Should show "vscode"
pwd               # Should show /workspaces/<repo-name>
```

🎉 **You're now inside the devcontainer with all tools pre-installed!**

---

## ⚙️ Environment Configuration

### Step 1: Understand the Configuration Files

The application uses environment files for configuration:

- **`.local`** - Docker Compose environment variables (for containers)
- **`.local.sh`** - Shell environment variables (for local development)

### Step 2: Choose Your Approach

#### Option A: Use Default Passwords (Quick Start)

```bash
# Generate default configuration files
make setup
```

This creates secure files with default development passwords.

#### Option B: Customize Your Passwords (Recommended)

```bash
# 1. Generate custom passwords (choose strong passwords)
export MY_SA_PASSWORD="MyStrong#Admin!Pass123"
export MY_APP_PASSWORD="MyApp#User!Pass456"

# 2. Create .local file with your passwords
cat > .local << EOF
CS_MSSQL_CONN=Server=mssql;Database=WebAppDB;User Id=WebAppUser;Password=${MY_APP_PASSWORD};TrustServerCertificate=true
SA_PASSWORD=${MY_SA_PASSWORD}
WEBAPP_USER_PASSWORD=${MY_APP_PASSWORD}
EOF

# 3. Create .local.sh file for shell environment
cat > .local.sh << EOF
export CS_MSSQL_CONN='Server=mssql;Database=WebAppDB;User Id=WebAppUser;Password=${MY_APP_PASSWORD};TrustServerCertificate=true'
export SA_PASSWORD='${MY_SA_PASSWORD}'
export WEBAPP_USER_PASSWORD='${MY_APP_PASSWORD}'
EOF

# 4. Secure the files
chmod 600 .local .local.sh

# 5. Verify setup
make setup
```

### Step 3: Verify Configuration

The `make setup` command will show you:
- ✅ Configuration file status
- 🔐 Masked password display (for security)
- 📋 Environment loading status
- 🛡️ Security recommendations

```bash
make setup
```

**Sample Output:**
```
[INFO]  Setting up development environment...

📁 Configuration Files: 
  • .local     - Docker Compose environment variables
  • .local.sh  - Shell environment variables (for local development)

[OK] .local file exists 
📋 Current configuration: 
  CS_MSSQL_CONN 
    └─ Connection: Server=mssql;Database=WebAppDB;User Id=WebAppUser;Password=****;TrustServerCertificate=true

[OK] .local.sh file exists 
    └─ Environment: Not loaded (run: source .local.sh)
```

---

## 🏃‍♂️ Running the Application Stack

### Step 1: Build the Docker Images

```bash
# Build all required Docker images
make build
```

This builds:
- 📦 **Frontend**: ASP.NET Core web application (`ghcr.io/timcrider/apps/compose-frontend`)
- 🗄️ **SQL Server**: Microsoft SQL Server 2022 Express
- ⚙️ **Database Setup**: Initialization and user creation scripts

### Step 2: Start the Full Stack

```bash
# Start all services: mssql + mssql-setup + frontend
make up
```

This orchestrates:
1. **SQL Server** starts and initializes
2. **Database Setup** creates application database and user
3. **Frontend** application connects and starts
4. **Health checks** ensure everything is working

### Step 3: Access Your Application

🌐 **Web Application**: http://localhost:8080
🗄️ **Database**: localhost:1433 (if you need direct access)

### Step 4: Verify Everything Works

```bash
# Check service status
make status

# View logs (useful for troubleshooting)
make logs

# Test database connectivity
make db-shell
```

**Expected Status Output:**
```
Service Status:
NAME                    IMAGE                                           PORTS
compose-frontend-1      ghcr.io/timcrider/apps/compose-frontend       0.0.0.0:8080->8080/tcp
compose-mssql-1         mcr.microsoft.com/mssql/server:2022-latest    0.0.0.0:1433->1433/tcp
compose-mssql-setup-1   ghcr.io/timcrider/apps/compose-frontend       

✅ Services are running
🌐 Access URLs:
  • Web Application: http://127.0.0.1:8080
  • Database Server: 127.0.0.1:1433
```

---

## 💼 Development Workflow

### Daily Development Commands

```bash
# 🌅 Start your day
make up              # Start all services

# 🔧 Development work
# Edit code in src/ directory using VS Code
# Changes are automatically reflected

# 🔄 After making changes
make build          # Rebuild if Dockerfile changed
make up             # Restart services

# 🗄️ Database operations
make db-shell       # SQL Server management
make db-reset       # Fresh database
make db-migrate     # Run EF migrations

# 📊 Check status
make status         # Service health
make logs           # View logs

# 🌙 End of day
make down           # Stop services
```

### Development Modes

#### Full Stack Mode (Default)
```bash
make up
# Everything runs in containers
# Access: http://localhost:8080
```

#### Local Development Mode
```bash
# Start only database in container
make dev

# Run application locally (new terminal)
source .local.sh
cd src
dotnet run
# Access: http://localhost:5000
```

### Quality Assurance

```bash
# Run all quality checks
make check          # Tests + Security + Linting

# Individual checks
make test           # Unit tests
make security       # Security scanning
make lint           # Code formatting
```

---

## � Security Scanning

The application includes comprehensive security scanning capabilities to identify vulnerabilities in both your code and Docker images. The devcontainer comes with all security tools pre-installed.

### Available Security Tools

| Tool | Purpose | What it Scans |
|------|---------|---------------|
| **Trivy** | Container vulnerability scanner | Docker images, OS packages, dependencies |
| **Grype** | Software composition analysis | Application dependencies and libraries |
| **Syft** | Software bill of materials (SBOM) | Generate inventory of components |

### Quick Security Scan

```bash
# Run comprehensive security scan (all tools)
make security
```

This command automatically:
1. 🔍 Detects the current Docker image name
2. 🧪 Runs Trivy vulnerability scan
3. 📊 Runs Grype dependency analysis
4. 📋 Generates software bill of materials
5. 📄 Creates detailed security reports

### Manual Security Tool Usage

#### Trivy - Container Vulnerability Scanning

```bash
# Scan the built application image
trivy image ghcr.io/timcrider/apps/compose-frontend:latest

# Scan with specific severity levels
trivy image --severity HIGH,CRITICAL ghcr.io/timcrider/apps/compose-frontend:latest

# Generate detailed JSON report
trivy image --format json --output trivy-report.json ghcr.io/timcrider/apps/compose-frontend:latest

# Scan local filesystem for vulnerabilities
trivy fs .
```

#### Grype - Software Composition Analysis

```bash
# Scan the application image for known vulnerabilities
grype ghcr.io/timcrider/apps/compose-frontend:latest

# Scan with specific output format
grype ghcr.io/timcrider/apps/compose-frontend:latest -o json

# Scan local directory
grype dir:.
```

#### Syft - Software Bill of Materials

```bash
# Generate SBOM for the application image
syft ghcr.io/timcrider/apps/compose-frontend:latest

# Generate SBOM in SPDX format
syft ghcr.io/timcrider/apps/compose-frontend:latest -o spdx-json

# Generate SBOM for local directory
syft dir:.
```

### Security Scan Results

The security scan generates reports in the `security-reports/` directory:

```bash
# View generated security reports
ls -la security-reports/
# trivy-report.json      - Trivy vulnerability scan
# grype-report.json      - Grype dependency analysis  
# sbom-report.spdx       - Software bill of materials
```

### Understanding Security Reports

#### Trivy Report Structure
```json
{
  "Results": [
    {
      "Target": "image-name",
      "Vulnerabilities": [
        {
          "VulnerabilityID": "CVE-2023-1234",
          "Severity": "HIGH",
          "Title": "Vulnerability description",
          "FixedVersion": "1.2.3"
        }
      ]
    }
  ]
}
```

#### Common Vulnerability Severities
- 🔴 **CRITICAL**: Immediate attention required
- 🟠 **HIGH**: Should be fixed soon
- 🟡 **MEDIUM**: Fix when convenient
- 🟢 **LOW**: Informational, low priority

### CI/CD Integration

For automated security scanning in your CI/CD pipeline:

```bash
# Exit with error code if vulnerabilities found
make security

# Check exit code
echo $?  # 0 = no issues, non-zero = vulnerabilities found
```

### Security Best Practices

#### During Development
```bash
# Run security scans regularly
make security

# Before committing code
make check  # Includes security scanning

# Before building releases
make build
make security
```

#### Image Security Hygiene
- 🔄 **Regular Updates**: Keep base images current
- 🔍 **Scan Early**: Run security scans during development
- 📋 **Track Dependencies**: Monitor third-party libraries
- 🚫 **Fix Vulnerabilities**: Address issues promptly

### Installing Security Tools Locally

If you're not using the devcontainer, install security tools manually:

#### Install Trivy
```bash
# Mac (using Homebrew)
brew install trivy

# Linux (using apt)
sudo apt-get update
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

# Windows (using Chocolatey)
choco install trivy
```

#### Install Grype
```bash
# Mac (using Homebrew)
brew tap anchore/grype
brew install grype

# Linux (using curl)
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

# Windows (using Chocolatey)
choco install grype
```

#### Install Syft
```bash
# Mac (using Homebrew)
brew tap anchore/syft
brew install syft

# Linux (using curl)
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# Windows (using Chocolatey)
choco install syft
```

### Troubleshooting Security Scans

**Problem**: "Security scan script not found"
```bash
# Solution: Ensure you're in the project root and the script exists
ls -la bin/security-scan.sh
# If missing, check if you're in the correct directory
pwd  # Should show /workspaces/<repo-name>
```

**Problem**: "Docker image not found"
```bash
# Solution: Build the image first
make build
make security
```

**Problem**: High memory usage during scans
```bash
# Solution: Scan specific components separately
trivy image --light ghcr.io/timcrider/apps/compose-frontend:latest
grype ghcr.io/timcrider/apps/compose-frontend:latest --quiet
```

---

## �🖥️ Alternative Local Setup

> **⚠️ Note**: The devcontainer approach above is strongly recommended. This section is for users who prefer traditional local development.

### Windows Local Setup

```powershell
# Install Make (if not using devcontainer)
choco install make

# Install .NET SDK
winget install Microsoft.DotNet.SDK.8

# Clone and run
git clone <repository-url>
cd <repository-name>
make setup
make build
make up
```

### Mac Local Setup

```bash
# Install Make (if needed)
xcode-select --install

# Install .NET SDK
brew install dotnet

# Clone and run
git clone <repository-url>
cd <repository-name>
make setup
make build
make up
```

---

## 🔧 Troubleshooting

### Devcontainer Issues

**Problem**: "Failed to connect to the remote extension host server"
```bash
# Solution: Restart VS Code and Docker Desktop
# 1. Close VS Code
# 2. Restart Docker Desktop
# 3. Reopen VS Code and try again
```

**Problem**: Devcontainer build fails
```bash
# Solution: Clean Docker and rebuild
docker system prune -a
# Reopen in container
```

### Application Issues

**Problem**: Port 8080 already in use
```bash
# Find and kill the process
# Mac/Linux:
lsof -ti:8080 | xargs kill -9

# Windows:
netstat -ano | findstr :8080
# Note the PID and: taskkill /PID <pid> /F
```

**Problem**: Database connection errors
```bash
# Clean restart
make clean
make setup
make build
make up
```

**Problem**: "Docker daemon not running"
```bash
# Start Docker Desktop
# Windows: Start Menu → Docker Desktop
# Mac: Applications → Docker Desktop
# Wait for Docker to fully start before proceeding
```

### Getting Help

1. **Check Service Status**: `make status`
2. **View Detailed Logs**: `make logs`
3. **Clean Reset**: `make clean && make build && make up`
4. **Verify Environment**: `make setup`

---

## 🎯 Next Steps

### 1. Explore the Application
- Browse http://localhost:8080
- Test database functionality
- Review the sample data and pages

### 2. Learn the Codebase
- **Application**: `src/` directory
- **Infrastructure**: `deployments/compose/`
- **Build System**: `Makefile`
- **Configuration**: `.local` and `.local.sh`

### 3. Start Developing
- Modify Razor pages in `src/Pages/`
- Update styles in `src/wwwroot/css/`
- Add controllers and models following ASP.NET Core patterns
- Database changes via Entity Framework migrations

### 4. Advanced Topics
- **Security**: Review `SECURITY.md` for security best practices
- **CI/CD**: Use `make security` for automated security scanning
- **Production**: Never use development passwords in production!

---

**Happy Coding! 🚀**

*You're now ready to build amazing applications with ASP.NET Core and SQL Server!*
