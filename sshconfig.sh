#!/usr/bin/expect

# Define variables for passwords
set root_password "student"
set production_password "redhat"

# Step 1: SSH into servera as student user
spawn ssh student@servera
expect "password:"
send "$root_password\r"
expect "$ "

# Step 2: Switch to the production1 user
send "su - production1\r"
expect "Password:"
send "$production_password\r"
expect "$ "

# Step 3: Generate SSH keys (without passphrase)
send "ssh-keygen -t rsa -b 3072 -f /home/production1/.ssh/id_rsa -N ''\r"
expect "$ "

# Step 4: Copy public key to serverb (password for production1 will be prompted)
send "ssh-copy-id -o StrictHostKeyChecking=no production1@serverb\r"
expect "password:"
send "$production_password\r"
expect "$ "

# Step 5: Test login to serverb using SSH keys
send "ssh -o StrictHostKeyChecking=no production1@serverb\r"
expect "$ "

# Step 6: Exit production1 user session before switching to root
send "exit\r"
expect "$ "

# Step 7: Now switch to the root user
send "su -\r"
expect "Password:"
send "$root_password\r"
expect "# "

# Step 8: Edit /etc/ssh/sshd_config to disable root login (executed as root)
send "sed -i 's/^#\\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config\r"
expect "# "

# Step 9: Reload sshd service (executed as root)
send "systemctl reload sshd\r"
expect "# "

# Step 10: Edit /etc/ssh/sshd_config to disable password-based SSH login (executed as root)
send "sed -i 's/^#\\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config\r"
expect "# "

# Step 11: Reload sshd service again (executed as root)
send "systemctl reload sshd\r"
expect "# "

# Step 12: Exit root session on serverb
send "exit\r"
expect "$ "

# Step 13: Test login to serverb as production2 (should fail)
send "ssh -o StrictHostKeyChecking=no production2@serverb\r"
expect "$ "

# Step 14: Test login to serverb as production1 (should succeed)
send "ssh -o StrictHostKeyChecking=no production1@serverb\r"
expect "$ "

# Step 15: Exit all sessions
send "exit\r"
expect "$ "

send "exit\r"
expect eof
