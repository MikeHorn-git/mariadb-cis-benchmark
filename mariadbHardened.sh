#! /bin/bash
DATADIR=/var/lib/mysql

### 1.2 Use Dedicated Least Privileged Account for MariaDB Daemon/Service (Automated) ###
if ps -ef | grep -E "^mysql.*$" &>/dev/null; then
    groupadd -g 27 -o -r mysql >/dev/null 2>&1
    useradd -M -N -g mysql -o -r -d /var/lib/mysql -s /bin/false -c "MariaDB Server" -u 27 mysql >/dev/null 2>&1
fi

### 1.3 Disable MariaDB Command History (Automated) ###
find /home -name ".mysql_history" -exec shred -xfzu {} \;
find /root -name ".mysql_history" -exec shred -xfzu {} \;
ln -s /dev/null "$HOME"/.mysql_history
echo "MYSQL_HISTFILE=/dev/null" >> ~/.bashrc
echo "MYSQL_HISTFILE=/dev/null" >> ~/.zshrc

### 1.5 Ensure Interactive Login is Disabled (Automated) ###
usermod -s /sbin/nologin mysql

### 2.1.5 Point-in-Time Recovery (Automated) ###
mariadb --execute 'SET GLOBAL binlog_expire_logs_seconds=864000;'

### 2.3 Do Not Specify Passwords in the Command Line (Manual) [Partial] ###
find /home -name ".bash_history" -exec shred -xfzu {} \;
find /root -name ".bash_history" -exec shred -xfzu {} \;
find /home -name ".zsh_history" -exec shred -xfzu {} \;
find /root -name ".zsh_history" -exec shred -xfzu {} \;

### 2.6 Ensure 'password_lifetime' is Less Than or Equal to '365'(Automated) ###
mariadb --execute 'SET GLOBAL default_password_lifetime=8365;'

### 3.1 Ensure 'datadir' Has Appropriate Permissions (Automated) ###
chmod 750 "$DATADIR"
chown mysql:mysql "$DATADIR"

### 3.2 Ensure 'log_bin_basename' Files Have Appropriate Permissions (Automated) ###
find "$DATADIR" -name "log_bin_basename*" -exec chmod 660 {} \; -exec chown mysql:mysql {} \;

### 3.3 Ensure 'log_error' Has Appropriate Permissions (Automated) ###
find "$DATADIR" -name "mysql_error.log" -exec chmod 660 {} \; -exec chown mysql:mysql {} \;

### 3.4 Ensure 'slow_query_log' Has Appropriate Permissions (Automated) ###
mariadb --execute "SET SESSION slow_query_log=0;"

### 3.5 Ensure 'relay_log_basename' Files Have Appropriate Permissions (Automated) ###
find "$DATADIR" -name "relay_log_basename*" -exec chmod 660 {} \; -exec chown mysql:mysql {} \;

### 3.6 Ensure 'general_log_file' Has Appropriate Permissions (Automated) ###
mariadb --execute 'SET GLOBAL GENERAL_LOG=OFF;'
find "$DATADIR" -name "'$HOSTNAME'.log" -exec chmod 600 {} \; -exec chown mysql:mysql {} \;

### 3.8 Ensure Plugin Directory Has Appropriate Permissions (Automated) ###
TMP=$(mariadb --execute "SHOW Variables WHERE Variable_name='plugin_dir';")
PLUGINDIR=$(echo "$TMP" | cut -d ' ' -f4)
chmod 550 "$PLUGINDIR"
chown mysql:mysql "$PLUGINDIR"

### 3.9 Ensure 'server_audit_file_path' Has Appropriate Permissions (Automated) ###
TMP=$(mariadb --execute "SHOW Global Variables WHERE Variable_name='server_audit_file_path';")
AUDITPATH=$(echo "$TMP" | cut -d ' ' -f4)
chmod 660 "$AUDITPATH"
chown mysql:mysql "$AUDITPATH"

### 4.2 Ensure Example or Test Databases are Not Installed on Production Servers (Automated) [Partial]###
mariadb --execute "DROP DATABASE test;"

### 4.4 Harden Usage for 'local_infile' on MariaDB Clients (Automated) ###
mariadb --execute "SET GLOBAL local_infile=OFF;"

### 4.8 Ensure 'sql_mode' Contains 'STRICT_ALL_TABLES' (Automated) ###
mariadb --execute "SET GLOBAL sql_mode='STRICT_ALL_TABLES,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';"

### 6.3 Ensure 'log_warnings' is Set to '2' (Automated) ###
mariadb --execute "SET GLOBAL log_warnings=2;"

### 6.4 Ensure Audit Logging Is Enabled (Automated) ###
mariadb --execute "INSTALL SONAME 'server_audit';"
mariadb --execute "SET GLOBAL server_audit_logging=ON;"
mariadb --execute "SET GLOBAL server_audit_events=CONNECT;"

### 7.1 Disable use of the mysql_old_password plugin (Automated) ###
mariadb --execute "SET GLOBAL old_passwords=OFF;"
mariadb --execute "SET GLOBAL secure_auth=ON;"

### 7.3 Ensure strong authentication is utilized for all accounts (Automated) ###
mariadb --execute "ALTER USER 'root'@'localhost' identified via 'unix_socket';"
mariadb --execute "SET PASSWORD for 'mysql'@'localhost' = 'invalid';"
mariadb --execute "SET PASSWORD for 'mariadb.sys'@'localhost' = 'invalid';"
mariadb --execute "SET PASSWORD for 'mdbbackup'@'localhost' = 'invalid';"

### 7.4 Ensure Password Complexity Policies are in Place (Automated) ###
mariadb --execute "INSTALL SONAME 'simple_password_check'"
mariadb --execute "INSTALL SONAME 'cracklib_password_check'"    # apt install mariadb-plugin-cracklib-password-check
mariadb --execute "SET GLOBAL simple_password_check_minimal_length=14;"
mariadb --execute "SET GLOBAL strict_password_validation=ON;"

### 8.1 Ensure 'require_secure_transport' is Set to 'ON' and 'have_ssl' is Set to 'YES' (Automate) ###
mariadb --execute "SET GLOBAL require_secure_transport=1;"