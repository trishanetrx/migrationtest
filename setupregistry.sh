#!/bin/bash

# Define variables
REGISTRY_CONF_TEMPLATE="/tmp/registries.conf"
REGISTRY_CONF_DIR="$HOME/.config/containers"
REGISTRY_URL="registry.lab.example.com"
REGISTRY_USER="admin"
REGISTRY_PASSWORD="redhat321"

# Create the necessary directory for container configuration
mkdir -p $REGISTRY_CONF_DIR

# Copy the registry configuration template
cp $REGISTRY_CONF_TEMPLATE $REGISTRY_CONF_DIR/

# Log in to the container registry
podman login $REGISTRY_URL -u $REGISTRY_USER -p $REGISTRY_PASSWORD

if [ $? -eq 0 ]; then
    echo "Login succeeded!"
else
    echo "Login failed!"
fi
