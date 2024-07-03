#!/bin/bash

LOGFILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

mkdir -p /var/secure
chmod 700 /var/secure
touch $LOGFILE
chmod 600 $LOGFILE
touch $PASSWORD_FILE
chmod 600 $PASSWORD_FILE

log() {
    echo "$(date +"%Y-%m-%d %T") : $1" | tee -a $LOGFILE
}

# Generate random password
generate_password() {
    echo $(openssl rand -base64 12)
}

if [ -z "$1" ]; then
    echo "Usage: $0 <userfile>"
    exit 1
fi

USERFILE="$1"

if [ ! -f "$USERFILE" ]; then
    echo "User file not found!"
    exit 1
fi

while IFS=';' read -r username groups; do
    # Remove whitespace
    username=$(echo $username | xargs)
    groups=$(echo $groups | xargs)
    
    if id "$username" &>/dev/null; then
        log "User $username already exists. Skipping."
        continue
    fi

    useradd -m -s /bin/bash "$username"
    if [ $? -eq 0 ]; then
        log "User $username created successfully."
    else
        log "Failed to create user $username."
        continue
    fi

    usermod -g "$username" "$username"

    IFS=',' read -ra ADDR <<< "$groups"
    for group in "${ADDR[@]}"; do
        group=$(echo $group | xargs)
        if [ $(getent group $group) ]; then
            usermod -aG "$group" "$username"
            log "Added $username to group $group."
        else
            log "Group $group does not exist. Creating group and adding $username."
            groupadd "$group"
            usermod -aG "$group" "$username"
        fi
    done

    password=$(generate_password)
    echo "$username,$password" >> $PASSWORD_FILE
    echo "$username:$password" | chpasswd
    log "Password for $username set and stored securely."
    
done < "$USERFILE"

log "User creation process completed."
