#!/bin/bash

# Install container-tools
sudo dnf install -y container-tools

# Create the podmgr user
sudo useradd podmgr
echo redhat | sudo passwd podmgr --stdin

# Configure podmgr environment
su - podmgr <<EOF
mkdir -p ~/.config/containers
cp /tmp/review4/registries.conf ~/.config/containers/

# Log in to the registry
echo "redhat321" | podman login registry.lab.example.com --username admin --password-stdin

# Copy the development files
cp -r /tmp/review4/container-dev/* ~/

# Create persistent storage
mkdir -p ~/storage/database
chmod 0777 ~/storage/database

# Create the production DNS-enabled container network
podman network create --gateway 10.81.0.1 --subnet 10.81.0.0/16 production

# Verify network creation
podman network inspect production

# Search for the earliest version of the mariadb container
MARIADB_VERSION=$(skopeo inspect docker://registry.lab.example.com/rhel8/mariadb-103 | jq -r '.RepoTags | sort | .[0]')

# Create the db-app01 container
podman run -d --name db-app01 \
-e MYSQL_USER=developer \
-e MYSQL_PASSWORD=redhat \
-e MYSQL_DATABASE=inventory \
-e MYSQL_ROOT_PASSWORD=redhat \
--network production -p 13306:3306 \
-v ~/storage/database:/var/lib/mysql/data:Z \
registry.lab.example.com/rhel8/mariadb-103:$MARIADB_VERSION

# Create systemd service for db-app01
mkdir -p ~/.config/systemd/user/
podman generate systemd --name db-app01 --files
mv container-db-app01.service ~/.config/systemd/user/

# Stop the container
podman stop db-app01

# Enable and start systemd service
systemctl --user daemon-reload
systemctl --user enable --now container-db-app01
loginctl enable-linger

# Copy and execute the SQL script in the container
podman cp ~/db-dev/inventory.sql db-app01:/tmp/inventory.sql
podman exec -it db-app01 sh -c 'mysql -u root inventory < /tmp/inventory.sql'

# Build and run the http-app01 container
podman build -t http-client:9.0 ~/http-dev/
podman run -d --name http-app01 --network production -p 8080:8080 localhost/http-client:9.0

# Verify the http-app01 container
curl 127.0.0.1:8080

exit
EOF
