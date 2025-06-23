-- Database initialization script for WebAppDB
-- This script will be run when the SQL Server container starts

PRINT 'Starting database initialization...';

USE master;
GO

-- Create the database if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'WebAppDB')
BEGIN
    PRINT 'Creating database WebAppDB...';
    CREATE DATABASE WebAppDB;
    PRINT 'Database WebAppDB created successfully.';
END
ELSE
BEGIN
    PRINT 'Database WebAppDB already exists.';
END
GO

USE WebAppDB;
GO

-- Create the things table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='things' AND xtype='U')
BEGIN
    PRINT 'Creating things table...';
    CREATE TABLE things (
        id INT PRIMARY KEY IDENTITY(1, 1),
        created_on DATETIME NOT NULL DEFAULT GETDATE(),
        name VARCHAR(50) NOT NULL,
        purpose VARCHAR(255) NOT NULL,
        last_modified DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Table things created successfully.';
END
ELSE
BEGIN
    PRINT 'Table things already exists.';
END
GO

-- Create a login for the web application if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'WebAppUser')
BEGIN
    PRINT 'Creating login WebAppUser...';
    CREATE LOGIN WebAppUser WITH PASSWORD = 'WebApp_Password_123!';
    PRINT 'Login WebAppUser created successfully.';
END
ELSE
BEGIN
    PRINT 'Login WebAppUser already exists.';
END
GO

-- Create a user in the database if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'WebAppUser')
BEGIN
    PRINT 'Creating database user WebAppUser...';
    CREATE USER WebAppUser FOR LOGIN WebAppUser;
    PRINT 'Database user WebAppUser created successfully.';
END
ELSE
BEGIN
    PRINT 'Database user WebAppUser already exists.';
END
GO

-- Grant permissions to the user
PRINT 'Granting permissions to WebAppUser...';
GRANT SELECT, INSERT, UPDATE, DELETE ON things TO WebAppUser;
PRINT 'Permissions granted successfully.';
GO

-- Insert some sample data if the table is empty
IF NOT EXISTS (SELECT 1 FROM things)
BEGIN
    PRINT 'Inserting sample data...';
    INSERT INTO things (name, purpose, last_modified) VALUES 
        ('Sample Item 1', 'Demonstration purpose', GETDATE()),
        ('Sample Item 2', 'Testing database connectivity', GETDATE()),
        ('Docker Container', 'Containerized database example', GETDATE());
    PRINT 'Sample data inserted successfully.';
END
ELSE
BEGIN
    PRINT 'Sample data already exists.';
END
GO

PRINT 'Database WebAppDB initialization completed successfully!';
