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
        sudo apt-get update && sudo apt-get install -y "$package"
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

# Install necessary dependencies
echo "Installing dependencies..."
install_package ss
install_package docker
install_package nginx

# Copy the script to /usr/local/bin
echo "Copying devopsfetch to /usr/local/bin..."
sudo cp devopsfetch.sh /usr/local/bin/devopsfetch || error_exit "Failed to copy devopsfetch script."

# Make the script executable
echo "Making the script executable..."
sudo chmod +x /usr/local/bin/devopsfetch || error_exit "Failed to make the script executable."

# Set up systemd service
echo "Setting up systemd service..."
cat <<EOF | sudo tee /etc/systemd/system/devopsfetch.service >/dev/null
[Unit]
Description=DevOps Fetch Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/devopsfetch --all
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable the service
echo "Reloading systemd and enabling the service..."
sudo systemctl daemon-reload || error_exit "Failed to reload systemd."
sudo systemctl enable devopsfetch || error_exit "Failed to enable devopsfetch service."

echo "Installation and setup completed successfully!"
