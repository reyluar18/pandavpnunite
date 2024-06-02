#!/bin/bash

# Source MySQL credentials
. /etc/openvpn/login/config.sh

# Path to the SQL file for import
SQL_FILE="/home/root1/.profiles/teamkidl_dadyjo.sql"

# Function to import the database
import_database() {
    # Connect to MySQL and drop the database if it exists
    mysql -h $HOST -u $USER -p$PASS -e "DROP DATABASE IF EXISTS $DB;"

    # Create the database
    mysql -h $HOST -u $USER -p$PASS -e "CREATE DATABASE $DB;"

    # Import the database from the SQL file
    mysql -h $HOST -u $USER -p$PASS $DB < $SQL_FILE

    echo "Database import completed."
}

# Run the import_database function initially
import_database

# Loop to run the import every 15 minutes
while true; do
    # Call the import_database function
    import_database
    echo "Done"
    sleep 900
done
