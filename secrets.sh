#!/bin/bash

# Function to validate password
validate_password() {
    local password=$1
    # Check if password has at least 8 characters, 1 upper case, and 1 symbol
    if [[ ${#password} -ge 8 && "$password" =~ [A-Z] && "$password" =~ [^a-zA-Z0-9] ]]; then
        return 0
    else
        return 1
    fi
}

# Function to display a colored spinner
colored_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='\|/-'
    local i=0

    while ps -p $pid > /dev/null; do
        printf "%s" "${spinstr:$i:1}"
        i=$(( (i+1) % 4 ))
        sleep $delay
        printf "\b"
    done

    printf "    \b\b\b\b"
}

# Function to display a colored progress bar
colored_progress_bar() {
    local duration=$1
    local interval=0.2

    (colored_spinner $$) &

    for ((i = 0; i < duration; i++)); do
        sleep $interval
    done

    kill $! > /dev/null 2>&1
    wait $! > /dev/null 2>&1

    echo   # Move to the next line after the progress bar
}
# Function to display colored error message
error_message() {
    local message=$1
    echo -e "\e[91mError: $message\e[0m"
}

# Function to display colored success message
success_message() {
    local message=$1
    echo -e "\e[92mSuccess: $message\e[0m"
}

# Prompt for PostgreSQL credentials
read -p "Enter PostgreSQL user: " postgres_user
read -p "Enter PostgreSQL password: " -s postgres_password
echo

# Validate PostgreSQL password
while ! validate_password "$postgres_password"; do
    error_message "PostgreSQL password must have at least 8 characters, 1 upper case, and 1 symbol."
    read -p "Enter PostgreSQL password: " -s postgres_password
    echo
done

# Prompt for Odoo admin credentials
read -p "Enter Odoo admin password: " -s odoo_admin_password
echo

# Validate Odoo admin password
while ! validate_password "$odoo_admin_password"; do
    error_message "Odoo admin password must have at least 8 characters, 1 upper case, and 1 symbol."
    read -p "Enter Odoo admin password: " -s odoo_admin_password
    echo
done

# Update docker-compose.yaml
echo -e "\n\e[1;34mUpdating PostgreSQL and Odoo credentials in docker-compose.yaml...\e[0m"
colored_progress_bar 10
sed -i "s/POSTGRES_USER:.*$/POSTGRES_USER: $postgres_user/" docker-compose.yaml
sed -i "s/POSTGRES_PASSWORD:.*$/POSTGRES_PASSWORD: $postgres_password/" docker-compose.yaml
sed -i "s/DB_USER:.*$/DB_USER: $postgres_user/" docker-compose.yaml
sed -i "s/DB_PASSWORD:.*$/DB_PASSWORD: $postgres_password/" docker-compose.yaml

# Update odoo.conf
echo -e "\n\e[1;34mUpdating PostgreSQL and Odoo admin credentials in odoo.conf...\e[0m"
colored_progress_bar 10
sed -i "s/db_user = .*$/db_user = $postgres_user/" odoo.conf
sed -i "s/db_password = .*$/db_password = $postgres_password/" odoo.conf
sed -i "s/admin_passwd = .*$/admin_passwd = $odoo_admin_password/" odoo.conf

success_message "Secrets Changed!"

