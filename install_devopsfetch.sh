#!/bin/bash

# Ensure the script is run as root
if [[ "$(id -u)" -ne 0 ]]; then
    sudo -E "$0" "$@"
    exit
fi

# Global variables
LOGFILE="/var/log/devopsfetch.log"
LOGDIR=$(dirname "$LOGFILE")
LOGROTATE_CONF="/etc/logrotate.d/devopsfetch"
NGINX_CONF_DIR=""
TIME_FORMAT="%Y-%m-%d %H:%M:%S"
DEPENDENCIES=("net-tools" "jq" "docker" "nginx" "logrotate")

# Declare an associative array to handle different package names and Nginx configuration paths
declare -A DISTRO_PACKAGES
declare -A NGINX_CONF_PATHS

# Map package names and Nginx paths for different distros
DISTRO_PACKAGES=( 
    ["apt"]="net-tools jq docker.io nginx logrotate"
    ["yum"]="net-tools jq docker nginx logrotate"
    ["dnf"]="net-tools jq docker nginx logrotate"
    ["zypper"]="net-tools jq docker nginx logrotate"
    ["pacman"]="net-tools jq docker nginx logrotate"
)

NGINX_CONF_PATHS=(
    ["apt"]="/etc/nginx/sites-available"
    ["yum"]="/etc/nginx/conf.d"
    ["dnf"]="/etc/nginx/conf.d"
    ["zypper"]="/etc/nginx/vhosts.d"
    ["pacman"]="/etc/nginx/sites-available"
)

# Functions

# Function to detect package manager and install packages
install_packages() {
    local packages="$1"
    if command -v apt-get &> /dev/null; then
        apt-get update -y
        apt-get install -y $packages
    elif command -v yum &> /dev/null; then
        yum install -y $packages
    elif command -v dnf &> /dev/null; then
        dnf install -y $packages
    elif command -v zypper &> /dev/null; then
        zypper install -y $packages
    elif command -v pacman &> /dev/null; then
        pacman -Sy --noconfirm $packages
    else
        printf "Unsupported package manager. Please install dependencies manually.\n" >&2
        exit 1
    fi
}

# Function to determine the package manager and install the correct packages
check_and_install_dependencies() {
    if command -v apt-get &> /dev/null; then
        install_packages "${DISTRO_PACKAGES[apt]}"
        NGINX_CONF_DIR="${NGINX_CONF_PATHS[apt]}"
    elif command -v yum &> /dev/null; then
        install_packages "${DISTRO_PACKAGES[yum]}"
        NGINX_CONF_DIR="${NGINX_CONF_PATHS[yum]}"
    elif command -v dnf &> /dev/null; then
        install_packages "${DISTRO_PACKAGES[dnf]}"
        NGINX_CONF_DIR="${NGINX_CONF_PATHS[dnf]}"
    elif command -v zypper &> /dev/null; then
        install_packages "${DISTRO_PACKAGES[zypper]}"
        NGINX_CONF_DIR="${NGINX_CONF_PATHS[zypper]}"
    elif command -v pacman &> /dev/null; then
        install_packages "${DISTRO_PACKAGES[pacman]}"
        NGINX_CONF_DIR="${NGINX_CONF_PATHS[pacman]}"
    else
        printf "Unsupported Linux distribution. Please install dependencies manually.\n" >&2
        exit 1
    fi
}

# Function to ensure necessary directories and files exist
ensure_directories_and_files() {
    # Ensure log directory exists
    if [[ ! -d "$LOGDIR" ]]; then
        mkdir -p "$LOGDIR"
        chmod 755 "$LOGDIR"
    fi

    # Ensure log file exists
    if [[ ! -f "$LOGFILE" ]]; then
        touch "$LOGFILE"
        chmod 644 "$LOGFILE"
    fi

    # Ensure Nginx configuration directory exists
    if [[ ! -d "$NGINX_CONF_DIR" ]]; then
        printf "Nginx configuration directory not found: $NGINX_CONF_DIR\n" >&2
        exit 1
    fi
}

# Function to create default configuration file if it doesn't exist
create_default_config() {
    if [[ ! -f "/etc/devopsfetch.conf" ]]; then
        cat <<EOF > /etc/devopsfetch.conf
# DevOpsFetch Configuration File
LOGFILE='/var/log/devopsfetch.log'
TIME_FORMAT='%Y-%m-%d %H:%M:%S'
LOG_LEVEL='INFO'
EOF
        chmod 644 "/etc/devopsfetch.conf"
    fi
}

# Systemd service creation
setup_systemd_service() {
    cat <<EOF > /etc/systemd/system/devopsfetch.service
[Unit]
Description=DevOps Fetch Service
After=network.target

[Service]
ExecStart=/usr/local/bin/devopsfetch -p -d -n -u
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable devopsfetch
    systemctl start devopsfetch
}

# Log rotation configuration
setup_log_rotation() {
    cat <<EOF > $LOGROTATE_CONF
$LOGFILE {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 root root
}
EOF
}

# Ensure devopsfetch script is installed and add to PATH
install_script() {
    cp devopsfetch /usr/local/bin/devopsfetch
    chmod +x /usr/local/bin/devopsfetch
}

# Check and install dependencies, setup systemd service, and ensure necessary files and directories
check_and_install_dependencies
ensure_directories_and_files
install_script
create_default_config
setup_systemd_service
setup_log_rotation

printf "DevOpsFetch installation and setup completed.\n"
