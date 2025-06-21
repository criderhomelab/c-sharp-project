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

# Confirm Working
$ sqlcmd -S localhost -U SA -p

select @@version
go

select name from sys.databases;
go

# Create a Database and User
CREATE LOGIN Alex WITH PASSWORD='Myp@ssw0rd0987==+';
GO

CREATE DATABASE AppDB;
GO

USE AppDB;
GO

CREATE TABLE users (
id INT PRIMARY KEY IDENTITY (1, 1),
first_name VARCHAR (50) NOT NULL,
last_name varchar(50) NOT NULL,
email varchar(50),
last_login DATE NOT NULL
);
GO

CREATE USER Alex FOR LOGIN Alex;
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON users TO Alex;
GO

$ sqlcmd -S localhost -U Alex -d AppDB -p

INSERT INTO users (first_name, last_name, email, last_login) VALUES ('Alex', 'Seed', 'alex@howtoforge.local', '20221201');
GO

SELECT * FROM users;
GO

quit