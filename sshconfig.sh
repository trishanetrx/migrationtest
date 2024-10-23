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
send "ssh-copy-id production1@serverb\r"
expect {
    "Are you sure you want to continue connecting (yes/no)?" {
        send "yes\r"
        exp_continue
    }
    "password:" {
        send "$production_password\r"
    }
}
expect "$ "

# Step 5: Test login to serverb using SSH keys
send "ssh production1@serverb\r"
expect "$ "

# Step 6: Switch to root on serverb
send "su -\r"
expect "Password:"
send "$root_password\r"
expect "# "

# Step 7: Edit /etc/ssh/sshd_config to disable root login
send "sed -i 's/^#\\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config\r"
expect "# "

# Step 8: Reload sshd service
send "systemctl reload sshd\r"
expect "# "

# Step 9: Edit /etc/ssh/sshd_config to disable password-based SSH login
send "sed -i 's/^#\\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config\r"
expect "# "

# Step 10: Reload sshd service again
send "systemctl reload sshd\r"
expect "# "

# Step 11: Exit root session on serverb
send "exit\r"
expect "$ "

# Step 12: Test login to serverb as production2 (should fail)
send "ssh production2@serverb\r"
expect "$ "

# Step 13: Test login to serverb as production1 (should succeed)
send "ssh production1@serverb\r"
expect "$ "

# Step 14: Exit all sessions
send "exit\r"
expect "$ "

send "exit\r"
expect eof
