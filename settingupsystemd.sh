#!/bin/bash

# Variables
CONTAINER_NAME="inventorydb"

# Create the systemd directory
mkdir -p ~/.config/systemd/user/

# Generate the systemd service from the running container
cd ~/.config/systemd/user/
podman generate systemd --name $CONTAINER_NAME --files --new

# Reload systemd daemon and enable the service
systemctl --user daemon-reload
systemctl --user enable --now container-$CONTAINER_NAME.service

# Enable lingering for the user services to start at boot
loginctl enable-linger $(whoami)

echo "Systemd service for $CONTAINER_NAME is set up and enabled!"
