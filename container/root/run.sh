#!/bin/bash
string=$1
DBS=(${string//:/ })
CREATE_REQUIRED=false

for DB in "${DBS[@]}"; do

  if [ ! -d /var/lib/mysql/$DB ]; then
    echo -e "($DB) DB to be created";
    CREATE_REQUIRED=true;
  fi;

done;

if [ $CREATE_REQUIRED == true ]; then

  # Start database in the background, so commands can be run against it
  service mysql start

  # Add default privileges
  echo "GRANT ALL ON *.* TO '$CFG_DB_USER'@'%' IDENTIFIED BY '$CFG_DB_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql

  for DB in "${DBS[@]}"; do

    # Provides ability to only add missing databases
    if [ ! -d /var/lib/mysql/$DB ]; then

      echo "($DB) Creating DB";

      # Create the database
      mysql -u root -e "CREATE DATABASE $DB"

      echo "($DB) Ingesting Schema";

      # Create the database tables from the schema/db directory
      for filename in $CFG_DB_SCHEMA_DIR/$DB/*.sql; do
        echo "Importing $filename";
        mysql -u root $DB < $filename
      done

    fi;

  done

  # Unfortunately, there's no *good* way to reattach to the background mysqld_safe job
  service mysql stop

fi;

echo 'Starting MySQL';

# Restart now, DB is populated
/usr/bin/mysqld_safe
