# ASP.NET Core Things CRUD Application

A complete ASP.NET Core 8.0 web application with Docker support, demonstrating CRUD operations with Entity Framework Core and SQL Server integration.

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [Quick Start](#quick-start)
4. [Configuration Management](#configuration-management)
5. [Docker Setup](#docker-setup)
6. [Database Schema](#database-schema)
7. [Security Implementation](#security-implementation)
8. [Development Setup](#development-setup)
9. [Production Deployment](#production-deployment)
10. [Deployment Structure](#deployment-structure)
11. [Troubleshooting](#troubleshooting)
12. [References](#references)

## 📝 Project Overview

This project implements a complete CRUD interface for managing "Things" in an ASP.NET Core Razor Pages application. It features a cascading configuration system for secure database connection management and full Docker containerization support.

### Key Features

- **Complete CRUD Operations**: Create, Read, Update, Delete functionality
- **Sortable Table Headers**: Click-to-sort functionality with visual indicators
- **Secure Configuration**: Multi-tier configuration with User Secrets and Environment Variables
- **Local Development Environment**: Complete SQL Server setup with Docker Compose (for developers without SQL Server access)
- **Remote Database Support**: Connect to existing SQL Server instances
- **Docker Support**: Full containerization with Alpine Linux
- **Responsive UI**: Bootstrap 5 with Font Awesome icons
- **Database Integration**: Entity Framework Core with SQL Server
- **Production Ready**: Environment-specific configurations
- **Password Security**: Environment variable-based password management

## 🛠️ Technology Stack

- **Framework**: ASP.NET Core 8.0
- **UI**: Razor Pages with Bootstrap 5
- **ORM**: Entity Framework Core 8.0
- **Database**: SQL Server (Docker or Remote)
- **Containerization**: Docker with Alpine Linux
- **Icons**: Font Awesome 6.0
- **Language**: C# with .NET 8.0

## 🚀 Quick Start

> **⚠️ Security Note**: All password examples below use placeholder values (`YourSecurePassword123!`). **Replace these with your own secure passwords** before use. Never commit actual passwords to version control.

### Local Development with Docker SQL Server (Recommended)

**Complete self-contained development environment with SQL Server in Docker:**

1. **Setup Local Environment Files**:
   ```bash
   # Create environment files (if they don't exist)
   touch /workspaces/.local
   touch /workspaces/.local.sh
   
   # Add to .local (for Docker Compose):
   echo "CS_MSSQL_CONN=Server=mssql;Database=WebAppDB;User Id=WebAppUser;Password=\${WEBAPP_USER_PASSWORD};TrustServerCertificate=true" >> /workspaces/.local
   echo "LOCAL_SA_PASSWORD=YourSecurePassword123!" >> /workspaces/.local
   echo "SA_PASSWORD=YourSecurePassword123!" >> /workspaces/.local
   echo "WEBAPP_USER_PASSWORD=YourSecurePassword123!" >> /workspaces/.local
   
   # Add to .local.sh (for shell export):
   echo "export CS_MSSQL_CONN='Server=mssql;Database=WebAppDB;User Id=WebAppUser;Password=YourSecurePassword123!;TrustServerCertificate=true'" >> /workspaces/.local.sh
   echo "export LOCAL_SA_PASSWORD='YourSecurePassword123!'" >> /workspaces/.local.sh
   echo "export SA_PASSWORD='YourSecurePassword123!'" >> /workspaces/.local.sh
   echo "export WEBAPP_USER_PASSWORD='YourSecurePassword123!'" >> /workspaces/.local.sh
   ```

2. **Start Local Development Environment**:
   ```bash
   cd deployments/compose
   docker compose -f compose-localdb.yaml up --build
   ```

3. **Access Application**: http://localhost:8080/Things

### Remote Database Development

**For development with an existing remote SQL Server (if you have access to one):**

1. **Configure Database Connection** (choose one):
   
   **Option A: User Secrets (Recommended for Development)**
   ```bash
   cd src
   dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Server=your-server;Database=your-db;User Id=your-user;Password=your-password;TrustServerCertificate=true"
   ```

   **Option B: Environment Variable**
   ```bash
   export CS_MSSQL_CONN="Server=your-server;Database=your-db;User Id=your-user;Password=your-password;TrustServerCertificate=true"
   ```

2. **Run Application**:
   ```bash
   cd src
   dotnet restore
   dotnet run
   ```

### Remote Database with Docker (Alternative)

**If you have a remote SQL Server but want to run the app in Docker:**

1. **Configure Database Connection**:
   ```bash
   # Create .secret file with your remote database connection
   echo "CS_MSSQL_CONN=Server=your-server;Database=your-db;User Id=your-user;Password=YourPassword;TrustServerCertificate=true" > .secret
   ```

2. **Run with Docker Compose**:
   ```bash
   cd deployments/compose
   docker compose up --build
   ```

3. **Access Application**: http://localhost:8080

### Production Deployment

**For actual production environments, use your organization's deployment practices:**

1. **Environment Variables**: Configure `CS_MSSQL_CONN` through your deployment system
2. **Container Registry**: Push to your organization's container registry
3. **Orchestration**: Deploy using Kubernetes, Docker Swarm, or cloud services
4. **Security**: Use proper secrets management (Azure Key Vault, AWS Secrets Manager, etc.)

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

### Local Development with Docker SQL Server

**For developers who cannot stand up their own SQL Server or want a complete self-contained environment:**

The project includes a complete local development environment with SQL Server:

**compose-localdb.yaml** (located in `deployments/compose/`):
```yaml
services:
  frontend:
    build:
      context: ../../
      target: final
    depends_on:
      mssql-setup:
        condition: service_completed_successfully
    env_file:
      - ../../.local
    environment:
      - DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
    ports:
      - 8080:8080

  mssql:
    image: mcr.microsoft.com/mssql/server:2022-latest
    ports:
      - 1433:1433
    env_file:
      - ../../.local
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=${LOCAL_SA_PASSWORD}
      - MSSQL_PID=Express
    healthcheck:
      test: ["CMD-SHELL", "/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $${SA_PASSWORD} -No -C -Q 'SELECT 1' || exit 1"]
      interval: 15s
      timeout: 10s
      retries: 10
      start_period: 30s
    volumes:
      - mssql_data:/var/opt/mssql

  mssql-setup:
    image: mcr.microsoft.com/mssql/server:2022-latest
    depends_on:
      mssql:
        condition: service_healthy
    env_file:
      - ../../.local
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=${LOCAL_SA_PASSWORD}
    volumes:
      - ./mssql/setup_mssql_things.sql:/setup_mssql_things.sql:ro
    command: >
      bash -c "
        echo 'Waiting for SQL Server to be ready...'
        sleep 5
        echo 'Running database setup script...'
        /opt/mssql-tools18/bin/sqlcmd -S mssql -U sa -P ${LOCAL_SA_PASSWORD} -No -C -v WEBAPP_USER_PASSWORD='${WEBAPP_USER_PASSWORD}' -i /setup_mssql_things.sql
        echo 'Database setup complete!'
      "
    restart: "no"

volumes:
  mssql_data:
```

### Remote Database with Docker

**For connecting to an existing remote SQL Server while running the app in Docker:**

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

> **Note**: This setup requires a `.secret` file with your remote database connection string. It's designed for developers who have access to a remote SQL Server but want to run the application in Docker.

### Issues Fixed in Docker Configuration

- **✅ ICU Globalization**: Added `icu-libs` package for Alpine Linux
- **✅ Connection String**: Proper environment variable handling
- **✅ Multi-stage Build**: Optimized build process
- **✅ Alpine Compatibility**: Full .NET globalization support
- **✅ Local Database**: Complete SQL Server setup with automated initialization
- **✅ Password Security**: Environment variable-based password management
- **✅ Health Checks**: Proper service orchestration and dependency management

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

### Automated Local Database Setup

The local development environment includes automated database initialization:

**setup_mssql_things.sql** (located in `deployments/compose/mssql/`):
```sql
CREATE LOGIN WebAppUser WITH PASSWORD='$(WEBAPP_USER_PASSWORD)';
GO

CREATE DATABASE WebAppDB;
GO

USE WebAppDB;
GO

CREATE TABLE things (
  id INT PRIMARY KEY IDENTITY (1, 1),
  created_on DATETIME NOT NULL DEFAULT GETDATE(),
  name VARCHAR (50) NOT NULL,
  purpose VARCHAR(255) NOT NULL,
  last_modified DATETIME NOT NULL
);
GO

SELECT sobjects.name FROM sysobjects sobjects WHERE sobjects.xtype = 'U'
GO

CREATE USER WebAppUser FOR LOGIN WebAppUser;
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON things TO WebAppUser;
GO

INSERT INTO things (name, purpose, last_modified) VALUES ('WebAppUser', 'Web Application User', GETDATE());
GO
```

**Security Features:**
- **🔐 Password Abstraction**: Uses `$(WEBAPP_USER_PASSWORD)` variable substitution
- **🛡️ Least Privilege**: WebAppUser only has CRUD permissions on the `things` table
- **🚫 No Admin Rights**: Restricted user cannot modify server settings
- **📊 Database Scoped**: User only has access to the `WebAppDB` database

### Manual Database Setup Instructions

To set up the database manually on a remote server, follow these steps:

#### 1. Connect as Administrator

```bash
# Connect to SQL Server as SA (System Administrator)
sqlcmd -S your-server-name -U SA -p
```

#### 2. Create Database and User

```sql
-- Create a login for the web application
CREATE LOGIN WebAppUser WITH PASSWORD='YourSecurePassword123!';
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
Server=your-server-name;Database=WebAppDB;User Id=WebAppUser;Password=YourSecurePassword123!;TrustServerCertificate=true
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
export CS_MSSQL_CONN="Server=prod-server;Database=ProdDB;User Id=ProdUser;Password=YourProductionPassword;TrustServerCertificate=true"

# Windows Command Prompt
set CS_MSSQL_CONN=Server=prod-server;Database=ProdDB;User Id=ProdUser;Password=YourProductionPassword;TrustServerCertificate=true

# Windows PowerShell
$env:CS_MSSQL_CONN="Server=prod-server;Database=ProdDB;User Id=ProdUser;Password=YourProductionPassword;TrustServerCertificate=true"
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

The project has been organized with a comprehensive deployment folder structure:

### File Organization
- **`deployments/compose/`**: Docker Compose configurations
  - **`compose-localdb.yaml`**: Self-contained development environment with Docker SQL Server
  - **`compose.yaml`**: Remote database development (for those with existing SQL Server access)
  - **`mssql/setup_mssql_things.sql`**: Automated database initialization script
- **`deployments/k8s/`**: Future Kubernetes manifests
- **`.local`**: Environment variables for local development with Docker SQL Server
- **`.local.sh`**: Environment variables for local development (shell export format)
- **`.secret`**: Remote database connection configuration

### Environment Files

**Docker SQL Server Development (.local)**:
```bash
CS_MSSQL_CONN=Server=mssql;Database=WebAppDB;User Id=WebAppUser;Password=${WEBAPP_USER_PASSWORD};TrustServerCertificate=true
LOCAL_SA_PASSWORD=YourSecurePassword123!
SA_PASSWORD=YourSecurePassword123!
WEBAPP_USER_PASSWORD=YourSecurePassword123!
```

**Remote Database Development (.secret)**:
```bash
CS_MSSQL_CONN=Server=your-remote-server;Database=your-db;User Id=your-user;Password=your-password;TrustServerCertificate=true
```

### Running from Deployment Directory

**Docker SQL Server Development:**
```bash
# Navigate to the compose deployment directory
cd deployments/compose

# Start self-contained environment with Docker SQL Server
docker compose -f compose-localdb.yaml up --build

# View logs
docker compose -f compose-localdb.yaml logs -f

# Stop services
docker compose -f compose-localdb.yaml down
```

**Remote Database Development:**
```bash
# Navigate to the compose deployment directory
cd deployments/compose

# Run app in Docker connected to remote database
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
├── .local                         # Local development environment variables (Docker Compose)
├── .local.sh                      # Local development environment variables (shell export)
├── .secret                        # Production database connection configuration
├── .gitignore                     # Git ignore rules (excludes .local* and .secret*)
├── deployments/
│   ├── compose/
│   │   ├── compose.yaml           # Production Docker Compose configuration
│   │   ├── compose-localdb.yaml   # Local development with SQL Server
│   │   └── mssql/
│   │       ├── Dockerfile         # SQL Server container setup
│   │       └── setup_mssql_things.sql # Database initialization script
│   └── k8s/                       # Kubernetes manifests (future)
├── Dockerfile                     # Multi-stage Docker build
├── README.md                      # This comprehensive documentation
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
    │   ├── Things/
    │   │   ├── Index.cshtml       # Sortable table with Things list
    │   │   ├── Index.cshtml.cs    # Server-side sorting logic
    │   │   ├── Create.cshtml      # Create new Thing
    │   │   ├── Edit.cshtml        # Edit existing Thing
    │   │   ├── Delete.cshtml      # Delete Thing
    │   │   └── Details.cshtml     # View Thing details
    │   └── Shared/
    │       └── _Layout.cshtml     # Main layout with navigation
    └── wwwroot/
        ├── css/
        │   └── site.css           # Custom styles including sortable headers
        ├── js/
        │   └── site.js            # Custom JavaScript
        └── lib/                   # External libraries (Bootstrap, jQuery, FontAwesome)
```

This application demonstrates modern ASP.NET Core development practices with:
- **Secure configuration management** with environment variables and user secrets
- **Local development environment** with automated SQL Server setup
- **Sortable table interface** with server-side processing
- **Docker containerization** for both development and production
- **Production-ready deployment patterns** with proper security practices