# Secure Cross-Platform ASP.NET C8. [Troubleshooting](#-troubleshooting)
9. [Documentation](#-comprehensive-documentation)

## 🛡️ **IPv6 Elimination & Network Security**

This application implements **comprehensive IPv6 disabling** at all infrastructure levels for enhanced security and simplified network management.

### 🔒 **Security Benefits**
- **Reduced Attack Surface**: No IPv6 endpoints to secure or monitor
- **Simplified Firewall Rules**: IPv4-only rules eliminate dual-stack complexity
- **Consistent Network Behavior**: No IPv6/IPv4 fallback or resolution issues
- **Enhanced Security Compliance**: Meets strict IPv4-only infrastructure requirements
- **Faster Network Resolution**: Eliminates IPv6 DNS lookup attempts

### 🏗️ **Implementation Levels**

#### **1. System Level (Linux Kernel)**
```bash
# IPv6 disabled via sysctl parameters
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
```

#### **2. Docker Daemon Level**
```json
{
  "ipv6": false,
  "fixed-cidr-v6": "",
  "ip6tables": false,
  "default-address-pools": [
    {"base": "172.17.0.0/16", "size": 24}
  ]
}
```

#### **3. Docker Compose Network**
```yaml
networks:
  default:
    enable_ipv6: false
    driver: bridge
    driver_opts:
      com.docker.network.enable_ipv6: "false"
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16
```

#### **4. Port Binding Level**
```yaml
ports:
  - "127.0.0.1:8080:8080"  # IPv4 localhost only
  - "127.0.0.1:1433:1433"  # IPv4 localhost only
```

#### **5. Application Level**
```bash
# ASP.NET Core IPv6 disabling
ASPNETCORE_URLS=http://0.0.0.0:8080
DOTNET_SYSTEM_NET_DISABLEIPV6=true

# SQL Server IPv4-only binding
MSSQL_IP_ADDRESS=0.0.0.0
MSSQL_TCP_PORT=1433
```

### ✅ **Verification Commands**

```bash
# Check IPv6 kernel status (should return: 1)
cat /proc/sys/net/ipv6/conf/all/disable_ipv6

# Verify no IPv6 interfaces (should return: 0)
ip addr show | grep inet6 | wc -l

# Check Docker network IPv6 status (should return: false)
docker network inspect compose_default | grep "EnableIPv6"

# Verify IPv4-only port bindings
netstat -tlnp | grep -E ':8080|:1433'
# Should show: tcp 0 0 127.0.0.1:8080 0.0.0.0:* LISTEN

# Test application connectivity (IPv4 only)
curl -s http://127.0.0.1:8080 | head -1
```

### 🔧 **Automatic Setup**

IPv6 disabling is automatically configured through:
- `.devcontainer/setup-docker.sh` - OS-aware Docker setup with IPv6 disabling
- `.devcontainer/disable-ipv6.sh` - Comprehensive IPv6 elimination script
- `compose-localdb.yaml` - IPv4-only network configuration
- Container environment variables for .NET and SQL Server

**Result**: Complete IPv4-only infrastructure with zero IPv6 exposure or dependencies.

## � **Quick Start**Application

A **production-ready ASP.NET Core 8.0** application with comprehensive security features, cross-platform Docker support, and universal password handling capabilities.

## 🎯 **Key Features & Security**

### 🔐 **Security-First Design**
- ✅ **Universal Password Support**: Handles any password complexity with special characters
- ✅ **Complete IPv6 Elimination**: Disabled at all infrastructure levels
- ✅ **Environment Variable Security**: No passwords in code or version control
- ✅ **IPv4-Only Networking**: Reduced attack surface and simplified firewall rules

### 🏗️ **Cross-Platform Excellence**
- ✅ **Automatic OS Detection**: Optimized Docker setup for Apple Silicon and Intel
- ✅ **Docker Outside of Docker (DooD)**: For Apple Silicon/ARM64 compatibility
- ✅ **Docker in Docker (DinD)**: For x86_64/Intel performance
- ✅ **Universal Compatibility**: Works seamlessly across all development platforms

### 🚀 **Production-Ready Features**
- ✅ **Complete CRUD Operations**: Full Things management interface
- ✅ **Robust Database Setup**: Handles complex passwords and special characters
- ✅ **Health Monitoring**: Comprehensive container health checks
- ✅ **Scalable Architecture**: Container-based deployment ready

## 📋 Table of Contents

1. [Quick Start](#-quick-start)
2. [Security Features](#-security-implementation)
3. [Cross-Platform Setup](#-cross-platform-docker-setup)
4. [Technology Stack](#-technology-stack)
5. [Configuration Management](#-configuration-management)
6. [Database Schema](#-database-schema)
7. [Development Environment](#-development-setup)
8. [Troubleshooting](#-troubleshooting)
9. [Documentation](#-comprehensive-documentation)

## � **Quick Start**

### **Option 1: Automatic Setup (Recommended)**
```bash
# Clone the repository
git clone <repository-url>
cd <project-directory>

# Open in VS Code devcontainer (auto-detects your platform)
code .
# Select "Reopen in Container" when prompted

# Start the application
cd deployments/compose
docker compose -f compose-localdb.yaml up
```

### **Option 2: Manual Setup**
```bash
# For Apple Silicon/ARM64
cp .devcontainer/devcontainer-arm64.json .devcontainer/devcontainer.json

# For Intel/x86_64  
cp .devcontainer/devcontainer-x86_64.json .devcontainer/devcontainer.json

# Configure your environment
cp .local.example .local
# Edit .local with your database passwords

# Start services
docker compose -f compose-localdb.yaml up
```

**Application URL**: http://127.0.0.1:8080

## � **Security Implementation**
   ```

2. **Configure Database Connection** (choose one):
   
   **Option A: User Secrets (Recommended for Development)**
   ```bash
   dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Server=your-server;Database=your-db;User Id=your-user;Password=your-password;TrustServerCertificate=true"
   ```

   **Option B: Environment Variable**
   ```bash
   export CS_MSSQL_CONN="Server=your-server;Database=your-db;User Id=your-user;Password=your-password;TrustServerCertificate=true"
   ```

3. **Run Application**:
   ```bash
   dotnet run
   ```

### Docker Deployment

1. **Set Environment Variable**:
   ```bash
   export CS_MSSQL_CONN="Server=your-server;Database=your-db;User Id=your-user;Password=your-password;TrustServerCertificate=true"
   ```

2. **Build and Run**:
   ```bash
   cd deployments/compose
   docker compose up --build
   ```

3. **Access Application**: http://localhost:8080

## 🔄 Configuration Management

The application uses a **cascading configuration system** with the following priority order:

### 1. Environment Variable `CS_MSSQL_CONN` (Highest Priority)
- **Use Case**: Production deployments, Docker containers, CI/CD pipelines
- **Setting**: `export CS_MSSQL_CONN="connection-string"`
- **Benefits**: Overrides all other settings, perfect for containers

### 2. User Secrets / Configuration Files (Medium Priority)
- **Development**: User Secrets (encrypted, local)
- **Production**: `appsettings.Production.json`
- **Setting**: `dotnet user-secrets set "ConnectionStrings:DefaultConnection" "connection-string"`
- **Benefits**: Secure for development, environment-specific

### 3. Default Fallback (Lowest Priority)
- **Connection**: `Server=localhost;Database=LocalTestDB;Integrated Security=true`
- **Use Case**: Local development without any configuration
- **Benefits**: Always works for basic local development

## 🐳 Docker Setup

### Issues Fixed in Docker Configuration

- **✅ ICU Globalization**: Added `icu-libs` package for Alpine Linux
- **✅ Connection String**: Proper environment variable handling
- **✅ Multi-stage Build**: Optimized build process
- **✅ Alpine Compatibility**: Full .NET globalization support

### Docker Files Structure

**Dockerfile**:
```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
RUN apk add --no-cache icu-libs
COPY . /source
WORKDIR /source/src
RUN dotnet publish -c Release -o /app

# Final stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS final
RUN apk add --no-cache icu-libs
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "myWebApp.dll"]
```

**compose.yaml** (located in `deployments/compose/`):
```yaml
services:
  server:
    build:
      context: ../../
      target: final
    env_file:
      - ../../.secret
    environment:
      - DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
    ports:
      - 8080:8080
```

## 🗄️ Database Schema

The application works with the following SQL Server table:

```sql
CREATE TABLE things (
  id INT PRIMARY KEY IDENTITY (1, 1),
  created_on DATETIME NOT NULL DEFAULT GETDATE(),
  name VARCHAR (50) NOT NULL,
  purpose VARCHAR(255) NOT NULL,
  last_modified DATETIME NOT NULL
);
```

### Database Setup Instructions

To set up the database and create a restricted user for the web application, follow these steps:

#### 1. Connect as Administrator

```bash
# Connect to SQL Server as SA (System Administrator)
sqlcmd -S your-server-name -U SA -p
```

#### 2. Create Database and User

```sql
-- Create a login for the web application
CREATE LOGIN WebAppUser WITH PASSWORD='YourSecurePassword!123';
GO

-- Create the database
CREATE DATABASE WebAppDB;
GO

-- Switch to the new database
USE WebAppDB;
GO

-- Create the things table
CREATE TABLE things (
  id INT PRIMARY KEY IDENTITY (1, 1),
  created_on DATETIME NOT NULL DEFAULT GETDATE(),
  name VARCHAR (50) NOT NULL,
  purpose VARCHAR(255) NOT NULL,
  last_modified DATETIME NOT NULL
);
GO

-- Verify table creation
SELECT sobjects.name FROM sysobjects sobjects WHERE sobjects.xtype = 'U';
GO

-- Create a database user for the login
CREATE USER WebAppUser FOR LOGIN WebAppUser;
GO

-- Grant only necessary permissions (principle of least privilege)
GRANT SELECT, INSERT, UPDATE, DELETE ON things TO WebAppUser;
GO
```

#### 3. Test the User Connection

```bash
# Connect as the web application user
sqlcmd -S your-server-name -U WebAppUser -d WebAppDB -p
```

```sql
-- Test inserting data
INSERT INTO things (name, purpose, last_modified)
VALUES ('Test Item', 'Application Testing', GETDATE());
GO

-- Verify the data
SELECT * FROM things;
GO

-- Exit
quit
```

#### 4. Security Best Practices

- **🔐 Strong Password**: Use a complex password with special characters
- **🛡️ Restricted Permissions**: The user only has CRUD permissions on the `things` table
- **🚫 No Admin Rights**: WebAppUser cannot create/drop databases or modify server settings
- **📊 Limited Scope**: User only has access to the `WebAppDB` database

#### 5. Connection String Format

After creating the user, use this connection string format:

```
Server=your-server-name;Database=WebAppDB;User Id=WebAppUser;Password=YourSecurePassword!123;TrustServerCertificate=true
```

### Entity Framework Model

```csharp
[Table("things")]
public class Thing
{
    [Column("id")]
    public int Id { get; set; }
    
    [Required]
    [StringLength(50)]
    [Column("name")]
    public string Name { get; set; } = string.Empty;
    
    [Required]
    [StringLength(255)]
    [Column("purpose")]
    public string Purpose { get; set; } = string.Empty;
    
    [Column("created_on")]
    public DateTime CreatedOn { get; set; } = DateTime.Now;
    
    [Column("last_modified")]
    public DateTime LastModified { get; set; } = DateTime.Now;
}
```

## 🔐 Security Implementation

### Development Security
- **User Secrets**: Encrypted local storage for sensitive data
- **No Hardcoded Passwords**: All sensitive data externalized
- **Safe Fallback**: Local database with integrated security

### Production Security
- **Environment Variables**: Secure configuration injection
- **TrustServerCertificate**: For self-signed certificates
- **Connection String Validation**: Automatic detection and logging

### Setting Up User Secrets

```bash
# Initialize user secrets (already done)
dotnet user-secrets init

# Set connection string (use single quotes for special characters)
dotnet user-secrets set "ConnectionStrings:DefaultConnection" 'Server=server;Database=db;User Id=user;Password=complex!password;TrustServerCertificate=true'

# Verify secrets
dotnet user-secrets list

# Remove secret (if needed)
dotnet user-secrets remove "ConnectionStrings:DefaultConnection"
```

## 💻 Development Setup

### Prerequisites
- .NET 8.0 SDK
- Docker Desktop (for containerization)
- SQL Server (local or remote)

### Required NuGet Packages
```xml
<PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="8.0.0" />
<PackageReference Include="Microsoft.EntityFrameworkCore.Tools" Version="8.0.0" />
<PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="8.0.0" />
<PackageReference Include="Microsoft.VisualStudio.Web.CodeGeneration.Design" Version="8.0.0" />
```

### Installation Commands
```bash
cd src
dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 8.0.0
dotnet add package Microsoft.EntityFrameworkCore.Tools --version 8.0.0
dotnet add package Microsoft.EntityFrameworkCore.Design --version 8.0.0
dotnet add package Microsoft.VisualStudio.Web.CodeGeneration.Design --version 8.0.0
dotnet restore
```

### Entity Framework Migrations

The application includes clean migrations that match the current model:

```bash
# Create new migration (if needed)
dotnet ef migrations add MigrationName

# Update database
dotnet ef database update

# Remove last migration (if needed)
dotnet ef migrations remove
```

## 🚀 Production Deployment

### Environment Variables for Production

```bash
# Linux/macOS
export CS_MSSQL_CONN="Server=prod-server;Database=ProdDB;User Id=ProdUser;Password=SecurePassword;TrustServerCertificate=true"

# Windows Command Prompt
set CS_MSSQL_CONN=Server=prod-server;Database=ProdDB;User Id=ProdUser;Password=SecurePassword;TrustServerCertificate=true

# Windows PowerShell
$env:CS_MSSQL_CONN="Server=prod-server;Database=ProdDB;User Id=ProdUser;Password=SecurePassword;TrustServerCertificate=true"
```

### Docker Production Deployment

1. **Build for Production**:
   ```bash
   docker build -t myapp .
   ```

2. **Multi-platform Build**:
   ```bash
   docker build --platform=linux/amd64 -t myapp .
   ```

3. **Push to Registry**:
   ```bash
   docker push myregistry.com/myapp
   ```

### Azure App Service Configuration
- Navigate to Azure Portal → App Service → Configuration
- Add application setting:
  - **Name**: `CS_MSSQL_CONN`
  - **Value**: Your connection string

## � Deployment Structure

The project has been organized with a dedicated deployment folder structure:

### File Organization
- **`deployments/compose/`**: Docker Compose configurations
- **`deployments/k8s/`**: Future Kubernetes manifests
- **`.secret`**: Database connection configuration (moved to workspace root)

### Running from Deployment Directory
All Docker operations should now be run from the deployment directory:

```bash
# Navigate to the compose deployment directory
cd deployments/compose

# Build and run
docker compose up --build

# Stop services
docker compose down

# View logs
docker compose logs -f
```

### Migration from Root Directory
If upgrading from a previous version:
1. The `compose.yaml` file has moved from `/workspaces/compose.yaml` to `/workspaces/deployments/compose/compose.yaml`
2. The `.secret` file has moved from `/workspaces/src/.secret` to `/workspaces/.secret`
3. All relative paths in `compose.yaml` have been updated to work from the new location

## �🔍 Troubleshooting

### Common Issues

#### 1. **Docker Build Errors**
```bash
# Check Docker daemon
docker --version

# Clean build cache
docker system prune

# Rebuild from scratch
docker compose build --no-cache
```

#### 2. **Database Connection Issues**
```bash
# Test connection string format
# Ensure TrustServerCertificate=true for self-signed certificates
# Verify server accessibility from container network
```

#### 3. **ICU Globalization Errors**
```bash
# Solution: Install icu-libs in Dockerfile (already implemented)
RUN apk add --no-cache icu-libs
```

#### 4. **Migration Issues**
```bash
# Reset migrations (if corrupted)
rm -rf Migrations/
dotnet ef migrations add InitialCreate
dotnet ef database update
```

#### 5. **Deployment Directory Issues**
```bash
# If Docker Compose fails to find files:
# 1. Ensure you're in the correct directory
cd deployments/compose

# 2. Verify file structure
ls -la ../../.secret        # Should exist
ls -la ../../Dockerfile     # Should exist

# 3. Check compose.yaml paths are correct
cat compose.yaml | grep context  # Should show: context: ../../
```

### Debug Connection Configuration

The application logs which connection source is being used:
- "Using connection string from environment variable CS_MSSQL_CONN"
- "Using connection string from User Secrets"
- "Using connection string from configuration files"
- "Using default fallback connection string"

### Testing Different Configuration Sources

```bash
# Test 1: Environment Variable (highest priority)
export CS_MSSQL_CONN="test-connection-string"
dotnet run

# Test 2: User Secrets (medium priority)
unset CS_MSSQL_CONN
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "test-connection-string"
dotnet run

# Test 3: Configuration Files (lowest priority)
unset CS_MSSQL_CONN
dotnet user-secrets remove "ConnectionStrings:DefaultConnection"
dotnet run
```

## 📚 References

### Documentation
- [Docker's .NET Guide](https://docs.docker.com/language/dotnet/)
- [ASP.NET Core Configuration](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/)
- [Entity Framework Core](https://docs.microsoft.com/en-us/ef/core/)
- [User Secrets](https://docs.microsoft.com/en-us/aspnet/core/security/app-secrets)

### Related Repositories
- [dotnet-docker samples](https://github.com/dotnet/dotnet-docker/tree/main/samples)
- [Remote Try DotNet](https://github.com/microsoft/vscode-remote-try-dotnet)

### Database Resources
- [MS SQL Server Docker](https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker)
- [Docker Getting Started](https://docs.docker.com/go/get-started-sharing/)

---

## 📄 File Structure

```
/workspaces/
├── .secret                        # Database connection configuration
├── deployments/
│   ├── compose/
│   │   └── compose.yaml           # Docker Compose configuration
│   └── k8s/                       # Kubernetes manifests (future)
├── Dockerfile                     # Multi-stage Docker build
├── README.md                      # This consolidated documentation
└── src/
    ├── myWebApp.csproj            # Project file with dependencies
    ├── Program.cs                 # Application startup with cascading config
    ├── appsettings.json           # Base configuration
    ├── appsettings.Production.json # Production configuration
    ├── Data/
    │   └── ApplicationDbContext.cs # EF Core DbContext
    ├── Models/
    │   └── Thing.cs               # Entity model
    ├── Migrations/                # EF Core migrations
    ├── Pages/
    │   ├── Things/                # CRUD pages for Things
    │   └── Shared/
    │       └── _Layout.cshtml     # Main layout with navigation
    └── wwwroot/                   # Static web assets
```

This application demonstrates modern ASP.NET Core development practices with secure configuration management, Docker containerization, and production-ready deployment patterns.