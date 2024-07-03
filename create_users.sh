#!/bin/bash

LOGFILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

# Create necessary directories and set permissions
mkdir -p /var/secure
chmod 700 /var/secure

# Create log and password files if they don't exist and set appropriate permissions
touch $LOGFILE
chmod 600 $LOGFILE
touch $PASSWORD_FILE
chmod 600 $PASSWORD_FILE

# Log function to write messages to the log file with a timestamp
log() {
    echo "$(date +"%Y-%m-%d %T") : $1" | tee -a $LOGFILE
}

# Function to generate a random password
generate_password() {
    echo $(openssl rand -base64 12)
}

# Check if a user file is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <userfile>"
    exit 1
fi

USERFILE="$1"

# Check if the user file exists using full path
if [ ! -f "$USERFILE" ]; then
    echo "User file $USERFILE not found!"
    exit 1
fi

# Read the user file line by line
while IFS=';' read -r username groups; do
    # Remove whitespace from username and groups
    username=$(echo $username | xargs)
    groups=$(echo $groups | xargs)
    
    # Log and skip if user already exists
    if id "$username" &>/dev/null; then
        log "User $username already exists. Skipping."
        continue
    fi

    # Create user with home directory and default shell
    useradd -m -s /bin/bash "$username"
    if [ $? -eq 0 ]; then
        log "User $username created successfully."
    else
        log "Failed to create user $username."
        continue
    fi

    # Create user's personal group (same as username)
    groupadd "$username"
    usermod -g "$username" "$username"

    # Add user to additional groups
    IFS=',' read -ra ADDR <<< "$groups"
    for group in "${ADDR[@]}"; do
        group=$(echo $group | xargs)
        if getent group $group &>/dev/null; then
            usermod -aG "$group" "$username"
            log "Added $username to group $group."
        else
            groupadd "$group"
            usermod -aG "$group" "$username"
            log "Group $group created and $username added."
        fi
    done

    # Generate and store password
    password=$(generate_password)
    echo "$username,$password" >> $PASSWORD_FILE
    echo "$username:$password" | chpasswd
    log "Password for $username set and stored securely."
    
done < "$USERFILE"

log "User creation process completed."
