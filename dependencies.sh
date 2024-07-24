#!/bin/bash

# List of packages to be checked and installed for each distribution
debian_packages=("ss" "gawk" "sed" "grep" "docker.io" "nginx" "systemd")
rpm_packages=("iproute" "gawk" "sed" "grep" "docker-ce" "nginx" "systemd")
arch_packages=("iproute2" "gawk" "sed" "grep" "docker" "nginx" "systemd")

# Detect the Linux distribution
distro=""
if [ -f /etc/os-release ]; then
    . /etc/os-release
    distro=$ID
elif [ -f /etc/redhat-release ]; then
    distro="rhel"
elif [ -f /etc/arch-release ]; then
    distro="arch"
fi

# Function to check if a package is installed (Debian/Ubuntu)
is_installed_debian() {
    dpkg -l | grep -q "^ii  $1 "
}

# Function to check if a package is installed (Red Hat/Fedora)
is_installed_rpm() {
    rpm -q "$1" >/dev/null 2>&1
}

# Function to check if a package is installed (Arch)
is_installed_arch() {
    pacman -Q "$1" >/dev/null 2>&1
}

# Install packages based on the distribution
case "$distro" in
    debian|ubuntu)
        echo "Updating package lists..."
        sudo apt-get update

        for pkg in "${debian_packages[@]}"; do
            if is_installed_debian "$pkg"; then
                echo "$pkg is already installed."
            else
                echo "$pkg is not installed. Installing..."
                sudo apt-get install -y "$pkg"
            fi
        done
        ;;
    
    rhel|fedora)
        echo "Updating package lists..."
        sudo dnf check-update 2>/dev/null

        for pkg in "${rpm_packages[@]}"; do
            if is_installed_rpm "$pkg"; then
                echo "$pkg is already installed."
            else
                echo "$pkg is not installed. Installing..."
                sudo dnf install -y "$pkg"
            fi
        done
        ;;
    
    arch)
        echo "Synchronizing package database..."
        sudo pacman -Syu

        for pkg in "${arch_packages[@]}"; do
            if is_installed_arch "$pkg"; then
                echo "$pkg is already installed."
            else
                echo "$pkg is not installed. Installing..."
                sudo pacman -S --noconfirm "$pkg"
            fi
        done
        ;;
    
    *)
        echo "Unsupported distribution: $distro"
        exit 1
        ;;
esac

echo "Package installation process completed."
