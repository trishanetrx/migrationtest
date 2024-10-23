#!/bin/bash

# Step 1: Identify and terminate the process using the most CPU
# Get the PID of the process consuming the most CPU (dd process example)
most_cpu_pid=$(ps -eo pid,%cpu,comm --sort=-%cpu | head -n 2 | tail -n 1 | awk '{print $1}')
# Kill the process
kill -15 $most_cpu_pid

# Step 2: Create the database group with GID 50000
groupadd -g 50000 database

# Step 3: Create the dbadmin1 user and set up the required configurations
useradd -G database dbadmin1

# Step 4: Set the password for dbadmin1
echo "dbadmin1:redhat" | chpasswd

# Step 5: Force dbadmin1 to change the password on first login
chage -d 0 dbadmin1

# Step 6: Set the password policies for dbadmin1
chage -m 10 -M 30 dbadmin1

# Step 7: Enable sudo access for dbadmin1
echo "dbadmin1 ALL=(ALL) ALL" > /etc/sudoers.d/dbadmin1

# Step 8: Switch to the dbadmin1 user to configure their environment
su - dbadmin1 << EOF

# Step 9: Append umask 007 to the .bashrc file
echo "umask 007" >> ~/.bashrc
source ~/.bashrc

# Step 10: Create the /home/dbadmin1/grading/review2 directory
mkdir -p /home/dbadmin1/grading/review2

# Step 11: Set dbadmin1 as the owner and database as the group for /home/dbadmin1 and subdirectories
chown -R dbadmin1:database /home/dbadmin1/

# Step 12: Set group execute permissions on /home/dbadmin1 and subdirectories
chmod -R g+x /home/dbadmin1

# Step 13: Configure /home/dbadmin1/grading/review2 to allow group file creation and set correct permissions
chmod g+s /home/dbadmin1/grading/review2
chmod 775 /home/dbadmin1/grading/review2

# Step 14: Apply sticky bit to /home/dbadmin1/grading/review2 to allow only owners to delete files
chmod o+t /home/dbadmin1/grading/review2

EOF

# Step 15: Exit dbadmin1 and return to the root user
exit
