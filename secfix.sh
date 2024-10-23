#!/bin/bash
podman run -d --name db-app01 -e MYSQL_USER=developer -e MYSQL_PASSWORD=redhat -e MYSQL_DATABASE=inventory -e MYSQL_ROOT_PASSWORD=redhat --network production -p 13306:3306 -v /home/podmgr/storage/database:/var/lib/mysql/data:Z registry.lab.example.com/rhel8/mariadb-103:1-86

