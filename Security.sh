#!/bin/bash

# Variables for user and target server
USER="student"
SERVER="servera"
SSH_DIR="/home/$USER/.ssh"
KEY_PATH="$SSH_DIR/id_rsa"
PUBLIC_KEY_PATH="$KEY_PATH.pub"

# Step 1: Ensure the .ssh directory exists and has the correct permissions
echo "Ensuring $SSH_DIR exists and has the correct permissions..."
if [ ! -d "$SSH_DIR" ]; then
    sudo mkdir -p "$SSH_DIR"
    echo "$SSH_DIR created."
fi
sudo chmod 700 "$SSH_DIR"
sudo chown "$USER:$USER" "$SSH_DIR"

# Step 2: Generate SSH keys if they don't already exist
if [ -f "$KEY_PATH" ]; then
    echo "SSH key already exists at $KEY_PATH. Skipping key generation."
else
    echo "Generating SSH key pair..."
    sudo -u $USER ssh-keygen -t rsa -b 3072 -f "$KEY_PATH" -N ""
fi

# Verify that the SSH key pair was created
if [ -f "$KEY_PATH" ] && [ -f "$PUBLIC_KEY_PATH" ]; then
    echo "SSH key pair generated successfully:"
    ls -l "$SSH_DIR"
else
    echo "Error: SSH key pair not found."
    exit 1
fi

# Step 3: Copy the public key to the target server (servera)
echo "Copying the public key to $SERVER..."
sudo -u $USER ssh-copy-id -i "$PUBLIC_KEY_PATH" $USER@$SERVER

# Step 4: Verify login without password
echo "Attempting to log in to $SERVER without a password..."
sudo -u $USER ssh -o PubkeyAuthentication=yes -o PasswordAuthentication=no $USER@$SERVER

if [ $? -eq 0 ]; then
    echo "SSH login to $SERVER succeeded without password!"
else
    echo "SSH login to $SERVER failed. Please check the SSH configuration."
fi
