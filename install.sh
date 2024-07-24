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
    local package_name="$2"
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get install -y "$package_name"
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install -y "$package_name"
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install -y "$package_name"
    elif [ -x "$(command -v pacman)" ]; then
        sudo pacman -Syu --noconfirm "$package_name"
    elif [ -x "$(command -v zypper)" ]; then
        sudo zypper install -y "$package_name"
    else
        error_exit "Unsupported package manager. Please install $package manually."
    fi
}

# Check for the presence of the 'ss' command
if ! command -v ss &> /dev/null; then
    echo "'ss' command not found, installing iproute2 package..."
    install_package iproute2 iproute2
else
    echo "'ss' command is already installed."
fi

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    echo "Docker not found, installing Docker..."
    if [ -x "$(command -v dnf)" ]; then
        install_package docker docker
    else
        install_package docker.io docker.io
    fi
else
    echo "Docker is already installed."
fi

# Install Nginx if not already installed
if ! command -v nginx &> /dev/null; then
    echo "Nginx not found, installing Nginx..."
    install_package nginx nginx
else
    echo "Nginx is already installed."
fi

# Install logrotate if not already installed
if ! command -v logrotate &> /dev/null; then
    echo "Logrotate not found, installing logrotate..."
    install_package logrotate logrotate
else
    echo "Logrotate is already installed."
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
Restart=on-failure
StandardOutput=file:/tmp/devopsfetch_service.log
StandardError=file:/tmp/devopsfetch_service.log

[Install]
WantedBy=multi-user.target
EOF

# Create a logrotate configuration file for devopsfetch
echo "Setting up logrotate configuration..."
cat <<EOF | sudo tee /etc/logrotate.d/devopsfetch >/dev/null
/var/log/devopsfetch.log {
    size 100M                 # Rotate logs when they reach 100MB in size
    missingok                 # Do not issue an error if the log file is missing
    rotate 7                  # Keep 7 days of backlogs
    compress                  # Compress rotated logs to save space
    delaycompress             # Compress the log file on the next rotation cycle
    notifempty                # Do not rotate the log if it is empty
    create 0640 root root    # Create new log file with specified permissions
    sharedscripts            # Run post-rotation scripts once for all logs
    postrotate
        # Commands to run after rotating logs
        systemctl restart devopsfetch.service > /dev/null 2>&1 || true
    endscript
}
EOF

# Set up a cron job to run logrotate every 10 minutes
echo "Setting up cron job for logrotate..."
cat <<EOF | sudo tee /etc/cron.d/devopsfetch-logrotate >/dev/null
*/10 * * * * root /usr/sbin/logrotate /etc/logrotate.d/devopsfetch > /dev/null 2>&1
EOF

# Reload systemd and enable the service
echo "Reloading systemd and enabling the service..."
sudo systemctl daemon-reload || error_exit "Failed to reload systemd."
sudo systemctl enable devopsfetch || error_exit "Failed to enable devopsfetch service."
sudo systemctl start devopsfetch || error_exit "Failed to start devopsfetch service."

echo "Installation and setup completed successfully!"
echo "Check /tmp/devopsfetch_service.log for service output and errors."
