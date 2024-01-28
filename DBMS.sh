#!/usr/bin/bash

database_folder="$(pwd)"
current_database=""

create_database() {
  read -p "Enter database name: " new_database

  # Replace spaces with underscores in the database name
  new_database="${new_database// /_}"

  # Validate the database name using a regular expression
  if [[ "$new_database" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
    if [ -d "$database_folder/$new_database" ]; then
      echo "Error: Database '$new_database' already exists."
    else
      mkdir "$database_folder/$new_database"
      echo "Database '$new_database' created."
    fi
  else
    echo "Error: Invalid database name '$new_database'."
  fi
}



# Function to list databases
list_databases() {
  echo "List of databases:"
  for db in "$database_folder"/*; do
    [ -d "$db" ] && echo "$(basename "$db")"
  done
}


# Function to drop a database
drop_database() {
  read -p "Enter database name to drop: " drop_db
  if [ -d "$database_folder/$drop_db" ]; then
    rm -r "$database_folder/$drop_db"
    echo "Database '$drop_db' dropped successfully."
  else
    echo "Error: Database '$drop_db' not found."
  fi
}

# Function to connect to a database
connect_to_database() {
  read -p "Enter database name to connect: " connect_db
  if [ -d "$database_folder/$connect_db" ]; then
    current_database="$connect_db"
    cd "$database_folder/$connect_db" || exit
    echo "Connected to database "
  else
    echo "Error: Database '$connect_db' not found."
  fi
}

# Main menu
while true; do
  echo -e "\nMenu:"
  echo "1. Create Database"
  echo "2. List Databases"
  echo "3. Drop Database"
  echo "4. Connect to Database"
  echo "0. Exit"

  read -p "Enter your choice: " choice

  case $choice in
    1)
      create_database
      ;;
    2)
      list_databases
      ;;
    3)
      drop_database
      ;;
    4)
      connect_to_database
      ;;
    0)
      echo "Exiting the script."
      exit 0
      ;;
    *)
      echo "Error: Invalid choice. Please enter a valid option."
      ;;
  esac
done

