**Automating User Creation on Ubuntu with a Bash Script
**
**Introduction**

Efficiently managing user accounts is crucial for system security and operations. This article explains a Bash script, `create_users.sh`, which automates user creation based on a provided text file. The script reads usernames and groups, creates users and groups, sets up home directories, generates passwords, and logs all actions.

### Script Overview

The `create_users.sh` script:
1. Reads a text file with usernames and group names.
2. Creates users and groups as specified.
3. Sets up home directories with appropriate permissions.
4. Generates random passwords for the users.
5. Logs all actions to `/var/log/user_management.log`.
6. Stores generated passwords securely in `/var/secure/user_passwords.csv`.

### Script Components

1. **Initial Setup** (Lines 1-11)
    - Initializes log and password file paths.
    - Creates necessary directories and files with secure permissions.

2. **Logging Function** (Lines 13-15)
    - Writes messages to the log file with a timestamp.

3. **Password Generation** (Lines 17-19)
    - Generates random passwords using `openssl`.

4. **Argument and File Checks** (Lines 21-25)
    - Checks if the user file is provided and exists.

5. **Main Logic** (Lines 27-65)
    - Processes each line of the user file.
    - Creates users and their personal groups.
    - Assigns users to additional groups.
    - Generates and stores passwords.
    - Logs all actions.

### Usage

1. **Create the Input File**

Create a text file with the following format:
```
light; sudo,dev,www-data
idimma; sudo
mayowa; dev,www-data
```

2. **Make the Script Executable**

```bash
chmod +x create_users.sh
```

3. **Run the Script**

```bash
sudo ./create_users.sh $(pwd)/users.txt
```

4. **Verify Logs and Passwords**

Check the log file:
```bash
sudo cat /var/log/user_management.log
```

Check the password file:
```bash
sudo cat /var/secure/user_passwords.csv
```

Verify user creation:
```bash
id light
id idimma
id mayowa
```

### Conclusion

This Bash script simplifies user and group creation on Ubuntu, ensuring consistency and security. This was a project for HNG cohort 11 .For more information on the HNG Internship program, visit (https://hng.tech/internship) and (https://hng.tech/premium).

By following this guide, you can streamline user management and enhance your system administration skills.
