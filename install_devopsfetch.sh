#!/bin/bash

# Ensure the script is run as root. If not, rerun the script with sudo.
if [[ "$(id -u)" -ne 0 ]]; then
    sudo -E "$0" "$@"
    exit
fi

# Define paths and file locations.
DEVOPS_SCRIPT="/usr/local/bin/devopsfetch"
PYTHON_FORMATTER="/usr/local/bin/format_output.py"
SERVICE_FILE="/etc/systemd/system/devopsfetch.service"

# Function to install required system dependencies based on the package manager.
install_system_dependencies() {
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y net-tools docker.io nginx python3 python3-pip
    elif command -v yum &> /dev/null || command -v dnf &> /dev/null; then
        sudo yum install -y net-tools docker nginx python3 python3-pip
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y net-tools docker nginx python3 python3-pip
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy --noconfirm net-tools docker nginx python3 python-pip
    else
        echo "Unsupported Linux distribution. Please install dependencies manually."
        exit 1
    fi
}

# Function to install required Python dependencies using pip.
install_python_dependencies() {
    # Ensure pip is up-to-date.
    sudo python3 -m pip install --upgrade pip

    # Install required Python packages.
    sudo python3 -m pip install tabulate
}

# Function to create necessary directories and files for the devopsfetch service.
create_files_and_directories() {
    # Copy the devopsfetch script to /usr/local/bin and make it executable.
    sudo cp devopsfetch.sh "$DEVOPS_SCRIPT"
    sudo chmod +x "$DEVOPS_SCRIPT"

    # Copy the Python formatter script to /usr/local/bin and make it executable.
    sudo cp format_output.py "$PYTHON_FORMATTER"
    sudo chmod +x "$PYTHON_FORMATTER"

    # Create a systemd service file for devopsfetch and set the correct permissions.
    sudo tee "$SERVICE_FILE" > /dev/null <<EOL
[Unit]
Description=DevOpsFetch Monitoring Service
After=network.target

[Service]
ExecStart=$DEVOPS_SCRIPT
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL
    sudo chmod 644 "$SERVICE_FILE"
}

# Function to enable and start the devopsfetch systemd service.
setup_systemd_service() {
    sudo systemctl daemon-reload
    sudo systemctl enable devopsfetch.service
    sudo systemctl start devopsfetch.service
}

# Main function to execute the installation process.
main() {
    install_system_dependencies
    install_python_dependencies
    create_files_and_directories
    setup_systemd_service

    echo "DevOpsFetch installation and setup completed."
}

# Execute the main function.
main "$@"
