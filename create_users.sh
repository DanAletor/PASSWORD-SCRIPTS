#!/bin/bash

INPUT_FILE="$1"

if [ -z "$1" ]; then
  echo "Usage: $0 <name-of-text-file>"
  exit 1
fi

LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

touch "$LOG_FILE"
touch "$PASSWORD_FILE"

chmod 600 "$PASSWORD_FILE"

generate_password() {
  echo "$(openssl rand -base64 12)"
}

while IFS=';' read -r username groups; do
  # Remove whitespace
  username=$(echo "$username" | xargs)
  groups=$(echo "$groups" | xargs)

  if id "$username" &>/dev/null; then
    echo "User $username already exists. Skipping..." | tee -a "$LOG_FILE"
    continue
  fi

  groupadd "$username"
  echo "Group $username created." | tee -a "$LOG_FILE"

  useradd -m -g "$username" -G "$(echo "$groups" | tr ',' ' ')" "$username"
  echo "User $username created and added to groups: $groups." | tee -a "$LOG_FILE"

  password=$(generate_password)
  echo "$username,$password" >> "$PASSWORD_FILE"

  echo "$username:$password" | chpasswd
  echo "Password set for user $username." | tee -a "$LOG_FILE"

  chmod 700 "/home/$username"
  chown "$username:$username" "/home/$username"
  echo "Permissions set for /home/$username." | tee -a "$LOG_FILE"

done < "$INPUT_FILE"

echo "User creation process completed." | tee -a "$LOG_FILE"
