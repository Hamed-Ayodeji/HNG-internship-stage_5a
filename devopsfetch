#!/bin/bash

# Global variables
CONFIG_FILE="/etc/devopsfetch.conf"
LOGFILE="/var/log/devopsfetch.log"
TIME_FORMAT="%Y-%m-%d %H:%M:%S"
NGINX_CONF_DIR="/etc/nginx"  # Default, will be overwritten based on distro
LOG_LEVEL="INFO"  # Default log level, can be overridden by config

# Load configuration file if it exists
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    printf "Configuration file not found. Using default settings.\n" >&2
fi

# Functions

# Log function with levels
log() {
    local level=$1
    local message=$2
    if [[ "$level" =~ ^(INFO|WARN|ERROR)$ ]]; then
        printf "[%s] [%s] %s\n" "$(date +"$TIME_FORMAT")" "$level" "$message" >> "$LOGFILE"
    else
        printf "[%s] [INFO] %s\n" "$(date +"$TIME_FORMAT")" "$message" >> "$LOGFILE"
    fi
}

# Function to determine the Nginx configuration directory based on the package manager
determine_nginx_conf_dir() {
    if command -v apt-get &> /dev/null; then
        NGINX_CONF_DIR="/etc/nginx/sites-available"
    elif command -v yum &> /dev/null || command -v dnf &> /dev/null; then
        NGINX_CONF_DIR="/etc/nginx/conf.d"
    elif command -v zypper &> /dev/null; then
        NGINX_CONF_DIR="/etc/nginx/vhosts.d"
    elif command -v pacman &> /dev/null; then
        NGINX_CONF_DIR="/etc/nginx/sites-available"
    else
        log "WARN" "Unsupported Linux distribution. Nginx configuration directory may vary."
        NGINX_CONF_DIR="/etc/nginx"
    fi
}

# Function to validate port numbers
validate_port() {
    if [[ ! $1 =~ ^[0-9]+$ || $1 -lt 1 || $1 -gt 65535 ]]; then
        log "ERROR" "Invalid port number: $1"
        return 1
    fi
    return 0
}

# Function to display help message with detailed explanations
display_help() {
    printf "Usage: devopsfetch [OPTIONS]\n\n"
    printf "DevOpsFetch is a versatile tool designed to fetch and display various system information. It can handle Docker containers, Nginx configurations, user logins, and much more.\n\n"
    printf "Options:\n"
    printf "  -p, --port [PORT_NUMBER]     Display all active ports and services, or detailed information about a specific port.\n"
    printf "                               Example:\n"
    printf "                               devopsfetch -p              # Lists all active ports and services\n"
    printf "                               devopsfetch -p 80           # Displays detailed information about port 80\n\n"
    printf "  -d, --docker [CONTAINER]     List all Docker images and containers, or detailed information about a specific container.\n"
    printf "                               Example:\n"
    printf "                               devopsfetch -d              # Lists all Docker images and containers\n"
    printf "                               devopsfetch -d my_container # Displays details for 'my_container'\n\n"
    printf "  -n, --nginx [DOMAIN]         Display Nginx domains and their ports, or detailed configuration for a specific domain.\n"
    printf "                               Example:\n"
    printf "                               devopsfetch -n              # Lists all Nginx domains and their ports\n"
    printf "                               devopsfetch -n example.com  # Displays Nginx config for 'example.com'\n\n"
    printf "  -u, --users [USERNAME]       List all users and their last login times, or detailed information about a specific user.\n"
    printf "                               Example:\n"
    printf "                               devopsfetch -u              # Lists all users and their last login times\n"
    printf "                               devopsfetch -u john         # Displays last login details for user 'john'\n\n"
    printf "  -t, --time START END         Display activities within a specified time range.\n"
    printf "                               Example:\n"
    printf "                               devopsfetch -t '2023-08-01 00:00:00' '2023-08-01 23:59:59'  # Displays activities within this range\n\n"
    printf "  -s, --specific TIME          Display activities at a specific time.\n"
    printf "                               Example:\n"
    printf "                               devopsfetch -s '2023-08-01 12:00:00'  # Displays activities at the specified time\n\n"
    printf "  -h, --help                   Show this help message and exit.\n\n"
    printf "Config File:\n"
    printf "  You can customize DevOpsFetch's behavior by creating a configuration file at /etc/devopsfetch.conf.\n"
    printf "  Example configuration options:\n"
    printf "  LOGFILE='/var/log/devopsfetch.log'\n"
    printf "  TIME_FORMAT='%Y-%m-%d %H:%M:%S'\n"
    printf "  LOG_LEVEL='INFO'\n"
    printf "\n"
}

# Function to list active ports and services
list_ports() {
    printf "%-15s %-10s %-10s\n" "Port" "Protocol" "Service"
    sudo netstat -tuln | awk 'NR>2 {split($4,a,":"); print a[2], $1, $7}' | column -t
}

# Function to provide detailed information about a specific port
port_info() {
    local port=$1
    validate_port "$port" || return 1
    printf "Details for port %s:\n" "${port}"
    sudo netstat -tulnp | grep ":${port}\b" | awk '{print "Protocol: "$1"\nAddress: "$4"\nPID/Program: "$7}'
}

# Function to list Docker images and containers
list_docker() {
    printf "\nDocker Images:\n"
    printf "%-30s %-10s %-15s %-10s\n" "Repository" "Tag" "Image ID" "Size"
    sudo docker images --format "{{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}" | column -t
    printf "\nDocker Containers:\n"
    printf "%-20s %-30s %-15s %-20s\n" "Name" "Image" "Status" "Ports"
    sudo docker ps --format "{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | column -t
}

# Function to provide detailed information about a specific Docker container
docker_info() {
    local container=$1
    printf "Details for Docker container %s:\n" "${container}"
    sudo docker inspect "${container}" | jq .
}

# Function to display Nginx domains and their ports
list_nginx() {
    printf "%-30s %-10s\n" "Domain" "Port"
    grep -rh "server_name" ${NGINX_CONF_DIR}/* | awk '{print $2}' | tr -d ';' | while read -r domain; do
        grep -rh "listen" ${NGINX_CONF_DIR}/* | awk '{print $2}' | tr -d ';' | while read -r port; do
            printf "%-30s %-10s\n" "$domain" "$port"
        done
    done
}

# Function to provide detailed configuration information for a specific Nginx domain
nginx_info() {
    local domain=$1
    printf "Configuration details for Nginx domain %s:\n" "${domain}"
    grep -r "server_name ${domain}" ${NGINX_CONF_DIR}/* | xargs grep -H -E 'listen|server_name|root|index'
}

# Function to list users and their last login times
list_users() {
    printf "%-20s %-20s %-30s\n" "Username" "Port" "Last Login"
    lastlog | grep -v "Never" | awk '{printf "%-20s %-20s %-30s\n", $1, $3, $4 " " $5 " " $6 " " $7}'
}

# Function to provide detailed information about a specific user
user_info() {
    local username=$1
    printf "Last login details for user %s:\n" "${username}"
    lastlog -u "${username}" | grep -v "Never" | awk '{printf "Username: %s\nPort: %s\nLast Login: %s %s %s %s\n", $1, $3, $4, $5, $6, $7}'
}

# Function to display activities within a specified time range
time_range() {
    local start_time=$1
    local end_time=$2
    journalctl --since="$start_time" --until="$end_time"
}

# Function to display activities at a specific time
specific_time() {
    local time=$1
    journalctl --since="$time" --until="$time +1s"
}

# Main execution function
main() {
    # Determine the correct Nginx configuration directory based on distro
    determine_nginx_conf_dir
    
    if [[ "$#" -eq 0 ]]; then
        display_help
        exit 0
    fi
    
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -p|--port)
                if [[ -z "$2" ]]; then
                    list_ports
                    log "INFO" "Listed all active ports and services"
                else
                    port_info "$2"
                    log "INFO" "Displayed information for port $2"
                    shift
                fi
                ;;
            -d|--docker)
                if [[ -z "$2" ]]; then
                    list_docker
                    log "INFO" "Listed all Docker images and containers"
                else
                    docker_info "$2"
                    log "INFO" "Displayed information for Docker container $2"
                    shift
                fi
                ;;
            -n|--nginx)
                if [[ -z "$2" ]]; then
                    list_nginx
                    log "INFO" "Listed all Nginx domains and their ports"
                else
                    nginx_info "$2"
                    log "INFO" "Displayed Nginx configuration for domain $2"
                    shift
                fi
                ;;
            -u|--users)
                if [[ -z "$2" ]]; then
                    list_users
                    log "INFO" "Listed all users and their last login times"
                else
                    user_info "$2"
                    log "INFO" "Displayed information for user $2"
                    shift
                fi
                ;;
            -t|--time)
                if [[ -n "$2" && -n "$3" ]]; then
                    time_range "$2" "$3"
                    log "INFO" "Displayed activities from $2 to $3"
                    shift 2
                else
                    log "ERROR" "Time range requires a start and end time."
                    printf "Error: Time range requires a start and end time.\n" >&2
                fi
                ;;
            -s|--specific)
                if [[ -n "$2" ]]; then
                    specific_time "$2"
                    log "INFO" "Displayed activities at $2"
                    shift
                else
                    log "ERROR" "Specific time requires a valid time input."
                    printf "Error: Specific time requires a valid time input.\n" >&2
                fi
                ;;
            -h|--help)
                display_help
                exit 0
                ;;
            *)
                log "ERROR" "Invalid option: $1"
                printf "Invalid option: %s\n" "$1" >&2
                display_help
                exit 1
                ;;
        esac
        shift
    done
}

# Execute main function with provided arguments
main "$@"
