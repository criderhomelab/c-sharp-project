# 🚀 Secure ASP.NET Core Web Application

A **production-ready ASP.NET Core 8.0** web application featuring comprehensive CRUD operations, robust testing infrastructure, and enterprise-grade security features.

## 📋 Table of Contents - Key Documents for Review

| Document | Purpose | Target Audience |
|----------|---------|----------------|
| **[🎯 Project Purpose](docs/PURPOSE.md)** | Why this project exists and what it demonstrates | **Hiring Managers & Technical Interviewers** |
| **[📖 Getting Started Guide](docs/GETTING_STARTED.md)** | Complete setup and development workflow | **DevOps Engineers & Developers** |
| **[🧪 Test Coverage Report](docs/TEST_COVERAGE_REPORT.md)** | Comprehensive test analysis (17 tests, 100% pass rate) | **QA Engineers & Technical Leaders** |
| **[🛡️ Security Scanning Report](docs/SECURITY_SCANNING_REPORT.md)** | Multi-tool vulnerability assessment | **Security Engineers & Architects** |
| **[📝 Changelog](docs/CHANGELOG.md)** | Version history and feature evolution | **Product Managers & Technical Reviewers** |
| **[🔒 Security Documentation](docs/SECURITY.md)** | Security implementation details | **Security Teams & Compliance** |

---

## ✨ Key Features

- 🛡️ **Security-First**: IPv6 disabled, environment-based secrets, minimal attack surface
- 🧪 **100% Test Coverage**: Unit tests, integration tests, and code coverage reporting
- 🐳 **Container-Ready**: Docker support with devcontainer development environment
- 📊 **Database Management**: Full CRUD operations for "Things" entity with SQL Server
- 🔍 **Security Scanning**: Integrated Trivy, Grype, and Syft security tools
- 🛠️ **Developer-Friendly**: Comprehensive Makefile automation and setup tools

## 🎯 Quick Start

### 📦 Using Devcontainer (Recommended)

The fastest way to get started is using VS Code with the devcontainer:

```bash
# 1. Clone and open in VS Code
git clone <repository-url>
cd <project-directory>
code .

# 2. Reopen in container when prompted
# VS Code will build the devcontainer automatically

# 3. Set up environment and run
make setup    # Configure environment variables
make run      # Start the application stack
```

**🌐 Application will be available at: http://localhost:8080**

### 🔧 Manual Setup

If you prefer not to use devcontainers:

```bash
# 1. Prerequisites: Docker Desktop, .NET 8.0 SDK
# 2. Configure environment
cp .local.example .local
# Edit .local with your database passwords

# 3. Start the application
make run
```

## 📋 Available Commands

Our Makefile provides comprehensive automation:

```bash
make setup     # Configure environment with detailed output
make run       # Start the application stack  
make stop      # Stop all services
make test      # Run tests with coverage reports
make build     # Build application container
make security  # Run comprehensive security scans
make clean     # Clean up containers and volumes
make db        # Access database shell
make logs      # View application logs
```
## 🧪 Testing Infrastructure

The project includes a comprehensive test suite:

### Test Coverage
- **17 tests** covering all major functionality
- **Unit Tests**: Thing model validation and business logic
- **Integration Tests**: Database operations and web endpoints  
- **DbContext Tests**: Full CRUD operations with in-memory database

### Running Tests
```bash
# Run all tests with coverage
make test

# Run tests directly with dotnet
dotnet test --logger "console;verbosity=normal"

# Generate detailed coverage reports
dotnet test --collect:"XPlat Code Coverage" --results-directory ./TestResults
```

Test reports and coverage data are saved to `./TestResults/`.

## 🏗️ Project Structure

```
├── src/                          # Main web application
│   ├── Pages/                    # Razor Pages
│   ├── Models/                   # Data models (Thing entity)
│   ├── Data/                     # Entity Framework DbContext
│   └── wwwroot/                  # Static files
├── myWebApp.Tests/               # Test project
│   ├── UnitTest1.cs             # Thing model unit tests
│   ├── ApplicationDbContextTests.cs # Database tests
│   └── ThingsIntegrationTests.cs    # Web integration tests
├── deployments/compose/          # Docker Compose configurations
├── bin/                          # Setup and utility scripts
├── .devcontainer/               # VS Code devcontainer configuration
├── docs/
│   ├── GETTING_STARTED.md       # Detailed setup guide
│   ├── SECURITY.md              # Security documentation
│   ├── SECURITY_SCANNING.md     # Security scanning tools guide
│   ├── CHANGELOG.md             # Version history and updates
│   ├── PURPOSE.md               # Project purpose and goals
│   ├── TEST_COVERAGE_REPORT.md  # Comprehensive test analysis
│   └── SECURITY_SCANNING_REPORT.md  # Multi-tool security assessment
└── Makefile                     # Build and development automation
```

## 🗄️ Database Schema

The application manages a "Things" entity with the following schema:

```sql
CREATE TABLE Things (
    Id int IDENTITY(1,1) PRIMARY KEY,
    Name nvarchar(50) NOT NULL,
    Purpose nvarchar(255) NOT NULL,
    CreatedOn datetime2 NOT NULL DEFAULT GETDATE(),
    LastModified datetime2 NOT NULL DEFAULT GETDATE()
);
```

### CRUD Operations
- **Create**: Add new things via `/Things/Create`
- **Read**: List all things at `/Things` or view details at `/Things/Details/{id}`
- **Update**: Edit things at `/Things/Edit/{id}`
- **Delete**: Remove things at `/Things/Delete/{id}`

## � Security Features

### Network Security
- **IPv6 Completely Disabled**: At kernel, Docker daemon, and application levels
- **IPv4-Only Binding**: All services bound to 127.0.0.1 for localhost access
- **Minimal Port Exposure**: Only necessary ports exposed (8080 for web, 1433 for database)

### Application Security
- **Environment-Based Secrets**: No passwords in code or version control
- **SQL Server Authentication**: Dedicated application user with minimal permissions
- **TLS/SSL Ready**: Certificate handling for production deployments

### Security Scanning
Integrated security scanning tools:
- **Trivy**: Vulnerability scanner for containers and dependencies
- **Grype**: Advanced vulnerability detection
- **Syft**: Software bill of materials (SBOM) generation

```bash
make security  # Run all security scans
```

## 🛠️ Technology Stack

- **Framework**: ASP.NET Core 8.0 with Razor Pages
- **Database**: SQL Server 2022 Express with Entity Framework Core
- **Testing**: xUnit with Microsoft.AspNetCore.Mvc.Testing
- **Containerization**: Docker and Docker Compose
- **Development**: VS Code devcontainers with C# extensions
- **Security**: Trivy, Grype, Syft vulnerability scanning

## 📚 Documentation

- 📖 **[Getting Started Guide](docs/GETTING_STARTED.md)** - Comprehensive setup instructions
- 🔒 **[Security Documentation](docs/SECURITY.md)** - Security implementation details  
- 🔍 **[Security Scanning Guide](docs/SECURITY_SCANNING.md)** - Vulnerability scanning tools
- �️ **[Security Scan Report](docs/SECURITY_SCANNING_REPORT.md)** - Current security analysis results
- 🧪 **[Test Coverage Report](docs/TEST_COVERAGE_REPORT.md)** - Test execution and coverage analysis
- �📝 **[Changelog](docs/CHANGELOG.md)** - Version history and updates
- 🎯 **[Project Purpose](docs/PURPOSE.md)** - Project goals and objectives

## 📊 Quality Assurance Reports

- 🧪 **[Test Coverage Report](docs/TEST_COVERAGE_REPORT.md)** - Comprehensive test analysis and coverage metrics
- 🛡️ **[Security Scanning Report](docs/SECURITY_SCANNING_REPORT.md)** - Multi-tool vulnerability assessment and remediation guidance

## 🚀 Production Deployment

The application is container-ready for production deployment:

### Container Images
All images are published to: `ghcr.io/timcrider/apps/`
- `ghcr.io/timcrider/apps/mywebapp:latest` - Main application
- `ghcr.io/timcrider/apps/mywebapp-db:latest` - Database with schema

### Environment Variables
Configure these for production:
- `CS_MSSQL_CONN` - Database connection string
- `SA_PASSWORD` - SQL Server admin password  
- `WEBAPP_USER_PASSWORD` - Application database user password

### Health Checks
Built-in health monitoring:
- Application health endpoint: `/health`
- Database connectivity validation
- Container health checks configured

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Run tests: `make test`
4. Run security scans: `make security`
5. Submit a pull request

All contributions must:
- ✅ Pass all existing tests
- ✅ Include tests for new functionality
- ✅ Pass security scans
- ✅ Follow coding standards

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**💡 Need help?** Check the [Getting Started Guide](docs/GETTING_STARTED.md) or [Troubleshooting Section](docs/GETTING_STARTED.md#-troubleshooting) for detailed setup instructions and common solutions.
