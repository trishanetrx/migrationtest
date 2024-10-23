#!/bin/bash

# Set the passwords for users
STUDENT_PASS="student"
PRODUCTION5_PASS="redhat"

# Function to check and run commands with error handling
run_cmd() {
  echo "Running: $1"
  eval "$1"
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to run '$1'"
    exit 1
  fi
}

# Function to handle ssh-copy-id with expect
ssh_copy_id_expect() {
  USER=$1
  SERVER=$2
  PASS=$3
  KEY=$4

  /usr/bin/expect <<EOF
  spawn ssh-copy-id -i $KEY $USER@$SERVER
  expect {
    "(yes/no)?" { send "yes\r"; exp_continue }
    "password:" { send "$PASS\r" }
  }
  expect eof
EOF
}

# Function to handle SSH login with expect
ssh_login_expect() {
  USER=$1
  SERVER=$2
  PASS=$3
  COMMAND=$4

  /usr/bin/expect <<EOF
  spawn ssh $USER@$SERVER "$COMMAND"
  expect {
    "(yes/no)?" { send "yes\r"; exp_continue }
    "password:" { send "$PASS\r" }
  }
  expect eof
EOF
}

# Step 1: Generate SSH Key for student
run_cmd "ssh-keygen -t rsa -b 3072 -f /home/student/.ssh/id_rsa -N ''"
run_cmd "chmod 700 /home/student/.ssh"
run_cmd "chmod 600 /home/student/.ssh/id_rsa"
run_cmd "chmod 644 /home/student/.ssh/id_rsa.pub"
run_cmd "touch /home/student/.ssh/known_hosts"
run_cmd "chmod 600 /home/student/.ssh/known_hosts"

# Step 2: Copy SSH key to servera for student using expect
ssh_copy_id_expect "student" "servera" "$STUDENT_PASS" "/home/student/.ssh/id_rsa.pub"

# Step 3: SSH into servera as student using expect
ssh_login_expect "student" "servera" "$STUDENT_PASS" "echo SSH connection successful for student user"

# Step 4: Set SELinux mode to permissive on servera using expect
ssh_login_expect "student" "servera" "$STUDENT_PASS" "sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/sysconfig/selinux"
ssh_login_expect "student" "servera" "$STUDENT_PASS" "sudo systemctl reboot"

# Wait for servera to reboot
echo "Waiting for servera to reboot..."
sleep 60

# Step 5: Verify /localhome directory doesn't exist on serverb
if [ ! -d "/localhome" ]; then
  echo "/localhome does not exist, proceeding."
else
  echo "/localhome already exists, skipping creation."
fi

# Step 6: Install autofs on serverb and configure the automount
run_cmd "sudo dnf install -y autofs"
cat <<EOT | sudo tee /etc/auto.master.d/production5.autofs
/- /etc/auto.production5
EOT
run_cmd "getent passwd production5 | grep '/localhome/production5'"
cat <<EOT | sudo tee /etc/auto.production5
/localhome/production5 -rw servera.lab.example.com:/user-homes/production5
EOT
run_cmd "sudo systemctl restart autofs"
run_cmd "sudo ls -ld /localhome/production5"

# Step 7: Enable SELinux boolean to allow NFS-mounted directories
run_cmd "sudo setsebool -P use_nfs_home_dirs true"

# Step 8: Generate SSH Key for production5 user
run_cmd "sudo su - production5 -c 'ssh-keygen -t rsa -b 3072 -f /home/production5/.ssh/id_rsa -N '''"
run_cmd "sudo su - production5 -c 'chmod 700 /home/production5/.ssh && chmod 600 /home/production5/.ssh/id_rsa && chmod 644 /home/production5/.ssh/id_rsa.pub'"
run_cmd "sudo su - production5 -c 'touch /home/production5/.ssh/known_hosts && chmod 600 /home/production5/.ssh/known_hosts'"

# Step 9: Copy SSH key to servera for production5 using expect
ssh_copy_id_expect "production5" "servera" "$PRODUCTION5_PASS" "/home/production5/.ssh/id_rsa.pub"

# Step 10: Set up firewall to block servera traffic on serverb
run_cmd "sudo firewall-cmd --add-source=172.25.250.10/32 --zone=block --permanent"
run_cmd "sudo firewall-cmd --reload"

# Step 11: Fix Apache port binding issue on port 30080 (SELinux)
run_cmd "sudo semanage port -a -t http_port_t -p tcp 30080"
run_cmd "sudo firewall-cmd --add-port=30080/tcp --permanent"
run_cmd "sudo firewall-cmd --reload"
run_cmd "sudo systemctl restart httpd"

echo "Script completed successfully!"
