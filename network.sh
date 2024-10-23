#!/bin/bash

# Step 1: Switch to root user (prompt for sudo)
echo "student" | sudo -S nmcli connection add con-name static type ethernet \
ifname eth0 ipv4.addresses '172.25.250.111/24' ipv4.gateway '172.25.250.254' \
ipv4.dns '172.25.250.254' ipv4.method manual

# Step 2: Activate the static connection profile
echo "student" | sudo -S nmcli connection up static

# Step 3: Set the hostname to server-review4.lab4.example.com
echo "student" | sudo -S hostnamectl set-hostname server-review4.lab4.example.com

# Step 4: Verify the new hostname
hostname

# Step 5: Add 'client-review4' as the canonical name for the servera IP in /etc/hosts
echo "student" | sudo -S bash -c 'echo "172.25.250.10 client-review4" >> /etc/hosts'

# Step 6: Verify connectivity to servera using the canonical name
ping -c2 client-review4

# Step 7: Add the additional IP address (172.25.250.211) to the static connection profile
echo "student" | sudo -S nmcli connection modify static +ipv4.addresses '172.25.250.211/24'

# Step 8: Activate the new IP address
echo "student" | sudo -S nmcli connection up static

# Step 9: Verify the reachability of the new IP address (ping this from workstation)
ping -c2 172.25.250.211

# Step 10: Restore the original network profile "Wired connection 1"
echo "student" | sudo -S nmcli connection up "Wired connection 1"

# Step 11: Exit the root session
exit
