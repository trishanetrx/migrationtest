#!/usr/bin/expect

# Define variables for passwords
set root_password "student"
set production_password "redhat"

# Step 1: SSH into servera as student user
spawn ssh student@servera
expect "password:"
send "$root_password\r"
expect "$ "

# Step 2: Switch to the production1 user to perform non-privileged tasks
send "su - production1\r"
expect "Password:"
send "$production_password\r"
expect "$ "

# Step 3: Generate SSH keys (without passphrase) as production1
send "ssh-keygen -t rsa -b 3072 -f /home/production1/.ssh/id_rsa -N ''\r"
expect "$ "

# Step 4: Copy public key to serverb (password for production1 will be prompted)
send "ssh-copy-id -o StrictHostKeyChecking=no production1@serverb\r"
expect "password:"
send "$production_password\r"
expect "$ "

# Step 5: Test login to serverb using SSH keys (as production1)
send "ssh -o StrictHostKeyChecking=no production1@serverb\r"
expect "$ "

# Step 6: **Exit the production1 session** after non-privileged tasks are done
send "exit\r"
expect "$ "

# Step 7: Now switch to the root user on serverb to run privileged commands
send "ssh root@serverb\r"
expect "password:"
send "$root_password\r"
expect "# "  ; # now as root on serverb

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

# Step 13: Exit all sessions
send "exit\r"
expect "$ "

send "exit\r"
expect eof
