#!/usr/bin/env bash

# From https://www.howtoforge.com/how-to-install-microsoft-sql-server-on-debian-12/

# 1
sudo apt update && sudo apt upgrade

# 2
sudo apt install gnupg2 apt-transport-https wget curl

# 3
wget -q -O- https://packages.microsoft.com/keys/microsoft.asc | \
gpg --dearmor | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null 2>&1

# 4
echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg arch=amd64,armhf,arm64] https://packages.microsoft.com/ubuntu/22.04/mssql-server-2022 jammy main" | \
sudo tee /etc/apt/sources.list.d/mssql-server-2022.list

# 5
sudo apt update

# 6
sudo apt install mssql-server

# 7
sudo /opt/mssql/bin/mssql-conf setup

# sudo systemctl is-enabled mssql-server
#sudo systemctl status mssql-server

# sudo apt install ufw

#sudo ufw allow OpenSSH
#sudo ufw allow 1433/tcp
# or
#sudo ufw allow from 192.168.1.0/24 to any port 1433
# sudo ufw enable
# sudo ufw status

# TOOLS
echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg arch=amd64,armhf,arm64] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" | \
sudo tee /etc/apt/sources.list.d/prod.list

sudo apt update
sudo apt install mssql-tools unixodbc-dev

ls -ah /opt/mssql-tools/bin

echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /etc/environment
source /etc/environment
echo $PATH

which sqlcmd
which bcp

sqlcmd -?
bcp -?

exit

# Confirm Working
$ sqlcmd -S localhost -U SA -p

select @@version
go

select name from sys.databases;
go

# Create a Database and User
CREATE LOGIN WebAppUser WITH PASSWORD='<password>';
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

$ sqlcmd -S localhost -U WebAppUser -d AppDB -p

INSERT INTO things (name, purpose, last_modified) VALUES ('WebAppUser', 'Web Application User', GETDATE());
GO

SELECT * FROM things;
GO

quit