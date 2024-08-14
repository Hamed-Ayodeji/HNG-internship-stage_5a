#!/bin/bash

# Ensure the script is run as root
if [[ "$(id -u)" -ne 0 ]]; then
    sudo -E "$0" "$@"
    exit
fi

# Path to the Python formatting script
PYTHON_FORMATTER="/usr/local/bin/format_output.py"

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
    printf "  TIME_FORMAT='%%Y-%%m-%%d %%H:%%M:%%S'\n"
    printf "  LOG_LEVEL='INFO'\n"
    printf "\n"
}

# Function to list active ports and services
list_ports() {
    netstat -tulnp | awk 'NR>2 && $1 != "tcp6" && $1 != "udp6" {
        split($4, a, ":");
        split($7, proc, "/");
        port = (a[2] ? a[2] : "-");
        service = (proc[2] ? proc[2] : "-");
        printf "%s %s %s\n", port, $1, service;
    }' | python3 "$PYTHON_FORMATTER" ports
}

# Function to provide detailed information about a specific port
port_info() {
    local port=$1
    validate_port "$port" || return 1

    # Capture the netstat output
    local output
    output=$(netstat -tulnp | grep ":${port}\b" | awk '$1 != "tcp6" && $1 != "udp6" {
        split($7, proc, "/");
        split($4, addr, ":");
        ip = (addr[1] ? addr[1] : "-");
        pid = (proc[1] ? proc[1] : "-");
        service = (proc[2] ? proc[2] : "-");
        printf "%s %s %s %s %s\n", $1, addr[2], ip, pid, service;
    }')

    # Check if output is empty
    if [[ -z "$output" ]]; then
        printf "No service is using the specified port.\n"
    else
        printf "%s\n" "$output" | python3 "$PYTHON_FORMATTER" port_info
    fi
}

# Function to list Docker images
display_docker_images() {
    local images_output
    images_output=$(docker images --format "{{.Repository}} {{.Tag}} {{.ID}} {{.Size}}" | awk '{printf "%s\t%s\t%s\t%s\n", $1, $2, $3, $4}')

    if [[ -z "$images_output" ]]; then
        printf "No Docker images found.\n"
    else
        printf "Docker Images:\n"
        printf "%s\n" "$images_output" | python3 "$PYTHON_FORMATTER" docker_images
    fi
}

# Function to list Docker containers
display_docker_containers() {
    local containers_output

    containers_output=$(docker ps --format "{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}")

    if [[ -z "$containers_output" ]]; then
        printf "No running Docker containers found.\n"
    else
        printf "Docker Containers:\n"
        echo "$containers_output" | awk -F'\t' '{ printf "%s\t%s\t%s\t%s\n", $1, $2, $3, ($4 ? $4 : "None") }' | python3 "$PYTHON_FORMATTER" docker_containers
    fi
}

# Function to provide detailed information about a specific Docker container
docker_info() {
    local container_name=$1
    local container_details
    local container_state

    # Check if the container exists and is running
    container_state=$(docker inspect --format="{{.State.Status}}" "$container_name" 2>/dev/null)

    if [[ "$container_state" != "running" ]]; then
        printf "The Docker container '%s' is not running or does not exist.\n" "$container_name"
        return
    fi

    # If the container is running, gather details
    container_details=$(docker inspect "$container_name" 2>/dev/null | jq -r '.[0] | {
        "Name": (.Name | ltrimstr("/")),
        "Image": .Config.Image,
        "State": .State.Status,
        "Ports": (if (.NetworkSettings.Ports | length) > 0 then (.NetworkSettings.Ports | to_entries | map(.key) | join(", ")) else "None" end)
    } | to_entries | map([.key, .value]) | .[] | @tsv')

    echo "$container_details" | awk '{printf "%s\t%s\n", $1, $2}' | python3 "$PYTHON_FORMATTER" docker_info
}

# Function to display Nginx domains and their ports
display_nginx_domains() {
    find "$NGINX_CONF_DIR" -type f ! -name "*.bak" -exec grep -H "server_name" {} \; | awk '!/^#/ && $0 != ""' | while read -r line; do
        file=$(echo "$line" | awk -F: '{print $1}')
        domains=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/server_name //; s/;$//')
        proxy=$(grep -m1 "proxy_pass" "$file" | awk '!/^#/ && $0 != "" {print $2}')
        [[ -z "$proxy" ]] && proxy="<No Proxy>"
        for domain in $domains; do
            printf "%s\t%s\t%s\n" "$domain" "$proxy" "$file"
        done
    done | sort | uniq | python3 "$PYTHON_FORMATTER" nginx
}

# Function to provide detailed information about a specific Nginx domain
nginx_info() {
    local domain_name=$1
    local config_files
    local found=false
    local output=""

    # Find all configuration files containing the specified domain
    config_files=$(grep -irl "server_name.*$domain_name" "$NGINX_CONF_DIR")

    if [[ -z "$config_files" ]]; then
        printf "No configuration found for domain: %s\n" "$domain_name"
        return
    fi

    # Loop through each file to gather relevant information
    for config_file in $config_files; do
        grep -E "server_name|proxy_pass" "$config_file" | awk -v domain="$domain_name" -v file="$config_file" '
        BEGIN { proxy="<No Proxy>"; domain_found=0 }
        !/^#/ && $0 != "" {
            if ($1 == "server_name" && index($0, domain) > 0) {
                domain_found=1
            }
            if (domain_found && $1 == "proxy_pass") {
                proxy = $2
            }
        }
        END {
            if (domain_found) {
                printf "%s\t%s\t%s\n", domain, proxy, file
            }
        }' >> output.txt
    done

    # If output.txt is not empty, print the contents and format them
    if [[ -s output.txt ]]; then
        cat output.txt | python3 "$PYTHON_FORMATTER" nginx
        rm -f output.txt
    else
        printf "No configuration found for domain: %s\n" "$domain_name"
        rm -f output.txt
    fi
}

# Function to list users and their last login times
list_users() {
    local users_output
    users_output=$(lastlog | awk 'NR>1 {if ($2 == "**Never") printf "%s\t**Never logged in**\n", $1; else printf "%s\t%s %s %s %s %s\n", $1, $4, $5, $6, $7, $9}')

    if [[ -z "$users_output" ]]; then
        printf "No users found.\n"
    else
        printf "%s\n" "$users_output" | python3 "$PYTHON_FORMATTER" users
    fi
}

# Function to provide detailed information about a specific user
user_info() {
    local username=$1
    local user_output

    user_output=$(lastlog | awk -v user="$username" '$1 == user {if ($2 == "**Never") printf "%s\t**Never logged in**\n", $1; else printf "%s\t%s %s %s %s %s\n", $1, $4, $5, $6, $7, $9}')

    if [[ -z "$user_output" ]]; then
        printf "No login record found for user: %s\n" "$username"
    else
        printf "%s\n" "$user_output" | python3 "$PYTHON_FORMATTER" users
    fi
}

# Function to display activities within a specified time range
time_range() {
    local start_time=$1
    local end_time=$2
    printf "\nDisplaying activities from %s to %s:\n" "$start_time" "$end_time"
    journalctl --since="$start_time" --until="$end_time"
    printf "\n"
}

# Function to display activities at a specific time
specific_time() {
    local time=$1
    printf "\nDisplaying activities at %s:\n" "$time"
    journalctl --since="$time" --until="$time +1 second"
    printf "\n"
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
                    display_docker_images
                    display_docker_containers
                    log "INFO" "Listed all Docker images and containers"
                else
                    docker_info "$2"
                    log "INFO" "Displayed information for Docker container $2"
                    shift
                fi
                ;;
            -n|--nginx)
                if [[ -z "$2" ]]; then
                    display_nginx_domains
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

    # End of execution message
    printf "\n%s\n" "Checks completed."
    printf "END TIME: $(date '+%a %b %d %T %Z %Y')\n"
    printf "\n"
}

# Execute main function with provided arguments
main "$@"
