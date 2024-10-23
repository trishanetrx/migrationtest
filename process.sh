#!/bin/bash

# Step 1: Log in to serverb as student (assuming you are already logged in)
# ssh student@serverb

# Step 2: Identify and terminate the process using the most CPU
# Get the PID of the process consuming the most CPU (dd process example)
most_cpu_pid=$(ps -eo pid,%cpu,comm --sort=-%cpu | head -n 2 | tail -n 1 | awk '{print $1}')
# Kill the process with sudo
echo "student" | sudo -S kill -15 $most_cpu_pid

# Step 3: Create the database group with GID 50000 using sudo
echo "student" | sudo -S groupadd -g 50000 database

# Step 4: Create the dbadmin1 user and set up the required configurations using sudo
echo "student" | sudo -S useradd -G database dbadmin1

# Step 5: Set the password for dbadmin1 using sudo
echo "dbadmin1:redhat" | echo "student" | sudo -S chpasswd

# Step 6: Force dbadmin1 to change the password on first login using sudo
echo "student" | sudo -S chage -d 0 dbadmin1

# Step 7: Set the password policies for dbadmin1 using sudo
echo "student" | sudo -S chage -m 10 -M 30 dbadmin1

# Step 8: Enable sudo access for dbadmin1 using sudo
echo "dbadmin1 ALL=(ALL) ALL" | echo "student" | sudo -S tee /etc/sudoers.d/dbadmin1

# Step 9: Switch to the dbadmin1 user to configure their environment
echo "student" | sudo -S su - dbadmin1 << EOF

# Step 10: Append umask 007 to the .bashrc file
echo "umask 007" >> ~/.bashrc
source ~/.bashrc

# Step 11: Create the /home/dbadmin1/grading/review2 directory
mkdir -p /home/dbadmin1/grading/review2

# Step 12: Set dbadmin1 as the owner and database as the group for /home/dbadmin1 and subdirectories
echo "student" | sudo -S chown -R dbadmin1:database /home/dbadmin1/

# Step 13: Set group execute permissions on /home/dbadmin1 and subdirectories
echo "student" | sudo -S chmod -R g+x /home/dbadmin1

# Step 14: Configure /home/dbadmin1/grading/review2 to allow group file creation and set correct permissions
echo "student" | sudo -S chmod g+s /home/dbadmin1/grading/review2
echo "student" | sudo -S chmod 775 /home/dbadmin1/grading/review2

# Step 15: Apply sticky bit to /home/dbadmin1/grading/review2 to allow only owners to delete files
echo "student" | sudo -S chmod o+t /home/dbadmin1/grading/review2

EOF

# Step 16: Exit dbadmin1 and return to the student user
exit
