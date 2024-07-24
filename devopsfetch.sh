#!/bin/bash

# Function to format output in a simple table
format_table() {
    local header="$1"
    local data="$2"
    local separator="======================================"
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
        if [ -z "$ports" ]; then
            echo "No active ports found."
        else
            format_table "Active Ports and Services" "$ports"
        fi
    else
        if ! ss -tuln | grep -q ":$1 "; then
            echo "Error: Port $1 is not in use or does not exist."
            echo "Please ensure the port number is correct and try again."
            return
        fi
        local port_info=$(ss -tuln | grep ":$1 " |
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
        if [ -z "$images" ]; then
            echo "No Docker images found."
        else
            format_table "Docker Images" "$images"
        fi
        if [ -z "$containers" ]; then
            echo "No Docker containers running."
        else
            format_table "Docker Containers" "$containers"
        fi
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
        local domains=$(grep -R 'server_name' /etc/nginx/sites-enabled/ 2>/dev/null |
            awk '{print $2}' | sort | uniq)
        if [ -z "$domains" ]; then
            echo "No Nginx domains found."
        else
            format_table "Nginx Domains" "$domains"
        fi
    else
        local config=$(grep -R "server_name $1;" /etc/nginx/sites-enabled/ -A 10 2>/dev/null |
            sed 's/^[[:space:]]*//')
        if [ -z "$config" ]; then
            echo "Error: Nginx domain $1 is not configured."
            echo "Please verify the domain name and ensure it is correctly configured."
            return
        fi
        format_table "Nginx Config for $1" "$config"
    fi
}

# Function to display user login information
show_users() {
    if [ -z "$1" ]; then
        local users=$(lastlog | awk 'NR>1 {print $1 " " $3 " " $4 " " $5}')
        if [ -z "$users" ]; then
            echo "No user login information found."
        else
            format_table "Users and Last Login Times" "$users"
        fi
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

    # Handle single date input by setting end_date as the same as start_date
    if [ -z "$end_date" ]; then
        end_date="$start_date"
    fi

    # Search within the time range or specific date
    local activities=$(awk -v start="$start_date" -v end="$end_date" '
        BEGIN {
            split(start, sdate, "-");
            split(end, edate, "-");
            s = mktime(sdate[1] " " sdate[2] " " sdate[3] " 00 00 00");
            e = mktime(edate[1] " " edate[2] " " edate[3] " 23 59 59");
        }
        {
            split($1, date, "-");
            t = mktime(date[1] " " date[2] " " date[3] " 00 00 00");
            if (t >= s && t <= e) {
                print $0;
            }
        }
    ' /var/log/syslog 2>/dev/null)

    if [ -z "$activities" ]; then
        echo "No activities found in the specified time range."
    else
        format_table "Activities from $start_date to $end_date" "$activities"
    fi
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
    local all=false
    local command=""

    while [ $# -gt 0 ]; do
        case "$1" in
            -p | --port)
                command="ports"
                shift
                port="$1"
                ;;
            -d | --docker)
                command="docker"
                shift
                container="$1"
                ;;
            -n | --nginx)
                command="nginx"
                shift
                domain="$1"
                ;;
            -u | --users)
                command="users"
                shift
                user="$1"
                ;;
            -t | --time)
                command="time"
                shift
                start="$1"
                end="$2"
                shift
                ;;
            -a | --all)
                all=true
                ;;
            -h | --help)
                display_help
                exit 0
                ;;
            *)
                echo "Error: Invalid option $1"
                echo "Use --help to display the available options."
                exit 1
                ;;
        esac
        shift
    done

    if $all; then
        echo "Gathering all information..."
        show_ports
        show_docker
        show_nginx
        show_users
        show_time "$(date +%Y-%m-%d)"
    else
        case "$command" in
            ports)
                show_ports "$port"
                ;;
            docker)
                show_docker "$container"
                ;;
            nginx)
                show_nginx "$domain"
                ;;
            users)
                show_users "$user"
                ;;
            time)
                show_time "$start" "$end"
                ;;
            *)
                echo "Error: No valid command provided."
                echo "Use --help to display the available options."
                ;;
        esac
    fi
}

main "$@"
