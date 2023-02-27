#!/usr/bin/env
username="stageuser"
password="JEHBvsgfd389864bvxiLosgqpneygs"
USER_SHELL="/usr/sbin/nologin"

# add sftpd user
sudo useradd $username --shell $USER_SHELL

# Set the password for the user
echo "$username:$password" | chpasswd
# Update the package list
sudo apt-get update

# Install vsftpd
sudo apt-get install vsftpd -y

# Backup the default configuration file
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

# Restart vsftpd
sudo systemctl restart vsftpd
