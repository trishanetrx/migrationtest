#!/bin/bash

# Variables
DATA_DIR="/home/podsvc/db_data"
IMAGE="registry.lab.example.com/rhel8/mariadb-103:1-86"
CONTAINER_NAME="inventorydb"
MYSQL_USER="operator1"
MYSQL_PASSWORD="redhat"
MYSQL_DATABASE="inventory"
MYSQL_ROOT_PASSWORD="redhat"
PORT="13306"

# Create the data directory
mkdir -p $DATA_DIR

# Get MySQL UID and GID (usually 27:27)
podman run -d --name temp_db $IMAGE
MYSQL_UID=$(podman exec -it temp_db id -u mysql | tr -d '\r')
MYSQL_GID=$(podman exec -it temp_db id -g mysql | tr -d '\r')

# Remove the temporary container
podman stop temp_db && podman rm temp_db

# Set ownership of the data directory
sudo chown -R $MYSQL_UID:$MYSQL_GID $DATA_DIR

# Set the user namespace UID and GID using podman unshare
podman unshare chown -R $MYSQL_UID:$MYSQL_GID $DATA_DIR

# Create the inventorydb container
podman run -d --name $CONTAINER_NAME \
    -p $PORT:3306 \
    -e MYSQL_USER=$MYSQL_USER \
    -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
    -e MYSQL_DATABASE=$MYSQL_DATABASE \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    -v $DATA_DIR:/var/lib/mysql/data:Z \
    $IMAGE

echo "MariaDB container deployed!"
