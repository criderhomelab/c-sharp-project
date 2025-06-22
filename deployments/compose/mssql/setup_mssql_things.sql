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
