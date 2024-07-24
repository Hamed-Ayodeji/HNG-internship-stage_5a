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

# Function to show active ports with IP addresses
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

# Function to show Docker images/containers
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

# Function to show Nginx domains and configurations
show_nginx() {
    local header="Nginx Domains"
    local data=""

    # Array of common Nginx configuration file locations
    config_paths=(
        "/etc/nginx/nginx.conf"
        "/etc/nginx/conf.d/"
        "/etc/nginx/sites-available/"
        "/etc/nginx/sites-enabled/"
        "/usr/local/nginx/conf/"
    )

    # Loop through each configuration path
    for path in "${config_paths[@]}"; do
        if [ -d "$path" ]; then
            # If the path is a directory, find all .conf files
            config_files=$(find "$path" -type f -name "*.conf")
        elif [ -f "$path" ]; then
            # If the path is a file, use it directly
            config_files="$path"
        fi

        # Extract server_name from each configuration file
        for config_file in $config_files; do
            # Extract server_name and format them
            while IFS= read -r line; do
                server_names=$(echo "$line" | awk '{print $2}' | sed 's/;//')
                if [ -n "$server_names" ]; then
                    data+="$server_names "
                fi
            done < <(awk '/server_name/ {print}' "$config_file")
        done
    done

    # Remove trailing space and show the formatted table
    data=$(echo "$data" | sed 's/ *$//')
    format_table "$header" "$data"
}

# Function to show user login information
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

# Function to display activities within a specified time range or a specific time
show_time() {
    local start_time="$1"
    local end_time="$2"
    local max_entries=20  # Limit the number of log entries displayed

    if [ -n "$start_time" ] && [ -n "$end_time" ]; then
        echo "Activities from $start_time to $end_time:"
    elif [ -n "$start_time" ]; then
        echo "Activities at $start_time:"
        # Define an end time slightly after the specific time to capture all activities at that timestamp
        end_time=$(date -d "$start_time + 1 minute" "+%Y-%m-%d %H:%M:%S")
    else
        echo "Error: Invalid arguments. Please specify a time range or a specific time."
        exit 1
    fi

    echo "======================================"

    # Fetch logs using journalctl
    local logs
    if [ -n "$end_time" ]; then
        logs=$(journalctl --since "$start_time" --until "$end_time" --no-pager)
    else
        logs=$(journalctl --since "$start_time" --no-pager)
    fi

    # Limit the output
    filtered_logs=$(echo "$logs" | tail -n "$max_entries")

    # Check if filtered logs are empty
    if [ -z "$filtered_logs" ]; then
        echo "No logs found for the specified time."
    else
        # Print header
        printf "%-20s | %s\n" "Timestamp" "Log Message"
        echo "--------------------------------------"

        # Print each log entry
        while IFS= read -r line; do
            # Extract the timestamp and the message
            local timestamp=$(echo "$line" | awk '{print $1" "$2}')
            local message=$(echo "$line" | cut -d ' ' -f 3-)

            # Print formatted line
            printf "%-20s | %s\n" "$timestamp" "$message"
        done <<< "$filtered_logs"
    fi

    echo "======================================"
}

# Help function
show_help() {
    cat <<EOF
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

Examples:
    devopsfetch --port                                                  Show all active ports and services
    devopsfetch -p
    
    devopsfetch --port 80                                               Show detailed information about a specific port (e.g., port 80)
    devopsfetch -p 80
    
    devopsfetch --docker                                                List all Docker images and containers
    devopsfetch -d
    
    devopsfetch --docker specific-container                             Show detailed information about a specific Docker container named specific-container
    devopsfetch -d specific-container
    
    devopsfetch --nginx                                                 Show all Nginx domains and their ports
    devopsfetch -n
    
    devopsfetch --nginx example.com                                     Show detailed configuration for a specific domain (e.g., example.com)
    devopsfetch -n example.com
    
    devopsfetch --users                                                 List all users and their last login times
    devopsfetch -u
    
    devopsfetch --users john                                            Show detailed information about a specific user (e.g., john)
    devopsfetch -u john
    
    devopsfetch --time "2024-07-18 12:00:00" "2024-07-18 15:00:00"      Show activities that happened on the server between the specified time range
    devopsfetch -t "2024-07-18 12:00:00" "2024-07-18 15:00:00"
    
    devopsfetch --time "2024-07-18 12:00:00"                            Show activities that happened on the server for the specified time
    devopsfetch -t "2024-07-18 12:00:00"

    devopsfetch --all                                                   Show all available information at once
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
                show_help
                exit 0
                ;;
            *)
                echo "Error: Invalid option $1"
                echo "Use --help to show the available options."
                exit 1
                ;;
        esac
        shift
    done

    # Check if no command was specified
    if [ -z "$command" ] && ! $all; then
        show_help
        exit 0
    fi

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
                echo "Use --help to show the available options."
                ;;
        esac
    fi
}

main "$@"
