# User Management Script for Linux

## Description

This script, `create_users.sh`, automates the process of creating Linux users and groups based on input from a text file. It is designed to streamline user management tasks, such as setting up home directories, generating secure passwords, and logging actions for auditing purposes. The script also ensures proper error handling for common issues like attempting to create an already existing user or group.

## Features

- Reads usernames and group memberships from a text file.
- Creates a personal group for each user with the same name as the username.
- Adds users to their personal group and any additional groups specified.
- Sets up home directories with appropriate permissions and ownership.
- Generates secure passwords for each user.
- Logs all actions to `/var/log/user_management.log`.
- Stores generated passwords securely in `/var/secure/user_passwords.txt`.

## Usage

1. Save the script as `create_users.sh` in your preferred directory.
2. Prepare a text file (`users_and_groups.txt`) with one username per line, followed by groups separated by commas. For example:  light;sudo,dev,www-data idimma;sudo mayowa;dev,www-data


3. Make the script executable with `chmod +x create_users.sh`.
4. Run the script with the path to your text file as an argument: `./create_users.sh users_and_groups.txt`.

## Dependencies

- Bash shell environment.
- Text editor for editing the script and preparing the input file.

## Technical Article

For a detailed explanation of the script's functionality, design choices, and the rationale behind each step, refer to our [technical article](#). This article provides insights into the scripting process, focusing on automation, security, and efficient user management.

## Links to HNG Internship Websites

- [HNG Internship Website](https://hng.tech/internship)
- [HNG Hire](https://hng.tech/hire)
- [HNG Premium](https://hng.tech/premium)

## License

This project is licensed under the MIT License. See the LICENSE file for details.
