#! /bin/bash
#SOURCE: https://www.labsrc.com/automating-mariadb-backups-as-securely-as-possible/

### 2.1.1 Backup Policy in Place (Manual) ###
### 2.1.2 Verify Backups are Good (Manual) ###
### 2.1.3 Secure Backup Credentials (Manual) ###

echo -n "[+] ENTER the relative path of your Mariadb configuration directory [e.g /etc/mysql/mariadb.conf.d]: "
read -r MARIADB_DIR

# Check if InnoDB is used by tables.
if ! mariadb --execute "SELECT table_name, table_schema, engine FROM information_schema.tables WHERE engine = 'MyISAM' AND table_schema <> 'mysql'"; then
	echo "[+] Error, MyISAM tables detected. Convert them in InnoDB tables." || exit 1
fi
# Bzip2 is required for encrypted the databse later.
if ! [ -x "$(command -v bzip2)" ]; then
	echo "[+] Error, install bzip2." || exit 1
fi
# Cron is required for scheduled backup.
if ! [ -x "$(command -v crontab)" ]; then
	echo "[+] Error, install cron." || exit 1
fi

# Create Backup user.
mariadb --execute "GRANT SELECT, SHOW VIEW ON *.* TO 'mdbbackup'@'localhost' IDENTIFIED BY 'password';
flush privileges;"

# Create backup config file.
touch "$MARIADB_DIR"/backup.cnf
chmod 600 "$MARIADB_DIR"/backup.cnf
echo -n "[+] ENTER the password for the backup user mdbbackup store in the backup.cnf file: "
read -r PASS
cat <<EOF >>"$MARIADB_DIR"/backup.cnf
[mysqldump]

user = mdbbackup
password = "$PASS"
EOF

# Generate Private key.
echo "[+] Do not use the same password as the backup user. Use a strong one"
openssl genpkey -algorithm RSA -out "$MARIADB_DIR"/mdbbackup-priv.key -pkeyopt rsa_keygen_bits:4096 -aes256
openssl req -x509 -nodes -key "$MARIADB_DIR"/mdbbackup-priv.key -out "$MARIADB_DIR"/mdbbackup-pub.key
echo "[+] Store your private cert [mdbbackup-priv.key] in a different place for better security"

# Create cron daily backup at 1:00AM for all databases. Backup will be compress & encrypt and will be stored in /var/lib/mysql
crontab -l >crontab_new
echo "00 01 * * * mysqldump --routines --triggers --events --quick --single-transaction --all-databases | bzip2 | openssl smime -encrypt -binary -text -aes256 -out /var/lib/mysql/alldb_$('date +\%Y-\%m-\%d').sql.bz2.enc -outform DER $MARIADB_DIR/mdbbackup-pub.key && chmod 600 /var/lib/mysql/alldb_$('date +\%Y-\%m-\%d').sql.bz2.enc" >>crontab_new
crontab -e crontab_new
rm ./crontab_new
