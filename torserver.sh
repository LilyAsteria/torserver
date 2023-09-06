#!/bin/bash

# Step 1: Install required packages
sudo apt-get update -y
sudo apt-get install unattended-upgrades apt-listchanges apt-transport-https -y

# Step 2: Edit configuration files
# Create /etc/apt/apt.conf.d/50unattended-upgrades
echo 'Unattended-Upgrade::Origins-Pattern {
    "origin=Debian,codename=${distro_codename},label=Debian-Security";
    "origin=TorProject";
};
Unattended-Upgrade::Package-Blacklist {
};' | sudo tee /etc/apt/apt.conf.d/50unattended-upgrades > /dev/null

# Update /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Update-Package-Lists "1";
APT::Periodic::AutocleanInterval "5";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Verbose "1";' | sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null

# Step 3: Automatically reboot
echo 'Unattended-Upgrade::Automatic-Reboot "true";' | sudo tee -a /etc/apt/apt.conf.d/50unattended-upgrades > /dev/null

# Step 4: Configure Tor
# Create /etc/apt/sources.list.d/tor.list
echo 'deb     [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bullseye main
deb-src [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bullseye main' | sudo tee /etc/apt/sources.list.d/tor.list > /dev/null

# Import Tor GPG key
sudo wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null

# Update package lists
sudo apt-get update -y

# Install Tor and Nyx
sudo apt-get install tor deb.torproject.org-keyring nyx -y

# Configure Tor
echo 'Nickname    AeonDisk # Change "myNiceRelay" to something you like
# Write your e-mail and be aware it will be published
ORPort      443          # You might use a different port, should you want to
ExitRelay   0
SocksPort   0
ControlPort 6942
MyFamily B11E486834F4BFCB4EB2B59E24580FA0E71499A6' | sudo tee /etc/tor/torrc > /dev/null

# Step 5: Restart the Tor service
sudo systemctl restart tor@default
sudo systemctl restart tor
