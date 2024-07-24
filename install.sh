#!/bin/bash

set -e

# Function to display an error message and exit the script
error_exit() {
    echo "Error: $1"
    exit 1
}

# Function to determine package manager and install packages
install_package() {
    local package="$1"
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get install -y "$package"
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install -y "$package"
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install -y "$package"
    elif [ -x "$(command -v pacman)" ]; then
        sudo pacman -Syu --noconfirm "$package"
    elif [ -x "$(command -v zypper)" ]; then
        sudo zypper install -y "$package"
    else
        error_exit "Unsupported package manager. Please install $package manually."
    fi
}

# Check for the presence of the 'ss' command
if ! command -v ss &> /dev/null; then
    echo "'ss' command not found, installing iproute2 package..."
    install_package iproute2
else
    echo "'ss' command is already installed."
fi

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    echo "Docker not found, installing Docker..."
    install_package docker.io
else
    echo "Docker is already installed."
fi

# Install Nginx if not already installed
if ! command -v nginx &> /dev/null; then
    echo "Nginx not found, installing Nginx..."
    install_package nginx
else
    echo "Nginx is already installed."
fi

# Copy the script to /usr/local/bin
echo "Copying devopsfetch to /usr/local/bin..."
sudo cp devopsfetch.sh /usr/local/bin/devopsfetch || error_exit "Failed to copy devopsfetch script."

# Make the script executable
echo "Making the script executable..."
sudo chmod +x /usr/local/bin/devopsfetch || error_exit "Failed to make the script executable."

# Create a log file for debugging
echo "Creating log file for debugging..."
sudo bash -c 'echo "Starting devopsfetch service setup..." > /tmp/devopsfetch_service.log'

# Set up systemd service with logging
echo "Setting up systemd service..."
cat <<EOF | sudo tee /etc/systemd/system/devopsfetch.service >/dev/null
[Unit]
Description=DevOps Fetch Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/devopsfetch --all
Restart=always
StandardOutput=file:/tmp/devopsfetch_service.log
StandardError=file:/tmp/devopsfetch_service.log

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable the service
echo "Reloading systemd and enabling the service..."
sudo systemctl daemon-reload || error_exit "Failed to reload systemd."
sudo systemctl enable devopsfetch || error_exit "Failed to enable devopsfetch service."
sudo systemctl start devopsfetch || error_exit "Failed to start devopsfetch service."

echo "Installation and setup completed successfully!"
echo "Check /tmp/devopsfetch_service.log for service output and errors."
