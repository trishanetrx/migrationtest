#!/bin/bash

# Step 1: Switch to root user (assuming you are already logged in as student)
sudo -i

# Step 2: Determine the Ethernet interface name and connection profile
nmcli device status

# Step 3: Create the static connection profile with provided network settings
# Replace 'ethX' with the correct interface name as determined by the previous command
nmcli connection add con-name static type ethernet \
ifname ethX ipv4.addresses '172.25.250.111/24' ipv4.gateway '172.25.250.254' \
ipv4.dns '172.25.250.254' ipv4.method manual

# Step 4: Activate the static connection profile
nmcli connection up static

# Step 5: Set the hostname to server-review4.lab4.example.com
hostnamectl set-hostname server-review4.lab4.example.com

# Step 6: Verify the new hostname
hostname

# Step 7: Add 'client-review4' as the canonical name for the servera IP in /etc/hosts
echo "172.25.250.10 client-review4" >> /etc/hosts

# Step 8: Verify connectivity to servera using the canonical name
ping -c2 client-review4

# Step 9: Add the additional IP address (172.25.250.211) to the static connection profile
nmcli connection modify static +ipv4.addresses '172.25.250.211/24'

# Step 10: Activate the new IP address
nmcli connection up static

# Step 11: Verify the reachability of the new IP address (ping this from workstation)
ping -c2 172.25.250.211

# Step 12: Restore the original network profile
# Replace 'Wired connection 1' with the actual original profile name
nmcli connection up "Wired connection 1"

# Step 13: Exit the root session
exit
