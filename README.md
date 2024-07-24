# DevOpsFetch: Your All-in-One Server Information Tool

## Table of Contents

1. [Introduction](#introduction)
2. [What Makes DevOpsFetch Special?](#what-makes-devopsfetch-special)
3. [Installation](#installation)
4. [How to Use DevOpsFetch](#how-to-use-devopsfetch)
5. [Command Examples](#command-examples)
6. [Continuous Monitoring](#continuous-monitoring)
7. [Logging](#logging)
8. [Troubleshooting](#troubleshooting)
9. [Conclusion](#conclusion)

## Introduction

Imagine you're a chef in a bustling kitchen. You need to know what ingredients you have, what's cooking, and who's doing what. Now, picture your server as that kitchen. **DevOpsFetch** is like your trusty kitchen assistant, giving you all the important information about your server at your fingertips.

**DevOpsFetch** is a comprehensive tool designed for DevOps professionals and system administrators. It serves as a one-stop solution for gathering and monitoring critical server information, including active ports, Docker containers, Nginx configurations, user logins, and system activities.

## What Makes DevOpsFetch Special?

1. **Cross-Distribution Compatibility:** Works seamlessly across various Linux distributions, including Ubuntu, CentOS, Fedora, Arch Linux, and openSUSE. It automatically detects the package manager used by your system and installs the required tools accordingly.

2. **Unified Tool:** Consolidates functionality into a single command-line interface, simplifying the process of obtaining server information and making management easier.

3. **Readable Output:** Presents information in clean, organized tables, ensuring data is easy to interpret and understand.

4. **Continuous Monitoring:** Can run as a background service, continuously monitoring and reporting on server status without manual intervention.

5. **Efficient Logging:** Includes intelligent log management with automatic log rotation and compression to manage disk usage effectively.

## Installation

### Prerequisites

Before installing DevOpsFetch, ensure you have the following:

- Access to a terminal with superuser privileges.
- The `install.sh` and `devopsfetch.sh` scripts.

### Steps

1. **Download the Scripts:**
   - Ensure you have `install.sh` and `devopsfetch.sh` on your server.

2. **Make the Installation Script Executable:**

    ```bash
    chmod +x install.sh
    ```

3. **Run the Installation Script:**

    ```bash
    sudo ./install.sh
    ```

The `install.sh` script performs the following:

- **Dependency Check and Installation:** Detects your Linux distribution, installs necessary tools, and handles package management.
- **Script Deployment:** Copies `devopsfetch.sh` to `/usr/local/bin` for global access.
- **Service Configuration:** Sets up a systemd service to run DevOpsFetch as a background process.
- **Log Rotation Setup:** Configures log rotation to manage log files and prevent excessive disk space usage.

## How to Use DevOpsFetch

Using DevOpsFetch is straightforward. Execute the `devopsfetch` command followed by the desired option. Here are the available options:

- `-p` or `--port`: Displays information about active ports.
- `-d` or `--docker`: Provides details about Docker images and containers.
- `-n` or `--nginx`: Shows Nginx configurations and domains.
- `-u` or `--users`: Lists users and their last login times.
- `-t` or `--time`: Shows system activities within a specific time range.
- `-a` or `--all`: Displays all available information.
- `-h` or `--help`: Provides help information and usage instructions.

## Command Examples

Here are practical examples of how to use DevOpsFetch:

1. **To list all active ports:**

    ```bash
    devopsfetch --port
    ```

2. **To get information about port 80 (commonly used for web servers):**

    ```bash
    devopsfetch --port 80
    ```

3. **To view all Docker containers and images:**

    ```bash
    devopsfetch --docker
    ```

4. **To get details about a specific Docker container named "my-web-app":**

    ```bash
    devopsfetch --docker my-web-app
    ```

5. **To list all Nginx domains:**

    ```bash
    devopsfetch --nginx
    ```

6. **To view configuration for a specific Nginx domain like "example.com":**

    ```bash
    devopsfetch --nginx example.com
    ```

7. **To list all users and their last login times:**

    ```bash
    devopsfetch --users
    ```

8. **To get information about a specific user named "john":**

    ```bash
    devopsfetch --users john
    ```

9. **To view activities that occurred on July 18, 2024, between noon and 3 PM:**

    ```bash
    devopsfetch --time "2024-07-18 12:00:00" "2024-07-18 15:00:00"
    ```

10. **To display all available information at once:**

    ```bash
    devopsfetch --all
    ```

## Continuous Monitoring

DevOpsFetch can be set up to run continuously as a background service. This ensures ongoing monitoring and reporting of your server’s status.

- **Check if DevOpsFetch is running:**

    ```bash
    sudo systemctl status devopsfetch
    ```

- **Start the DevOpsFetch service:**

    ```bash
    sudo systemctl start devopsfetch
    ```

- **Stop the DevOpsFetch service:**

    ```bash
    sudo systemctl stop devopsfetch
    ```

## Logging

DevOpsFetch maintains a log of its operations, stored at `/tmp/devopsfetch_service.log`. The logging system features:

- **File Rotation:** Each log file is capped at 100MB. Older logs are compressed to save space.
- **Retention:** Logs are retained for the past 7 days.

To view the current log:

  ```bash
  cat /tmp/devopsfetch_service.log
  ```

## Troubleshooting

If you encounter issues with DevOpsFetch, follow these troubleshooting steps:

1. **Verify the Service Status:**

    ```bash
    sudo systemctl status devopsfetch
    ```

2. **Check Service Logs:**

    ```bash
    journalctl -u devopsfetch
    ```

3. **Confirm Required Tools Are Installed:**

    ```bash
    which ss docker nginx logrotate
    ```

4. **Ensure the Script is Deployed Correctly and is Executable:**

    ```bash
    ls -l /usr/local/bin/devopsfetch
    ```

If problems persist, consider reinstalling DevOpsFetch or checking for any error messages that appeared during installation.

## Conclusion

**DevOpsFetch** is a robust tool that simplifies server management by consolidating various monitoring and information-gathering functions into a single interface. Its compatibility with multiple Linux distributions, user-friendly output, continuous monitoring capabilities, and efficient logging make it an essential tool for DevOps professionals and system administrators.

Whether you're troubleshooting issues, monitoring system health, or conducting routine checks, DevOpsFetch streamlines the process and provides valuable insights into your server's performance and status.

For further assistance or questions, refer to the troubleshooting section or reach out for support.
