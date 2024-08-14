import sys
import argparse
from tabulate import tabulate

# Function to format and display the list of active ports and their services.
def format_ports_list(data):
    headers = ["PORT", "PROTOCOL", "SERVICE"]
    rows = [line.split() for line in data.strip().split('\n')]
    print(tabulate(rows, headers, tablefmt="grid", colalign=("left", "left", "left")))

# Function to format and display detailed information about a specific port.
def format_port_info(data):
    headers = ["PROTOCOL", "PORT", "IP", "PID", "SERVICE"]
    rows = [line.split() for line in data.strip().split('\n')]
    if rows:
        print(tabulate(rows, headers, tablefmt="grid", colalign=("left", "left", "left", "left", "left")))
    else:
        print("No service is using the specified port.")

# Function to format and display the list of Docker images.
def format_docker_images(data):
    headers = ["REPOSITORY", "TAG", "IMAGE ID", "SIZE"]
    rows = [line.split('\t') for line in data.strip().split('\n')]
    if rows:
        print(tabulate(rows, headers, tablefmt="grid", colalign=("left", "left", "left", "left")))
    else:
        print("No Docker images found.")

# Function to format and display the list of Docker containers.
def format_docker_containers(data):
    headers = ["NAMES", "IMAGE", "STATUS", "PORTS"]
    rows = [line.split('\t') for line in data.strip().split('\n')]
    if rows:
        print(tabulate(rows, headers, tablefmt="grid", colalign=("left", "left", "left", "left")))
    else:
        print("No running Docker containers found.")

# Function to format and display detailed information about a specific Docker container.
def format_docker_info(data):
    headers = ["ATTRIBUTE", "VALUE"]
    rows = [line.split('\t') for line in data.strip().split('\n')]
    if rows:
        print(tabulate(rows, headers, tablefmt="grid", colalign=("left", "left")))
    else:
        print("No details found for the specified Docker container.")

# Function to format and display the list of users and their last login times.
def format_users(data):
    headers = ["USERNAME", "LAST LOGIN"]
    rows = [line.split('\t', 1) for line in data.strip().split('\n')]
    if rows:
        print(tabulate(rows, headers, tablefmt="grid", colalign=("left", "left")))
    else:
        print("No users with login records found.")

# Function to format and display the list of Nginx domains and their configuration files.
def format_nginx_domains(data):
    headers = ["DOMAIN", "PROXY", "CONFIGURATION FILE"]
    rows = [line.split('\t') for line in data.strip().split('\n')]
    filtered_rows = [row for row in rows if len(row) == 3]
    if filtered_rows:
        print(tabulate(filtered_rows, headers, tablefmt="grid", colalign=("left", "left", "left")))
    else:
        print("No Nginx domains found.")

# Main function to handle command-line arguments and call the appropriate formatting function.
def main():
    parser = argparse.ArgumentParser(description="Format and display the output of devopsfetch.sh")
    parser.add_argument("type", choices=["ports", "port_info", "docker_images", "docker_containers", "docker_info", "nginx", "users"],
                        help="Type of output to format")
    parser.add_argument("file", nargs="?", type=argparse.FileType('r'),
                        help="File containing the raw output from devopsfetch.sh")

    args = parser.parse_args()

    # Read data from file or stdin.
    data = args.file.read() if args.file else sys.stdin.read()

    # Call the appropriate formatting function based on the command-line argument.
    if args.type == "ports":
        format_ports_list(data)
    elif args.type == "port_info":
        format_port_info(data)
    elif args.type == "docker_images":
        format_docker_images(data)
    elif args.type == "docker_containers":
        format_docker_containers(data)
    elif args.type == "docker_info":
        format_docker_info(data)
    elif args.type == "nginx":
        format_nginx_domains(data)
    elif args.type == "users":
        format_users(data)

# Execute the main function.
if __name__ == "__main__":
    main()
