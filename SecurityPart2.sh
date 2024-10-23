#!/bin/bash

# Function to install autofs and configure it
configure_autofs() {
    echo "Installing and configuring autofs..."
    sudo dnf install -y autofs
    echo "/- /etc/auto.production5" | sudo tee /etc/auto.master.d/production5.autofs
    echo "/localhome/production5 -rw servera.lab.example.com:/user-homes/production5" | sudo tee /etc/auto.production5
    sudo systemctl restart autofs
}

# Function to set SELinux to permissive on servera
set_selinux_permissive_servera() {
    echo "Setting SELinux to permissive on servera..."
    ssh student@servera <<EOF
        sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/sysconfig/selinux
        sudo systemctl reboot
EOF
}

# Function to set SELinux Boolean on serverb
set_selinux_boolean_serverb() {
    echo "Setting SELinux Boolean for NFS home directories on serverb..."
    sudo setsebool -P use_nfs_home_dirs true
}

# Function to verify NFS mount on serverb
verify_nfs_mount_serverb() {
    echo "Verifying NFS mount for production5 on serverb..."
    if ! grep -q "/localhome/production5" /etc/mtab; then
        sudo mount /localhome/production5
    fi
    ls -ld /localhome/production5
}

# Function to configure the Apache firewall rules
configure_apache_firewall() {
    echo "Configuring Apache firewall rules on serverb..."
    sudo firewall-cmd --add-port=30080/tcp --permanent
    sudo firewall-cmd --reload
}

# Function to fix Apache HTTPD issue with port 30080
fix_apache_httpd() {
    echo "Fixing Apache HTTPD service..."
    if ! sudo semanage port -l | grep -q "30080"; then
        sudo semanage port -a -t http_port_t -p tcp 30080
    fi
    sudo systemctl restart httpd
    sudo systemctl status httpd
}

# Run the configuration tasks
echo "Running remaining tasks..."

configure_autofs
set_selinux_permissive_servera
set_selinux_boolean_serverb
verify_nfs_mount_serverb
configure_apache_firewall
fix_apache_httpd

echo "All tasks completed."
