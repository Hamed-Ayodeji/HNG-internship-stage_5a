#!/bin/bash

# Install necessary packages
echo "Installing required packages..."
apt-get update
apt-get install -y ss awk sed grep docker nginx systemd
echo "Packages installed successfully."