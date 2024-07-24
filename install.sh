#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit
fi

# Copy the devopsfetch script to /usr/local/bin
echo "Copying devopsfetch script to /usr/local/bin..."
cp devopsfetch.sh /usr/local/bin/devopsfetch
chmod +x /usr/local/bin/devopsfetch

# Create a systemd service file for devopsfetch
echo "Creating systemd service for devopsfetch..."
cat <<EOF >/etc/systemd/system/devopsfetch.service
[Unit]
Description=DevOps Fetch Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/devopsfetch --all
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
echo "Enabling and starting the devopsfetch service..."
systemctl enable devopsfetch
systemctl start devopsfetch

echo "Installation complete. The devopsfetch service is now running."

# Create a logrotate configuration for devopsfetch logs
echo "Configuring log rotation for devopsfetch logs..."
cat <<EOF >/etc/logrotate.d/devopsfetch
/var/log/devopsfetch.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root root
    postrotate
        systemctl restart devopsfetch > /dev/null
    endscript
}
EOF

# Ensure log directory exists
mkdir -p /var/log

# Run devopsfetch in continuous mode
/usr/local/bin/devopsfetch --all >> /var/log/devopsfetch.log 2>&1
