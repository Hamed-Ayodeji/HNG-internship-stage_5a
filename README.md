# DevOpsFetch Tool

## Table of Contents

- [Introduction](#introduction)
- [Problems Solved](#problems-solved)
- [Key Features](#key-features)
- [Use Cases](#use-cases)
- [Uniqueness](#uniqueness)
- [Installation Prerequisites](#installation-prerequisites)
- [Installation Steps](#installation-steps)
- [Usage with Examples](#usage-with-examples)
- [Contribution](#contribution)
- [Conclusion](#conclusion)

## Introduction

**DevOpsFetch** is a powerful command-line tool designed to streamline system monitoring and management for DevOps professionals. It offers a centralized solution for gathering and displaying critical system information, such as active ports, Docker containers, Nginx configurations, and user activities. By addressing the complexities and time-consuming tasks associated with managing modern IT environments, DevOpsFetch simplifies data collection and presentation, making system management more efficient and less cumbersome.

### Problems Solved

- **Centralized Monitoring**: Consolidates multiple system monitoring tasks into a single tool, reducing the need for various commands and tools.
- **Data Clarity**: Organizes and formats system data for easy analysis, preventing data overload and making troubleshooting easier.
- **Time Efficiency**: Automates data retrieval, significantly reducing the time required for system checks and issue resolution.
- **Cross-Platform Consistency**: Adapts to different Linux distributions, ensuring consistent performance across various environments.

### Key Features

- **Port Monitoring**: Lists active ports and services, providing detailed information on specific ports when needed.
- **Docker Management**: Displays all Docker images and running containers, with in-depth insights into container status.
- **Nginx Configuration Display**: Lists Nginx domains and their configurations, or provides detailed configuration data for specific domains.
- **User Activity Tracking**: Lists all users with their last login times, offering detailed information on individual user activity.
- **Time-Based Logs**: Shows system activities within a specified time range, aiding in troubleshooting and audits.

### Use Cases

- **System Monitoring**: Regularly check services, ports, and user activities to ensure smooth operations.
- **Security Audits**: Quickly retrieve user logins and system logs for compliance and security auditing.
- **Troubleshooting**: Identify and resolve system issues efficiently with detailed logs and configuration data.
- **Configuration Management**: Validate consistent Nginx configurations across multiple servers.

### Uniqueness

DevOpsFetch stands out for its **simplicity**, **flexibility**, and **comprehensive coverage**. It integrates essential system monitoring tasks into a single tool, adapts to various Linux environments, and delivers clear, formatted outputs for easy interpretation. This makes DevOpsFetch an indispensable tool for DevOps professionals, saving time and enhancing system management efficiency.

---

## Installation Prerequisites

Before installing **DevOpsFetch**, ensure that your system meets the following prerequisites:

### 1. **Operating System**

- **Linux Distribution**: DevOpsFetch is compatible with various Linux distributions, including:
  - Ubuntu/Debian
  - CentOS/RHEL
  - Fedora
  - Arch Linux
  - openSUSE

### 2. **Administrative Access**

- **Root or Sudo Access**: You need root privileges or sudo access to install and configure DevOpsFetch, as the installation script requires the ability to install system packages and create service files.

### 3. **Network Connectivity**

- **Internet Access**: Required for downloading the necessary packages and updates during the installation process.

That’s all you need! The installation script will handle all other dependencies and setup tasks, allowing you to get started quickly and without hassle.

---

## Installation Steps

To install **DevOpsFetch** on your system, follow these steps:

### 1. **Clone the Repository**

Start by cloning the DevOpsFetch repository from GitHub:

```bash
git clone https://github.com/Hamed-Ayodeji/HNG-internship-stage_5a.git
```

Navigate into the cloned directory:

```bash
cd HNG-internship-stage_5a
```

### 2. **Run the Installation Script**

To install DevOpsFetch and its dependencies, execute the installation script provided in the repository. This script will automatically install the necessary packages and configure DevOpsFetch as a service:

```bash
sudo bash install_devopsfetch.sh
```

This script performs the following tasks:

- **Installs System Packages**: Installs `net-tools`, `docker`, `nginx`, `python3`, and `pip` based on your Linux distribution.
- **Installs Python Dependencies**: Installs the required Python packages, such as `tabulate`.
- **Copies DevOpsFetch Scripts**: Copies the `devopsfetch.sh` and `format_output.py` scripts to `/usr/local/bin` and makes them executable.
- **Configures and Starts the Systemd Service**: Sets up DevOpsFetch as a systemd service and starts it automatically.

### 3. **Verify Installation**

After the installation script completes, verify that DevOpsFetch is installed correctly by running:

```bash
devopsfetch --help
```

This command will display the usage information, confirming that DevOpsFetch is ready for use:

```bash
ubuntu@ip-12-0-0-11:~/HNG-internship-stage_5a$ devopsfetch --help
Usage: devopsfetch [OPTIONS]

DevOpsFetch is a versatile tool designed to fetch and display various system information. It can handle Docker containers, Nginx configurations, user logins, and much more.

Options:
  -p, --port [PORT_NUMBER]     Display all active ports and services, or detailed information about a specific port.
                               Example:
                               devopsfetch -p              # Lists all active ports and services
                               devopsfetch -p 80           # Displays detailed information about port 80

  -d, --docker [CONTAINER]     List all Docker images and containers, or detailed information about a specific container.
                               Example:
                               devopsfetch -d              # Lists all Docker images and containers
                               devopsfetch -d my_container # Displays details for 'my_container'

  -n, --nginx [DOMAIN]         Display Nginx domains and their ports, or detailed configuration for a specific domain.
                               Example:
                               devopsfetch -n              # Lists all Nginx domains and their ports
                               devopsfetch -n example.com  # Displays Nginx config for 'example.com'

  -u, --users [USERNAME]       List all users and their last login times, or detailed information about a specific user.
                               Example:
                               devopsfetch -u              # Lists all users and their last login times
                               devopsfetch -u john         # Displays last login details for user 'john'

  -t, --time START [END]       Display activities within a specified time range or at a specific time.
                               Example:
                               devopsfetch -t '2023-08-01 00:00:00' '2023-08-01 23:59:59'  # Displays activities within this range
                               devopsfetch -t '2023-08-01 12:00:00'  # Displays activities at the specific time

  -h, --help                   Show this help message and exit.

Config File:
  You can customize DevOpsFetch's behavior by creating a configuration file at /etc/devopsfetch.conf.
  Example configuration options:
  LOGFILE='/var/log/devopsfetch.log'
  TIME_FORMAT='%Y-%m-%d %H:%M:%S'
  LOG_LEVEL='INFO'
```

### 4. **Customization (Optional)**

You can customize DevOpsFetch's behavior by editing the configuration file located at `/etc/devopsfetch.conf`. Modify settings such as the log file location, time format, and log level to suit your needs.

By following these steps, DevOpsFetch will be installed, configured, and running on your system, ready to assist with your system monitoring and management tasks.

---

## Usage with Examples

After installation, you can use DevOpsFetch to gather various system information. Below are some common commands along with examples of their output.

### 1. **Listing All Active Ports and Services**

To list all active ports and the services running on them, use the `-p` option:

```bash
ubuntu@ip-12-0-0-11:~/HNG-internship-stage_5a$ devopsfetch -p
+--------+------------+-----------------+
| PORT   | PROTOCOL   | SERVICE         |
+========+============+=================+
| 22     | tcp        | sshd:           |
+--------+------------+-----------------+
| 53     | tcp        | systemd-resolve |
+--------+------------+-----------------+
| 80     | tcp        | nginx:          |
+--------+------------+-----------------+
| 32863  | tcp        | containerd      |
+--------+------------+-----------------+
| 323    | udp        | -               |
+--------+------------+-----------------+
| 53     | udp        | -               |
+--------+------------+-----------------+
| 68     | udp        | -               |
+--------+------------+-----------------+

Checks completed.
END TIME: Wed Aug 14 18:07:00 UTC 2024
```

### 2. **Displaying Information About a Specific Port**

To get detailed information about a specific port, provide the port number after the `-p` option:

```bash
ubuntu@ip-12-0-0-11:~/HNG-internship-stage_5a$ devopsfetch -p 80
+------------+--------+---------+-------+-----------+
| PROTOCOL   | PORT   | IP      | PID   | SERVICE   |
+============+========+=========+=======+===========+
| tcp        | 80     | 0.0.0.0 | 2713  | nginx:    |
+------------+--------+---------+-------+-----------+

Checks completed.
END TIME: Wed Aug 14 18:07:10 UTC 2024
```

If the specified

 port is not in use, DevOpsFetch will notify you:

```bash
ubuntu@ip-12-0-0-11:~/HNG-internship-stage_5a$ devopsfetch -p 8
No service is using the specified port.

Checks completed.
END TIME: Wed Aug 14 18:07:13 UTC 2024
```

### 3. **Listing Docker Images and Containers**

To view all Docker images and running containers on your system, use the `-d` option:

```bash
ubuntu@ip-12-0-0-11:~/HNG-internship-stage_5a$ devopsfetch -d
Docker Images:
+--------------+--------+--------------+--------+
| REPOSITORY   | TAG    | IMAGE ID     | SIZE   |
+==============+========+==============+========+
| httpd        | latest | a49fd2c04c02 | 148MB  |
+--------------+--------+--------------+--------+
| nginx        | latest | a72860cb95fd | 188MB  |
+--------------+--------+--------------+--------+
Docker Containers:
+------------------+---------+-------------+---------+
| NAMES            | IMAGE   | STATUS      | PORTS   |
+==================+=========+=============+=========+
| mystifying_kalam | nginx   | Up 10 hours | 80/tcp  |
+------------------+---------+-------------+---------+

Checks completed.
END TIME: Wed Aug 14 18:08:00 UTC 2024
```

### 4. **Getting Detailed Information About a Docker Container**

For detailed information on a specific Docker container, provide the container name after the `-d` option:

```bash
ubuntu@ip-12-0-0-11:~/HNG-internship-stage_5a$ devopsfetch -d mystifying_kalam
+-------------+------------------+
| ATTRIBUTE   | VALUE            |
+=============+==================+
| Name        | mystifying_kalam |
+-------------+------------------+
| Image       | nginx            |
+-------------+------------------+
| State       | running          |
+-------------+------------------+
| Ports       | 80/tcp           |
+-------------+------------------+

Checks completed.
END TIME: Wed Aug 14 18:08:12 UTC 2024
```

If the specified container is not running or does not exist, DevOpsFetch will inform you:

```bash
ubuntu@ip-12-0-0-11:~/HNG-internship-stage_5a$ devopsfetch -d flying_eagle
The Docker container 'flying_eagle' is not running or does not exist.

Checks completed.
END TIME: Wed Aug 14 18:08:35 UTC 2024
```

### 5. **Displaying Nginx Domains and Their Configurations**

To list all Nginx domains and their configurations, use the `-n` option:

```bash
ubuntu@ip-12-0-0-11:~/HNG-internship-stage_5a$ devopsfetch -n
+-----------------------+----------------------------+----------------------------------------+
| DOMAIN                | PROXY                      | CONFIGURATION FILE                     |
+=======================+============================+========================================+
| _                     | <No Proxy>                 | /etc/nginx/sites-available/default     |
+-----------------------+----------------------------+----------------------------------------+
| _                     | <No Proxy>                 | /etc/nginx/sites-available/test_config |
+-----------------------+----------------------------+----------------------------------------+
| api.example.com       | http://backend_api_server; | /etc/nginx/sites-available/test_config |
+-----------------------+----------------------------+----------------------------------------+
| example.com           | http://localhost:8080;     | /etc/nginx/sites-available/test_config |
+-----------------------+----------------------------+----------------------------------------+
| static.example.com    | <No Proxy>                 | /etc/nginx/sites-available/test_config |
+-----------------------+----------------------------+----------------------------------------+
| subdomain.example.com | <No Proxy>                 | /etc/nginx/sites-available/test_config |
+-----------------------+----------------------------+----------------------------------------+
| www.example.com       | http://localhost:8080;     | /etc/nginx/sites-available/test_config |
+-----------------------+----------------------------+----------------------------------------+

Checks completed.
END TIME: Wed Aug 14 18:11:07 UTC 2024
```

### 6. **Getting Detailed Information About a Specific Nginx Domain**

To display detailed configuration for a specific Nginx domain, provide the domain name after the `-n` option:

```bash
ubuntu@ip-12-0-0-11:~/HNG-internship-stage_5a$ devopsfetch -n www.example.com
+-----------------+------------------------+----------------------------------------+
| DOMAIN          | PROXY                  | CONFIGURATION FILE                     |
+=================+========================+========================================+
| www.example.com | http://localhost:8080; | /etc/nginx/sites-available/test_config |
+-----------------+------------------------+----------------------------------------+

Checks completed.
END TIME: Wed Aug 14 18:11:23 UTC 2024
```

If the specified domain is not found, DevOpsFetch will notify you:

```bash
ubuntu@ip-12-0-0-11:~/HNG-internship-stage_5a$ devopsfetch -n www.example.net
No configuration found for domain: www.example.net

Checks completed.
END TIME: Wed Aug 14 18:11:30 UTC 2024
```

### 7. **Listing All Users and Their Last Login Times**

To list all users on the system along with their last login times, use the `-u` option:

```bash
ubuntu@ip-12-0-0-11:~/HNG-internship-stage_5a$ devopsfetch -u
+----------------------+--------------------------+
| USERNAME             | LAST LOGIN               |
+======================+==========================+
| root                 | **Never logged in**      |
+----------------------+--------------------------+
| daemon               | **Never logged in**      |
+----------------------+--------------------------+
| bin                  | **Never logged in**      |
+----------------------+--------------------------+
...
| ubuntu               | Wed Aug 14 13:49:28 2024 |
+----------------------+--------------------------+
| lxd                  | **Never logged in**      |
+----------------------+--------------------------+
| dnsmasq              | **Never logged in**      |
+----------------------+--------------------------+
| ayo                  | **Never logged in**      |
+----------------------+--------------------------+

Checks completed.
END TIME: Wed Aug 14 18:12:19 UTC 2024
```

### 8. **Getting Detailed Information About a Specific User**

For detailed login information about a specific user, provide the username after the `-u` option:

```bash
ubuntu@ip-12-0-0-11:~/HNG-internship-stage_5a$ devopsfetch -u ayo
+------------+---------------------+
| USERNAME   | LAST LOGIN          |
+============+=====================+
| ayo        | **Never logged in** |
+------------+---------------------+

Checks completed.
END TIME: Wed Aug 14 18:12:35 UTC 2024
```

If no login record is found for the specified user, DevOpsFetch will inform you:

```bash
ubuntu@ip-12-0-0-11:~/HNG-internship-stage_5a$ devopsfetch -u temi
No login record found for user: temi

Checks completed.
END TIME: Wed Aug 14 18:12:42 UTC 2024
```

### 9. **Displaying System Activities Within a Specified Time Range**

To display system activities within a specific time range, use the `-t` option followed by the start and end times:

```bash
ubuntu@ip-12-0-0-11:~/HNG-internship-stage_5a$ devopsfetch -t '2024-08-14 15:00:00' '2024-08-14 15:15:00'

Displaying activities from 2024-08-14 15:00:00 to 2024-08-14 15:15:00:
Aug 14 15:01:04 ip-12-0-0-11 sudo[47376]:   ubuntu : TTY=pts/1 ; PWD=/home/ubuntu/HNG-internship-stage_5a ; USER=root ; COMMAND=./install_devopsfetch.sh
Aug 14 15:01:04 ip-12-0-0-11 sudo[47376]: pam_unix(sudo:session): session opened for user root(uid=0) by ubuntu(uid=1000)
...
Checks completed.
END TIME: Wed Aug 14 18:19:13 UTC 2024
```

### 10. **Displaying System Activities at a Specific Time**

To display system activities at a specific time, provide only the start time:

```bash
ubuntu@ip-12-0-0-11:~/HNG-internship-stage_5a$ devopsfetch -t '2024-08-14 15:01:04'

Displaying activities from 2024-08-14 15:01:04 to 2024-08-14 15:01:05:
Aug 14 15:01:04 ip-12-0-0-11 sudo[47376]:   ubuntu : TTY=pts/1 ; PWD=/home/ubuntu/HNG-internship-stage_

5a ; USER=root ; COMMAND=./install_devopsfetch.sh
Aug 14 15:01:04 ip-12-0-0-11 sudo[47376]: pam_unix(sudo:session): session opened for user root(uid=0) by ubuntu(uid=1000)
...
Checks completed.
END TIME: Wed Aug 14 18:19:13 UTC 2024
```

These examples show how DevOpsFetch can be used to gather detailed information about your system, whether you're checking active ports, managing Docker containers, monitoring Nginx configurations, tracking user logins, or reviewing system activities.

---

## Contribution

Contributions to **DevOpsFetch** are highly encouraged! Whether you want to enhance the codebase, add new features, fix bugs, or improve documentation, your input is valuable. Here’s how you can contribute:

1. **Fork the Repository**: Start by forking the [DevOpsFetch repository](https://github.com/Hamed-Ayodeji/HNG-internship-stage_5a.git) on GitHub.

2. **Clone Your Fork**: Clone your forked repository to your local machine for development.

   ```bash
   git clone https://github.com/your-username/HNG-internship-stage_5a.git
   ```

3. **Create a Branch**: Create a new branch for your feature, bug fix, or documentation update.

   ```bash
   git checkout -b my-new-feature
   ```

4. **Make Your Changes**: Implement your changes in your branch. Ensure your code is clean, well-documented, and adheres to the project's coding standards.

5. **Test Your Changes**: Thoroughly test your changes to ensure they work as expected and do not introduce any new issues.

6. **Commit and Push**: Commit your changes with a clear and concise message, then push your branch to your forked repository.

   ```bash
   git add .
   git commit -m "Add new feature: detailed port monitoring"
   git push origin my-new-feature
   ```

7. **Submit a Pull Request**: Navigate to the original repository on GitHub and submit a pull request from your branch. Provide a detailed description of your changes and why they should be merged.

8. **Review and Feedback**: The maintainers will review your pull request and may provide feedback or request changes. Collaborate with them to ensure your contribution is ready for merging.

9. **Stay Involved**: After your contribution is merged, stay involved in the community. You can help by reviewing other pull requests, reporting issues, or contributing to discussions.

By contributing to DevOpsFetch, you help improve a tool that benefits a broad community of DevOps professionals and system administrators. Your contributions not only enhance the tool but also demonstrate your commitment to collaborative, open-source development. Thank you for helping to make DevOpsFetch even better!

---

### Conclusion

**DevOpsFetch** is a robust and user-friendly tool that simplifies the management and monitoring of critical system components. By consolidating a wide range of system information—such as active ports, Docker containers, Nginx configurations, and user activities—into a single, easy-to-use interface, DevOpsFetch significantly reduces the time and effort required for these tasks.

Whether you're troubleshooting issues, conducting security audits, or maintaining your system's health, DevOpsFetch provides the detailed insights you need with just a few simple commands. Its versatility, combined with its ability to adapt to various Linux environments, makes it an indispensable tool for DevOps professionals, system administrators, and IT engineers alike.

By streamlining essential system tasks and offering clear, organized outputs, DevOpsFetch enhances your ability to maintain and optimize your infrastructure, ultimately contributing to more efficient and effective system management.

---
