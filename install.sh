#!/bin/bash

set -e

# Check if the script is running as root, and if not, re-run it with sudo
if [[ "$(id -u)" -ne 0 ]]; then
    sudo -E "$0" "$@"
    exit
fi

# Function to display an error message and exit the script
error_exit() {
    echo "Error: $1"
    exit 1
}

# Function to determine package manager and install packages
install_package() {
    local package_name="$1"
    if [ -x "$(command -v apt-get)" ]; then
        apt-get install -y "$package_name"
    elif [ -x "$(command -v yum)" ]; then
        yum install -y "$package_name"
    elif [ -x "$(command -v dnf)" ]; then
        dnf install -y "$package_name"
    elif [ -x "$(command -v pacman)" ]; then
        pacman -Syu --noconfirm "$package_name"
    elif [ -x "$(command -v zypper)" ]; then
        zypper install -y "$package_name"
    else
        error_exit "Unsupported package manager. Please install $package_name manually."
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
    if [ -x "$(command -v dnf)" ]; then
        install_package docker
    else
        install_package docker.io
    fi
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

# Install logrotate if not already installed
if ! command -v logrotate &> /dev/null; then
    echo "Logrotate not found, installing logrotate..."
    install_package logrotate
else
    echo "Logrotate is already installed."
fi

# Copy the script to /usr/local/bin
echo "Copying devopsfetch to /usr/local/bin..."
cp devopsfetch.sh /usr/local/bin/devopsfetch || error_exit "Failed to copy devopsfetch script."

# Make the script executable
echo "Making the script executable..."
chmod +x /usr/local/bin/devopsfetch || error_exit "Failed to make the script executable."

# Create a log file for debugging
echo "Creating log file for debugging..."
touch /var/log/devopsfetch.log
chmod 0640 /var/log/devopsfetch.log

# Set up systemd service with logging
echo "Setting up systemd service..."
cat <<EOF > /etc/systemd/system/devopsfetch.service
[Unit]
Description=DevOps Fetch Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/devopsfetch --all
Restart=on-failure
StandardOutput=file:/var/log/devopsfetch.log
StandardError=file:/var/log/devopsfetch.log

[Install]
WantedBy=multi-user.target
EOF

# Create a logrotate configuration file for devopsfetch
echo "Setting up logrotate configuration..."
cat <<EOF > /etc/logrotate.d/devopsfetch
/var/log/devopsfetch.log {
    size 100M
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 root root
    sharedscripts
    postrotate
        systemctl restart devopsfetch.service > /dev/null 2>&1 || true
    endscript
}
EOF

# Reload systemd and enable the service
echo "Reloading systemd and enabling the service..."
systemctl daemon-reload || error_exit "Failed to reload systemd."
systemctl enable devopsfetch || error_exit "Failed to enable devopsfetch service."
systemctl start devopsfetch || error_exit "Failed to start devopsfetch service."

echo "Installation and setup completed successfully!"
echo "Check /var/log/devopsfetch.log for service output and errors."

# Periodic logging function
log_periodic_updates() {
    while true; do
        echo "$(date): Service is running" >> /var/log/devopsfetch.log
        sleep 600  # Sleep for 10 minutes
    done
}

# Start periodic logging in the background
log_periodic_updates &
