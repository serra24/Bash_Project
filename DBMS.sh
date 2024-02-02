#!/usr/bin/bash
echo "Hello To DataBase Engine created by : Eng. Israa Lotfy & Eng.Hagar Serag" 

mkdir DB 2>> /dev/null
cd DB

database_folder="$(pwd)"
current_database=""
current_table=""

replace_spaces() {
  # Replace spaces with underscores
  echo "${1// /_}"
}

create_database() {
  read -p "Enter database name: " new_database
  new_database=$(replace_spaces "$new_database")

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

list_databases() {
  echo "List of databases:"
  ls  "$database_folder" | grep '/$' | sed 's/\/$//'
}

drop_database() {
  read -p "Enter database name to drop: " drop_db
  drop_db=$(replace_spaces "$drop_db")

  if [ -d "$database_folder/$drop_db" ]; then
    rm -r "$database_folder/$drop_db"
    echo "Database '$drop_db' dropped successfully."
  else
    echo "Error: Database '$drop_db' not found."
  fi
}

connect_to_database() {
  read -p "Enter database name to connect: " connect_db
  connect_db=$(replace_spaces "$connect_db")

  if [ -d "$database_folder/$connect_db" ]; then
    current_database="$connect_db"
    cd "$database_folder/$connect_db" || exit
    echo "Connected to database '$connect_db'"
  else
    echo "Error: Database '$connect_db' not found."
  fi
}

 create_table() {
    
     read -p "Enter your table name: " tablename
     tablename=$(replace_spaces "$tablename")
    
  

    # Table name shouldn't start with numbers
    while ! [[ $tablename =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]]; do
        echo -e "Invalid table name!!"
        echo -e "Enter your table name: \c"
        read tablename
    done

    # Check if the table already exists
    if [ -e "$tablename" ]; then
       
        echo -e "$tablename table already exists.\n"
        return
    fi

    # Enter the number of columns in the table
    echo -e "Number of Columns: \c"
    read colsNum

    # Check if the user enters a number or something else
    while ! [[ $colsNum =~ ^[0-9]+$ && $colsNum -gt 0 ]]; do
        echo -e "Invalid number!!"
        echo -e "Number of Columns: \c"
        read colsNum
    done

    # Columns counter
    count=1

    # Field separator
    sep="|"

    # Record separator
    rSep="\n"

    # Meta data string
    metaData="Field$sep"Type$sep"Key"

    # While the counter is less than the number of columns that you entered
    while [ $count -le $colsNum ]; do
        if [[ $count -eq 1 ]]; then
            echo -e "Enter Name of Your Primary Key Column: \c"
            read colName

            # Column name shouldn't contain anything except characters
            while ! [[ $colName =~ ^[a-zA-Z]+$ ]]; do
                echo -e "Invalid column name!!"
                echo -e "Enter Name of Your Primary Key Column: \c"
                read colName
            done
        else
            # Enter the column name
            echo -e "Name of Column No.$count: \c"
            read colName

            while ! [[ $colName =~ ^[a-zA-Z]+$ ]]; do
                echo -e "Invalid column name!!"
                echo -e "Name of Column No.$count: \c"
                read colName
            done
        fi

        # Choose the column type
        echo -e "Type of Column $colName (int/varchar): \c"
        read colType

        while ! [[ $colType =~ ^(int|varchar)$ ]]; do
            echo -e "Invalid column type!!"
            echo -e "Type of Column $colName (int/varchar): \c"
            read colType
        done

        # Choose if it is a primary key or not
        if [[ $count -eq 1 ]]; then
            metaData+=$rSep$colName$sep$colType$sep"PK"
        else
            metaData+=$rSep$colName$sep$colType$sep""
        fi

        # Columns names
        if [[ $count == $colsNum ]]; then
            temp=$temp$colName
        else
            temp=$temp$colName$sep
        fi

        ((count++))
    done

   

    # Create metadata hidden file
    touch .$tablename

    # Insert metadata string in metadata file
    echo -e $metaData >>.$tablename

    # Create table file
    touch $tablename

    # Insert columns names in table file
    echo -e $temp >>$tablename

    if [[ $? == 0 ]]; then
        # The table created successfully
        echo -e "Table created successfully.\n"
    else
        echo -e "Error creating table $tablename.\n"
    fi
}



list_tables() {
  echo "List of tables in database '$current_database':"
  for table in "$database_folder/$current_database"/*; do
    [ -f "$table" ] && echo "$(basename "$table")"
  done
}
insert_into_table() {
                echo -e "Table Name: \c"
                read tableName
                # check if your table  not exist by !-f
                if ! [[ -f $tableName ]]; then
                    # it dosn't exist
                    
                    echo -e "Table $tableName isn't existed ,choose another Table\n"
                    
                fi
                # it exists so
                # get the number of columns
                colsNum=$(awk 'END{print NR}' .$tableName)
                sep="|"
                rSep="\n"
                row=""
                for ((i = 2; i <= $colsNum; i++)); do
                    # trace on each record in metadata hidden file
                    colName=$(awk 'BEGIN{FS="|"}{ if(NR=='$i') print $1}' .$tableName)
                    colType=$(awk 'BEGIN{FS="|"}{if(NR=='$i') print $2}' .$tableName)
                    # get record values from user
                    echo -e "$colName ($colType) = \c"
                    read data
                    # is it a primary key ?
                    if [[ $i -eq 2 ]]; then
                        while [[ true ]]; do
                            # if it is a primary key so
                            # check if it is available
                            if [[ $colType == "int" ]]; then
                                while [[ !( $data =~ ^[0-9]*$ ) && $data != "" ]]; do
                                    echo -e "Primary Key can't be empty !!"
                                    echo -e "invalid DataType !!"
                                    echo -e "$colName ($colType) = \c"
                                    read data
                                done
                            fi
                            if [[ $colType == "varchar" ]]; then
                                while [[ !( $data =~ ^[a-zA-Z]*$ ) && $data != "" ]]; do
                                    echo -e "Primary Key can't be empty !!"
                                    echo -e "invalid DataType !!"
                                    echo -e "$colName ($colType) = \c"
                                    read data
                                done
                            fi
                            if [ "$data" = "`awk -F "|" '{ print $1 }' $tableName | grep "^$data$"`" ]; then
                                echo -e "invalid input for Primary Key !!"
                                echo -e "$colName ($colType) = \c"
                                read data
                            else
                                break
                            fi
                        done
                    fi
                    # Validate datatype
                    # is it an integer ?
                    if [[ $i -ne 2 ]]; then
                        if [[ $colType == "int" ]]; then
                            while ! [[ $data =~ ^[0-9]*$ ]]; do
                                echo -e "invalid DataType !!"
                                echo -e "$colName ($colType) = \c"
                                read data
                            done
                        fi
                        # is it a varchar ?
                        if [[ $colType == "varchar" ]]; then
                            while ! [[ $data =~ ^[a-zA-Z]*$ ]]; do
                                echo -e "invalid DataType !!"
                                echo -e "$colName ($colType) = \c"
                                read data
                            done
                        fi
                    fi
                    #Set value in record
                    if [[ $i == $colsNum ]]; then
                        row=$row$data$rSep
                    else
                        row=$row$data$sep
                    fi
                done
                # if all done set full record in the table
                echo -e $row"\c" >>$tableName
                # check if Data Inserted Successfully
                clear
                if [[ $? == 0 ]]; then
                    echo -e "\nData Inserted Successfully\n"
                else
                    echo -e "\nError Inserting Data into Table $tableName\n"
                fi
                q=0
          
            
}



drop_table() {
  read -p "Enter table name to drop: " drop_table
  drop_table=$(replace_spaces "$drop_table")
  if [ -f "$database_folder/$current_database/$drop_table" ]; then
    rm "$database_folder/$current_database/$drop_table"
    echo "Table '$drop_table' dropped successfully."
  else
    echo "Error: Table '$drop_table' not found."
  fi
}


select_from_table() {
  read -p "Enter table name to select from: " select_table
  select_table=$(replace_spaces "$select_table")
  if [ -f "$database_folder/$current_database/$select_table" ]; then
  while true; do
    echo -e "\nSelect Menu:"
    echo "1. Select All"
    echo "2. Select by Column"
    echo "3. Select by Row"
    echo "4.Back to table menu"
    
    read -p "Enter your choice: " select_choice
    select_choice=$(replace_spaces "$select_choice")
    case $select_choice in
      1)
        cat "$database_folder/$current_database/$select_table" | sed -n '1,$p'
        ;;
      2)
      read -p "Enter column number to select: " col_number
        cut -d'|' -f"$col_number" "$database_folder/$current_database/$select_table" | sed -n '1,$p'
        ;;
      3)
        read -p "Enter row number to select: " row_number
        sed -n "$((row_number + 1))p" "$database_folder/$current_database/$select_table"
        ;;
      4)
            break
            ;;
      *)
        echo "Error: Invalid choice. Please enter a valid option."
        ;;
    esac
    done
      
  else
    echo "Error: Table '$select_table' not found."
  fi
}

delete_from_table() {
  read -p "Enter table name to delete from: " delete_table
  delete_table=$(replace_spaces "$delete_table")
  if [ -f "$database_folder/$current_database/$delete_table" ]; then
    echo -e "\nDelete Menu:"
    echo "1. Delete by ID"
    echo "2. Delete All"
    echo "3. Back to table menu"
    echo "0. Exit"
    read -p "Enter your choice: " delete_choice

    case $delete_choice in
      1)
        read -p "Enter ID to delete: " delete_id
        sed -i "/^$delete_id|/d" "$database_folder/$current_database/$delete_table"
        echo "Row with ID '$delete_id' deleted from '$delete_table' successfully."
        ;;
      2)
         sed -i '2,$d' "$database_folder/$current_database/$delete_table"
        echo "All rows deleted from '$delete_table' successfully."
        ;;
      3)
        break
        ;;
      0)
        echo "Exiting the script."
        exit 0
        ;;
      *)
        echo "Error: Invalid choice. Please enter a valid option."
        ;;
    esac
  else
    echo "Error: Table '$delete_table' not found."
  fi
}

update_table() {
  echo -e "Table Name: \c"
  read tableName

  # Check if the table exists
  if [ ! -f "$database_folder/$current_database/$tableName" ]; then
    echo -e "Table $tableName doesn't exist. Choose another table.\n"
    return
  fi

  # Prompt for ID to update
  read -p "Enter ID to update: " updateId

  # Check if the ID exists in the table
  if ! grep -q "^$updateId" "$database_folder/$current_database/$tableName"; then
    echo "Error: ID '$updateId' not found in the table."
    return
  fi

  # Get the number of columns in the table
  colsNum=$(awk 'END{print NR}' "$database_folder/$current_database/.$tableName")

  # Display the current row for the given ID
  echo "Current Row for ID '$updateId':"
  grep "^$updateId|" "$database_folder/$current_database/$tableName"

  # Prompt for the column to update
  read -p "Enter the column name to update: " updateCol

  # Validate if the column name(data) exists
  if ! grep -q "$updateCol" "$database_folder/$current_database/$tableName"; then
    echo "Error: Column '$updateCol' not found in the table."
    return
  fi

  # Prompt for the new value for the specified column
  read -p "Enter new value for '$updateCol': " newData

  # Validate datatype
  colType=$(awk -F'|' -v colName="$updateCol" 'NR>1 && $1 == colName {print $2}' "$database_folder/$current_database/.$tableName")
  if [[ $colType == "int" ]]; then
    while ! [[ $newData =~ ^[0-9]*$ ]]; do
      echo -e "Invalid data type for '$updateCol' (integer) !!"
      read -p "Enter new value for '$updateCol': " newData
    done
  elif [[ $colType == "varchar" ]]; then
    while ! [[ $newData =~ ^[a-zA-Z]*$ ]]; do
      echo -e "Invalid data type for '$updateCol' (varchar) !!"
      read -p "Enter new value for '$updateCol': " newData
    done
  fi

  # Update the row in the table
  awk -v key="$updateId" -v newCol="$updateCol" -v newData="$newData" -F'|' '
    BEGIN {
      OFS = FS
    }
    {
      if ($1 == key) {
        for (i = 2; i <= NF; i++) {
          if ($i == newCol) {
            $i = newData
          }
        }
      }
      print
    }
  ' "$database_folder/$current_database/$tableName" > temp_table && mv temp_table "$database_folder/$current_database/$tableName"

  echo "Row updated successfully."
}



while true; do
  echo -e "\nMenu:"
  echo "1. Create Database"
  echo "2. List Databases"
  echo "3. Drop Database"
  echo "4. Connect to Database"
  echo "5. Exit"

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
      while [ -n "$current_database" ]; do
        echo -e "\nTable Menu for Database '$current_database':"
        echo "1. Create Table"
        echo "2. List Tables"
        echo "3. Drop Table"
        echo "4. Insert into Table"
        echo "5. Select from Table"
        echo "6. Delete from Table"
        echo "7. Update Table"
        echo "8. Back to Database Menu"
        echo "0. Exit"

        read -p "Enter your choice: " table_choice

        case $table_choice in
          1)
            create_table
            ;;
          2)
            list_tables
            ;;
          3)
            drop_table
            ;;
          4)
            insert_into_table
            ;;
          5)
            select_from_table
            ;;
          6)
            delete_from_table
            ;;
          7)
            update_table
            ;;
          8)
            break
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
      ;;
    5)
      echo "Exiting the script."
      exit 0
      ;;
    *)
      echo "Error: Invalid choice. Please enter a valid option."
      ;;
  esac
done

