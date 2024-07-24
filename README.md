# DevOpsFetch Documentation

## Overview

`devopsfetch` is a versatile tool designed to retrieve and display server information related to ports, Docker containers, Nginx configurations, user logins, and system activity logs. It is designed to work across multiple Linux distributions by detecting and using the appropriate package management commands. This tool can be run with various options to extract specific data or all available information at once.

## Features

- **Active Ports**: Display active ports and the services using them.
- **Docker Management**: List Docker images and containers, or show details about a specific container.
- **Nginx Configurations**: Display configured domains and details from Nginx configuration files.
- **User Logins**: Show last login times for users or details about a specific user.
- **System Activity Logs**: Display system activities within a specified time range or at a specific time.
- **Compatibility**: Works on various Linux distributions, including Ubuntu, CentOS, Fedora, Arch Linux, and SUSE.

## Installation

The installation script `install.sh` will check for necessary dependencies and install them if not present. It will also set up `devopsfetch` as a systemd service for regular execution.

### Installation Steps

1. **Download the Scripts:**
   - Obtain `devopsfetch.sh` and `install.sh`.

2. **Run the Installation Script:**

    ```bash
    sudo bash install.sh
    ```

   The script performs the following:

- Checks and installs required packages: `ss` (via `iproute2`), Docker, Nginx, and `logrotate`.
- Copies `devopsfetch.sh` to `/usr/local/bin` as `devopsfetch`.
- Sets up `devopsfetch` as a systemd service with logging enabled.
- Configures log rotation for `devopsfetch`.

## Usage

Run `devopsfetch` with various options to retrieve the desired information. Use the `--help` option to display a list of available commands and their usage.

### Command Options

```plaintext
    Usage: devopsfetch [OPTION]...
    Retrieve and show server information.

    Options:
        -p, --port [PORT]          Show active ports or info about a specific port
        -d, --docker [CONTAINER]   List Docker images/containers or info about a specific container
        -n, --nginx [DOMAIN]       Show Nginx domains or config for a specific domain
        -u, --users [USERNAME]     List users and last login times or info about a specific user
        -t, --time [START] [END]   Show activities within a specified time range
        -a, --all                  Show all information
        -h, --help                 Show this help message
```

### Examples

- **Show all active ports and services:**

    ```bash
    devopsfetch --port
    devopsfetch -p
    ```

- **Show detailed information about a specific port (e.g., port 80):**

    ```bash
    devopsfetch --port 80
    devopsfetch -p 80
    ```

- **List all Docker images and containers:**

    ```bash
    devopsfetch --docker
    devopsfetch -d
    ```

- **Show detailed information about a specific Docker container named `specific-container`:**

    ```bash
    devopsfetch --docker specific-container
    devopsfetch -d specific-container
    ```

- **Show all Nginx domains and their ports:**

    ```bash
    devopsfetch --nginx
    devopsfetch -n
    ```

- **Show detailed configuration for a specific domain (e.g., `example.com`):**

    ```bash
    devopsfetch --nginx example.com
    devopsfetch -n example.com
    ```

- **List all users and their last login times:**

    ```bash
    devopsfetch --users
    devopsfetch -u
    ```

- **Show detailed information about a specific user (e.g., `john`):**

    ```bash
    devopsfetch --users john
    devopsfetch -u john
    ```

- **Show activities that happened on the server between a specified time range:**

    ```bash
    devopsfetch --time "2024-07-18 12:00:00" "2024-07-18 15:00:00"
    devopsfetch -t "2024-07-18 12:00:00" "2024-07-18 15:00:00"
    ```

- **Show activities that happened on the server for a specified time:**

    ```bash
    devopsfetch --time "2024-07-18 12:00:00"
    devopsfetch -t "2024-07-18 12:00:00"
    ```

- **Show all available information at once:**

    ```bash
    devopsfetch --all
    devopsfetch -a
    ```

## System Requirements

- Linux distribution with `bash` shell
- Supported package manager (`apt-get`, `yum`, `dnf`, `pacman`, or `zypper`)
- Access to the internet for downloading dependencies
- Root privileges for installation

## Dependencies

The tool depends on the following packages:

- `iproute2`: Provides the `ss` command to show active ports.
- `docker`: Required to manage Docker images and containers.
- `nginx`: For displaying Nginx domains and configurations.
- `logrotate`: To handle log rotation for the service logs.

The installation script automatically handles the installation of these dependencies using the system's package manager.

## Logs and Debugging

- Logs for `devopsfetch` are stored in `/var/log/devopsfetch.log`.
- Log rotation is set up to keep logs manageable and prevent excessive disk usage.
- In case of issues, review the logs for errors and debug information.

## License

`devopsfetch` is released under the MIT License. You are free to use, modify, and distribute this software with attribution to the original author.

## Conclusion

`devopsfetch` is a powerful tool that simplifies the process of retrieving server information across various categories. By using this tool, you can quickly access details about active ports, Docker containers, Nginx configurations, user logins, and system activities. The tool is designed to be user-friendly and works seamlessly across different Linux distributions.
