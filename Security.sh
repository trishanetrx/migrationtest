#!/bin/bash

# Step 1: Generate SSH key pair for student on serverb without passphrase
ssh-keygen -t rsa -b 3072 -f /home/student/.ssh/id_rsa -N ""

# Step 2: Transfer the public key to student@servera
ssh-copy-id student@servera

# Step 3: Verify login to servera without password (optional check)
ssh student@servera exit

# Step 4: On serverb, verify /localhome does not exist and configure NFS autofs
if [ ! -d /localhome ]; then
    echo "/localhome directory does not exist, proceeding with autofs setup."
fi

# Switch to root
sudo -i

# Step 5: Install autofs
dnf install -y autofs

# Step 6: Create autofs configuration for production5
echo "/- /etc/auto.production5" > /etc/auto.master.d/production5.autofs

# Step 7: Create /etc/auto.production5 with NFS mount details
echo "/localhome/production5 -rw servera.lab.example.com:/user-homes/production5" > /etc/auto.production5

# Step 8: Restart autofs service
systemctl restart autofs

# Step 9: Verify the /localhome/production5 directory and permissions
ls -ld /localhome/production5

# Step 10: Set the SELinux Boolean to allow NFS-mounted home directories
setsebool -P use_nfs_home_dirs true

# Step 11: Adjust firewall to block connections from servera (172.25.250.10)
firewall-cmd --add-source=172.25.250.10/32 --zone=block --permanent
firewall-cmd --reload

# Step 12: Investigate and fix the failing Apache service on port 30080
systemctl restart httpd.service || {
    echo "Apache service failed to restart, checking status and logs."
    systemctl status httpd.service
    journalctl -xeu httpd.service
}

# Step 13: Adjust SELinux to allow httpd to bind to port 30080
semanage port -a -t http_port_t -p tcp 30080

# Step 14: Restart Apache httpd service after fixing SELinux
systemctl restart httpd

# Step 15: Open port 30080 for public access via firewall
firewall-cmd --add-port=30080/tcp --permanent
firewall-cmd --reload

# End of script
