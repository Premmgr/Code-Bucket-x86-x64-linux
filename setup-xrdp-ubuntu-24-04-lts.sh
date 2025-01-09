#!/bin/bash

# Before starting the setup ensure your have installed full kde plasma on ubuntu 24.04 lts

set -e

# Update package list and install required packages
sudo apt update
sudo apt install -y xrdp dbus-x11 git libpulse-dev autoconf m4 intltool build-essential dpkg-dev

# Remove existing self-signed certificates if they exist
sudo rm -f /etc/xrdp/cert.pem /etc/xrdp/key.pem

# Generate a new self-signed certificate
sudo openssl req -new -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes \
  -subj "/CN=$(hostname)" \
  -out /etc/xrdp/cert.pem -keyout /etc/xrdp/key.pem

# Set appropriate permissions for the certificate files
sudo chown root:xrdp /etc/xrdp/key.pem
sudo chmod 440 /etc/xrdp/key.pem

# Enable and start the XRDP service
sudo systemctl enable xrdp
sudo systemctl restart xrdp

# Backup the original startwm.sh script
sudo mv /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.orig

# Create a new startwm.sh script to launch KDE Plasma
echo 'dbus-launch --exit-with-session startplasma-x11' | sudo tee /etc/xrdp/startwm.sh
sudo chmod 755 /etc/xrdp/startwm.sh

# Restart XRDP and the display manager to apply changes
sudo systemctl restart xrdp
sudo systemctl restart display-manager

# Allow all users to start the X server
echo 'allowed_users=anybody' | sudo tee -a /etc/X11/Xwrapper.config
echo 'needs_root_rights=no' | sudo tee -a /etc/X11/Xwrapper.config

# Restart XRDP and the display manager again to apply X server settings
sudo systemctl restart xrdp
sudo systemctl restart display-manager

# Enable source repositories for building PulseAudio modules
sudo sed -i '/^# deb-src /s/^# //' /etc/apt/sources.list
sudo apt update

# Install PulseAudio build dependencies
sudo apt build-dep -y pulseaudio

# Clone the pulseaudio-module-xrdp repository
cd ~
git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git

# Build and install the PulseAudio modules
cd pulseaudio-module-xrdp
./bootstrap
./configure PULSE_DIR=~/pulseaudio.src
make
sudo make install

# Verify the installation of the modules
if ls $(pkg-config --variable=modlibexecdir libpulse) | grep -q xrdp; then
  echo "PulseAudio modules installed successfully."
else
  echo "Error: PulseAudio modules installation failed." >&2
  exit 1
fi

# Restart PulseAudio and XRDP services to apply changes
pulseaudio -k
sudo systemctl restart xrdp

echo "XRDP server with KDE Plasma and audio redirection has been successfully installed and configured."
