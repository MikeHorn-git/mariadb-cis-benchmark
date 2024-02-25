# Warning
Use this project in a dedicated test environment.

# Information
This project have 2 approachs :
* Declarative with my.cnf and mariadb.cnf files.
* Imperative with the mariadbHardened.sh script.

# Overview
## Installation
```bash
git clone https://github.com/MikeHorn-git/mariadb.cnf.git
cd mariadb.cnf
```

## docker-compose.yml
Modify to your need the yaml file before.
```bash
docker-compose up
```

## mariadb.cnf
Manual steps are required for certains steps. Like creating certification keys and so on.
Copy the files to your mysql conf.d folder.
```bash
sudo cp ./mariadb.cnf /etc/mysql/conf.d/mariadb.cnf
```

## mariadbHardened.sh
Script that dynamically hardened a running mariadb instance.
```bash
chmod +x ./mariadbHardened.sh
sudo ./maradbHardened.sh
```

## my.cnf
Classic my.cnf file. Required for mariadb.cnf.
```bash
sudo cp ./my.cnf /etc/mysql
```

# CIS Implementations
## backup.sh
* 2.1.1 Backup Policy in Place
* 2.1.2 Verify Backups are Good
* 2.1.3 Secure Backup Credentials

## mariadbHardened.sh
* 1.2 Use Dedicated Least Privileged Account for MariaDB Daemon/Service
* 1.3 Disable MariaDB Command History
* 1.5 Ensure Interactive Login is Disabled
* 2.1.5 Point-in-Time Recovery
* 2.3 Do Not Specify Passwords in the Command Line [Partial]
* 2.6 Ensure 'password_lifetime' is Less Than or Equal to '365'
* 3.1 Ensure 'datadir' Has Appropriate Permissions
* 3.2 Ensure 'log_bin_basename' Files Have Appropriate Permissions
* 3.3 Ensure 'log_error' Has Appropriate Permissions
* 3.4 Ensure 'slow_query_log' Has Appropriate Permissions
* 3.5 Ensure 'relay_log_basename' Files Have Appropriate Permissions
* 3.6 Ensure 'general_log_file' Has Appropriate Permissions
* 3.8 Ensure Plugin Directory Has Appropriate Permissions
* 3.9 Ensure 'server_audit_file_path' Has Appropriate Permissions
* 4.2 Ensure Example or Test Databases are Not Installed on Production Servers
* 4.4 Harden Usage for 'local_infile' on MariaDB Clients
* 4.8 Ensure 'sql_mode' Contains 'STRICT_ALL_TABLES'
* 6.3 Ensure 'log_warnings' is Set to '2'
* 6.4 Ensure Audit Logging Is Enabled
* 7.1 Disable use of the mysql_old_password plugin
* 7.3 Ensure strong authentication is utilized for all accounts
* 7.4 Ensure Password Complexity Policies are in Place
* 8.1 Ensure 'require_secure_transport' is Set to 'ON' and 'have_ssl' is Set to 'YES'

## my.cnf
* 1.2 Use Dedicated Least Privileged Account for MariaDB Daemon/Service
* 2.1.5 Point-in-Time Recovery
* 2.6 Ensure 'password_lifetime' is Less Than or Equal to '365'
* 2.10 Limit Accepted Transport Layer Security (TLS) Versions
* 2.11 Require Client-Side Certificates (X.509)
* 2.12 Ensure Only Approved Ciphers are Used
* 3.9 Ensure 'server_audit_file_path' Has Appropriate Permissions
* 4.4 Harden Usage for 'local_infile' on MariaDB Clients
* 4.5 Ensure mariadb is Not Started With 'skip-grant-tables'
* 4.6 Ensure Symbolic Links are Disabled (Automated)
* 4.8 Ensure 'sql_mode' Contains 'STRICT_ALL_TABLES'
* 6.1 Ensure 'log_error' is configured correctly
* 6.3 Ensure 'log_warnings' is Set to '2'
* 6.4 Ensure Audit Logging Is Enabled
* 6.5 Ensure the Audit Plugin Can't be Unloaded
* 6.6 Ensure Binary and Relay Logs are Encrypted
* 7.1 Disable use of the mysql_old_password plugin
* 7.4 Ensure Password Complexity Policies are in Place
* 8.1 Ensure 'require_secure_transport' is Set to 'ON' and 'have_ssl' is Set to 'YES'
