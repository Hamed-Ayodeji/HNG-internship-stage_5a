#!/bin/bash

# Function to format output in a table with borders
format_table() {
    local header="$1"
    local data="$2"
    local separator="===================================================="
    echo "$separator"
    echo "$header"
    echo "$separator"
    echo "$data" | column -t -s ' '
    echo "$separator"
}

# Function to display active ports with IP addresses
show_ports() {
    if [ -z "$1" ]; then
        local ports=$(ss -tuln | awk 'NR>1 {print $5 " " $1}' |
            awk -F: '{print $1 " " $2 " " $3}' |
            awk '{print $2, $1, $3}' | sed '/^\s*$/d')
        format_table "Active Ports and Services" "$ports"
    else
        if ! ss -tuln | grep -q "$1"; then
            echo "Error: Port $1 is not in use or does not exist."
            echo "Please ensure the port number is correct and try again."
            return
        fi
        local port_info=$(ss -tuln | grep "$1" |
            awk '{print $5 " " $1}' |
            awk -F: '{print $1 " " $2 " " $3}' |
            awk '{print $2, $1, $3}' | sed '/^\s*$/d')
        format_table "Port $1 Information" "$port_info"
    fi
}

# Function to display Docker images/containers
show_docker() {
    if [ -z "$1" ]; then
        local images=$(docker images --format "table {{.Repository}}  {{.Tag}}  {{.ID}}" |
            awk 'NR>1 {print $1, $2, $3}')
        local containers=$(docker ps --format "table {{.Names}}  {{.Image}}  {{.Status}}" |
            awk 'NR>1 {print $1, $2, $3}')
        format_table "Docker Images" "$images"
        format_table "Docker Containers" "$containers"
    else
        if ! docker inspect "$1" &>/dev/null; then
            echo "Error: Docker container $1 does not exist or is not running."
            echo "Please check the container name and try again."
            return
        fi
        local container_info=$(docker inspect "$1" --format "ID: {{.Id}}\nImage: {{.Config.Image}}\nStatus: {{.State.Status}}" |
            awk -F': ' '{print $2}' | awk '{printf "%s\n", $0}')
        format_table "Container $1 Information" "$container_info"
    fi
}

# Function to display Nginx domains and configurations
show_nginx() {
    if [ -z "$1" ]; then
        local domains=$(grep -R 'server_name' /etc/nginx/sites-enabled/ |
            awk '{print $2}' | sort | uniq)
        format_table "Nginx Domains" "$domains"
    else
        if ! grep -q "server_name $1;" /etc/nginx/sites-enabled/; then
            echo "Error: Nginx domain $1 is not configured."
            echo "Please verify the domain name and ensure it is correctly configured."
            return
        fi
        local config=$(grep -R "server_name $1;" /etc/nginx/sites-enabled/ -A 10 |
            sed 's/^[[:space:]]*//')
        format_table "Nginx Config for $1" "$config"
    fi
}

# Function to display user login information
show_users() {
    if [ -z "$1" ]; then
        local users=$(lastlog | awk 'NR>1 {print $1 " " $3 " " $4 " " $5}')
        format_table "Users and Last Login Times" "$users"
    else
        if ! lastlog -u "$1" | grep -q "$1"; then
            echo "Error: User $1 does not exist or has no login records."
            echo "Please check the username and try again."
            return
        fi
        local user_info=$(lastlog -u "$1" | awk 'NR>1 {print $1 " " $3 " " $4 " " $5}')
        format_table "User $1 Information" "$user_info"
    fi
}

# Function to display activities within a time range
show_time() {
    local start_date="$1"
    local end_date="$2"
    if [ -z "$start_date" ] || [ -z "$end_date" ]; then
        echo "Error: Both start and end dates are required for time range."
        echo "Usage: devopsfetch -t [START_DATE] [END_DATE]"
        return
    fi
    local activities=$(grep -E "^($start_date|$end_date)" /var/log/syslog |
        awk '{print $1, $2, $3, $5}' | sort)
    format_table "Activities from $start_date to $end_date" "$activities"
}

# Help function
display_help() {
    cat <<EOF
Usage: devopsfetch [OPTION]...
Retrieve and display server information.

Options:
  -p, --port [PORT]          Display active ports or info about a specific port
  -d, --docker [CONTAINER]   List Docker images/containers or info about a specific container
  -n, --nginx [DOMAIN]       Display Nginx domains or config for a specific domain
  -u, --users [USERNAME]     List users and last login times or info about a specific user
  -t, --time [START] [END]   Display activities within a specified time range
  -a, --all                  Display all information
  -h, --help                 Display this help message

Examples:
  devopsfetch --port                          Display all active ports and services
  devopsfetch -p

  devopsfetch --port 80                       Display detailed information about a specific port (e.g., port 80)
  devopsfetch -p 80

  devopsfetch --docker                        List all Docker images and containers
  devopsfetch -d

  devopsfetch --docker specific-container     Display detailed information about a specific Docker container named specific-container
  devopsfetch -d specific-container

  devopsfetch --nginx                         Display all Nginx domains and their ports
  devopsfetch -n

  devopsfetch --nginx example.com             Display detailed configuration for a specific domain (e.g., example.com)
  devopsfetch -n example.com

  devopsfetch --users                         List all users and their last login times
  devopsfetch -u

  devopsfetch --users john                    Display detailed information about a specific user (e.g., john)
  devopsfetch -u john

  devopsfetch --time 2024-07-18 2024-07-22    Display activities on the server from 2024-07-18 to 2024-07-22
  devopsfetch -t 2024-07-18 2024-07-22

  devopsfetch --time 2024-07-21               Display all activities that happened on the server on 2024-07-21
  devopsfetch -t 2024-07-21

  devopsfetch --all                           Display all available information at once
  devopsfetch -a
EOF
}

# Main function
main() {
    case "$1" in
        -h|--help)
            display_help
            ;;
        -p|--port)
            show_ports "$2"
            ;;
        -d|--docker)
            show_docker "$2"
            ;;
        -n|--nginx)
            show_nginx "$2"
            ;;
        -u|--users)
            show_users "$2"
            ;;
        -t|--time)
            show_time "$2" "$3"
            ;;
        -a|--all)
            show_ports
            show_docker
            show_nginx
            show_users
            show_time "$(date --date='-1 week' +%Y-%m-%d)" "$(date +%Y-%m-%d)"
            ;;
        *)
            echo "Error: Invalid option or missing argument."
            echo "Use '-h' or '--help' to see the usage instructions."
            ;;
    esac
}

main "$@"
