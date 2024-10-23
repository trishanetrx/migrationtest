#!/bin/bash

# Step 1: Log in to serverb as the student user (assuming you are logged in already)
# ssh student@serverb

# Step 2: Create the /home/student/grading directory
mkdir -p /home/student/grading

# Step 3: Create empty files grade1, grade2, and grade3 using brace expansion
touch /home/student/grading/grade{1,2,3}

# Step 4: Copy the first five lines of /home/student/bin/manage to /home/student/grading/review.txt
head -5 /home/student/bin/manage > /home/student/grading/review.txt

# Step 5: Append the last three lines of /home/student/bin/manage to /home/student/grading/review.txt
tail -3 /home/student/bin/manage >> /home/student/grading/review.txt

# Step 6: Copy /home/student/grading/review.txt to /home/student/grading/review-copy.txt
cp /home/student/grading/review.txt /home/student/grading/review-copy.txt

# Step 7: Automate the text modifications with sed:
# 1. Duplicate the Test JJ line
# 2. Remove the Test HH line
# 3. Add a new line "A new line" between Test BB and Test CC

# Duplicate "Test JJ" by appending it after the first occurrence
sed -i '/Test JJ/a Test JJ' /home/student/grading/review-copy.txt

# Remove "Test HH" line
sed -i '/Test HH/d' /home/student/grading/review-copy.txt

# Add "A new line" between "Test BB" and "Test CC"
sed -i '/Test BB/a A new line' /home/student/grading/review-copy.txt

# Step 8: Create a hard link to grade1
ln /home/student/grading/grade1 /home/student/hardcopy

# Step 9: Create a symbolic link to grade2
ln -s /home/student/grading/grade2 /home/student/softcopy

# Step 10: List the contents of /boot and save to longlisting.txt
ls -l /boot > /home/student/grading/longlisting.txt

# Final Step: Exit the session
exit
