#!/bin/bash
set -e

echo "Starting robust SQL Server setup with special character handling..."

# Wait for SQL Server to be ready
echo "Waiting for SQL Server to be ready..."
sleep 10

# Function to test SQL Server connectivity
test_sql_connection() {
    /opt/mssql-tools18/bin/sqlcmd -S mssql -U sa -P "$SA_PASSWORD" -No -C -Q "SELECT 1" >/dev/null 2>&1
}

# Wait for SQL Server to be responsive
echo "Testing SQL Server connectivity..."
RETRY_COUNT=0
MAX_RETRIES=30
while ! test_sql_connection; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "ERROR: SQL Server did not become ready after $MAX_RETRIES attempts"
        exit 1
    fi
    echo "SQL Server not ready yet, waiting... (attempt $RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done

echo "SQL Server is ready! Proceeding with setup..."

# Create a temporary SQL script with proper escaping
cat > /tmp/setup_safe.sql << 'EOF'
-- Check if login already exists and drop it
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'WebAppUser')
BEGIN
    DROP LOGIN WebAppUser;
    PRINT 'Existing WebAppUser login dropped';
END

-- Create login with special character handling
DECLARE @sql NVARCHAR(MAX);
DECLARE @password NVARCHAR(128) = N'$(password)';
SET @sql = N'CREATE LOGIN WebAppUser WITH PASSWORD=''' + @password + N''', CHECK_POLICY=OFF, CHECK_EXPIRATION=OFF';
EXEC sp_executesql @sql;
PRINT 'WebAppUser login created successfully';
GO

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'WebAppDB')
BEGIN
    CREATE DATABASE WebAppDB;
    PRINT 'WebAppDB database created';
END
ELSE
BEGIN
    PRINT 'WebAppDB database already exists';
END
GO

USE WebAppDB;
GO

-- Create table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[things]') AND type in (N'U'))
BEGIN
    CREATE TABLE things (
        id INT PRIMARY KEY IDENTITY (1, 1),
        created_on DATETIME NOT NULL DEFAULT GETDATE(),
        name VARCHAR (50) NOT NULL,
        purpose VARCHAR(255) NOT NULL,
        last_modified DATETIME NOT NULL
    );
    PRINT 'things table created';
END
ELSE
BEGIN
    PRINT 'things table already exists';
END
GO

-- Check and create database user
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'WebAppUser')
BEGIN
    CREATE USER WebAppUser FOR LOGIN WebAppUser;
    PRINT 'WebAppUser database user created';
END
ELSE
BEGIN
    PRINT 'WebAppUser database user already exists';
END
GO

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.things TO WebAppUser;
GRANT CREATE TABLE TO WebAppUser;
ALTER ROLE db_datareader ADD MEMBER WebAppUser;
ALTER ROLE db_datawriter ADD MEMBER WebAppUser;
PRINT 'Permissions granted to WebAppUser';
GO

-- Verify setup
SELECT 'Login exists: ' + CAST(COUNT(*) AS VARCHAR) AS LoginCheck 
FROM sys.server_principals WHERE name = 'WebAppUser';

SELECT 'Database exists: ' + CAST(COUNT(*) AS VARCHAR) AS DatabaseCheck 
FROM sys.databases WHERE name = 'WebAppDB';

SELECT 'Table exists: ' + CAST(COUNT(*) AS VARCHAR) AS TableCheck 
FROM WebAppDB.sys.objects WHERE object_id = OBJECT_ID(N'WebAppDB.[dbo].[things]') AND type in (N'U');

SELECT 'User exists: ' + CAST(COUNT(*) AS VARCHAR) AS UserCheck 
FROM WebAppDB.sys.database_principals WHERE name = 'WebAppUser';
GO
EOF

# Replace the password placeholder with the actual password (properly escaped)
# This approach avoids issues with sqlcmd variable substitution
ESCAPED_PASSWORD=$(printf '%s\n' "$WEBAPP_USER_PASSWORD" | sed 's/[[\.*^$()+?{|]/\\&/g; s/]/\\&/g')
sed "s/\$(password)/$WEBAPP_USER_PASSWORD/g" /tmp/setup_safe.sql > /tmp/setup_final.sql

echo "Executing SQL setup script..."
echo "Password length: ${#WEBAPP_USER_PASSWORD}"

# Execute the SQL script
if /opt/mssql-tools18/bin/sqlcmd -S mssql -U sa -P "$SA_PASSWORD" -No -C -i /tmp/setup_final.sql; then
    echo "✅ Database setup completed successfully!"
else
    echo "❌ Database setup failed!"
    echo "Attempting to debug the issue..."
    
    # Try a simpler approach
    echo "Trying alternative approach..."
    /opt/mssql-tools18/bin/sqlcmd -S mssql -U sa -P "$SA_PASSWORD" -No -C -Q "
    IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'WebAppUser')
        DROP LOGIN WebAppUser;
    CREATE LOGIN WebAppUser WITH PASSWORD=N'$WEBAPP_USER_PASSWORD', CHECK_POLICY=OFF;
    PRINT 'Login created with alternative method';
    "
    
    # Continue with database setup
    /opt/mssql-tools18/bin/sqlcmd -S mssql -U sa -P "$SA_PASSWORD" -No -C -Q "
    IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'WebAppDB')
        CREATE DATABASE WebAppDB;
    USE WebAppDB;
    IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'WebAppUser')
        CREATE USER WebAppUser FOR LOGIN WebAppUser;
    GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.things TO WebAppUser;
    "
fi

# Clean up temporary files
rm -f /tmp/setup_safe.sql /tmp/setup_final.sql

echo "Database setup script completed!"
