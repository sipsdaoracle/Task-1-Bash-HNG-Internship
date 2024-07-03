#!/bin/bash

# Check if the script is run as root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "You must run the script as root" >&2
    exit 1
fi

# Check if a filename is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <name-of-text-file>" >&2
    exit 1
fi

# File paths
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

# Ensure /var/secure storage for passwords
mkdir -p /var/secure
touch $PASSWORD_FILE
chown root:root /var/secure
chmod 700 /var/secure
chmod 600 $PASSWORD_FILE

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Function to generate a random password
generate_password() {
    tr -dc 'A-Za-z0-9!@#$%^&*()_+=-[]{}|;:<>,.?/~' </dev/urandom | head -c 16
}

# Function to hash passwords
hash_password() {
    echo "$1" | openssl passwd -6 -stdin
}

# Read the input file line by line
while IFS=";" read -r username groups; do
    # Trim whitespace
    username=$(echo "$username" | xargs)
    groups=$(echo "$groups" | xargs)

    # Skip empty lines
    if [[ -z "$username" ]]; then
        continue
    fi

    # Check if user already exists
    if id "$username" &>/dev/null; then
        log_action "User $username already exists!"
        continue
    fi

    # Create personal group
    if groupadd "$username"; then
        log_action "Group $username created successfully."
    else
        log_action "Failed to create group $username."
        continue
    fi

    # Create user with a home directory and personal group
    if useradd -m -s /bin/bash -g "$username" "$username"; then
        log_action "User $username created successfully."
    else
        log_action "Failed to create user $username."
        continue
    fi

    # Create groups and add user to them
    IFS=',' read -ra group_array <<< "$groups"
    for group in "${group_array[@]}"; do
        group=$(echo "$group" | xargs)
        if ! getent group "$group" >/dev/null 2>&1; then
            if groupadd "$group"; then
                log_action "Group $group created."
            else
                log_action "Failed to create group $group."
                continue
            fi
        fi
        if usermod -aG "$group" "$username"; then
            log_action "User $username added to group $group."
        else
            log_action "Failed to add user $username to group $group."
        fi
    done

    # Generate random password
    password=$(generate_password)
    hashed_password=$(hash_password "$password")
    if usermod --password "$hashed_password" "$username"; then
        echo "$username,$password" >> $PASSWORD_FILE
        log_action "Password set for user $username."
    else
        log_action "Failed to set password for user $username."
    fi

    # Set home directory permissions
    if mkdir -p "/home/$username" && chown -R "$username:$username" "/home/$username" && chmod 755 "/home/$username"; then
        log_action "Home directory permissions set for user $username."
    else
        log_action "Failed to set home directory permissions for user $username."
    fi

done < "$1"

log_action "User creation process completed. Check $LOG_FILE for details."
