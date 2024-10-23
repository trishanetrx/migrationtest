#!/bin/bash

# Step 1: Generate SSH keys for the student user on serverb
ssh-keygen -t rsa -b 3072 -f /home/student/.ssh/review3_key -N ""

# Step 2: Export the public key to servera (assuming the password for student user is 'student')
ssh-copy-id -i /home/student/.ssh/review3_key.pub student@servera << EOF
student
EOF

# Step 3: Test logging into servera using the new SSH key without entering a password
ssh -i /home/student/.ssh/review3_key student@servera << EOF
exit
EOF

# Step 4: Configure sshd to prevent root login
sudo sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl reload sshd.service

# Step 5: Configure sshd to disable password-based login but allow SSH keys
sudo sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl reload sshd.service

# Step 6: Install zsh package
sudo dnf install -y zsh

# Step 7: Set time zone to Asia/Kolkata
sudo timedatectl set-timezone Asia/Kolkata

# Step 8: Exit the session
exit
