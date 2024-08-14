import sys
import argparse
from tabulate import tabulate

def format_ports_list(data):
    headers = ["PORT", "PROTOCOL", "SERVICE"]
    rows = [line.split() for line in data.strip().split('\n')]
    print(tabulate(rows, headers, tablefmt="grid", colalign=("left", "left", "left")))

def format_port_info(data):
    headers = ["PROTOCOL", "PORT", "IP", "PID", "SERVICE"]
    rows = [line.split() for line in data.strip().split('\n')]
    if rows:
        print(tabulate(rows, headers, tablefmt="grid", colalign=("left", "left", "left", "left", "left")))
    else:
        print("No service is using the specified port.")

def format_docker_images(data):
    headers = ["REPOSITORY", "TAG", "IMAGE ID", "SIZE"]
    rows = [line.split() for line in data.strip().split('\n')]
    if rows:
        print(tabulate(rows, headers, tablefmt="grid", colalign=("left", "left", "left", "left")))
    else:
        print("No Docker images found.")

def format_docker_containers(data):
    headers = ["NAMES", "IMAGE", "STATUS", "PORTS"]
    rows = [line.split() for line in data.strip().split('\n')]
    if rows:
        print(tabulate(rows, headers, tablefmt="grid", colalign=("left", "left", "left", "left")))
    else:
        print("No running Docker containers found.")

def format_docker_info(data):
    headers = ["ATTRIBUTE", "VALUE"]
    rows = [line.split('\t') for line in data.strip().split('\n')]
    if rows:
        print(tabulate(rows, headers, tablefmt="grid", colalign=("left", "left")))
    else:
        print("No details found for the specified Docker container.")

def format_users(data):
    headers = ["USERNAME", "PORT", "LAST LOGIN"]
    rows = [line.split(maxsplit=2) for line in data.strip().split('\n')]
    print(tabulate(rows, headers, tablefmt="grid"))

def main():
    parser = argparse.ArgumentParser(description="Format and display the output of devopsfetch.sh")
    parser.add_argument("type", choices=["ports", "port_info", "docker_images", "docker_containers", "docker_info", "nginx", "users"],
                        help="Type of output to format")
    parser.add_argument("file", nargs="?", type=argparse.FileType('r'),
                        help="File containing the raw output from devopsfetch.sh")

    args = parser.parse_args()

    # Read data from file or stdin
    if args.file:
        data = args.file.read()
    else:
        data = sys.stdin.read()

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

if __name__ == "__main__":
    main()