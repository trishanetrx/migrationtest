#!/bin/bash

# Step 1: Switch to root user (assuming you are already logged in as student)
sudo -i

# Step 2: Create the static connection profile with provided network settings for eth0
nmcli connection add con-name static type ethernet \
ifname eth0 ipv4.addresses '172.25.250.111/24' ipv4.gateway '172.25.250.254' \
ipv4.dns '172.25.250.254' ipv4.method manual

# Step 3: Activate the static connection profile
nmcli connection up static

# Step 4: Set the hostname to server-review4.lab4.example.com
hostnamectl set-hostname server-review4.lab4.example.com

# Step 5: Verify the new hostname
hostname

# Step 6: Add 'client-review4' as the canonical name for the servera IP in /etc/hosts
echo "172.25.250.10 client-review4" >> /etc/hosts

# Step 7: Verify connectivity to servera using the canonical name
ping -c2 client-review4

# Step 8: Add the additional IP address (172.25.250.211) to the static connection profile
nmcli connection modify static +ipv4.addresses '172.25.250.211/24'

# Step 9: Activate the new IP address
nmcli connection up static

# Step 10: Verify the reachability of the new IP address (ping this from workstation)
ping -c2 172.25.250.211

# Step 11: Restore the original network profile "Wired connection 1"
nmcli connection up "Wired connection 1"

# Step 12: Exit the root session
exit
