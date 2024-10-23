#!/bin/bash

# Ensure .ssh directory exists with proper permissions
mkdir -p /home/student/.ssh
chmod 700 /home/student/.ssh

# Generate SSH key pair for student
ssh-keygen -t rsa -b 3072 -f /home/student/.ssh/id_rsa -N ""

# Ensure proper permissions for the generated key files
chmod 600 /home/student/.ssh/id_rsa
chmod 644 /home/student/.ssh/id_rsa.pub

# Transfer the public key to student@servera
ssh-copy-id -i /home/student/.ssh/id_rsa.pub student@servera

# Verify SSH login to servera without password
ssh student@servera exit
