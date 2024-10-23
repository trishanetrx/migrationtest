#!/bin/bash

# Step 1: Create the /review5-disk directory
mkdir -p /review5-disk

# Step 2: Mount the vdb1 block device on /review5-disk
mount /dev/vdb1 /review5-disk

# Step 3: Verify that the block device is mounted
df -Th | grep "/review5-disk"

# Step 4: Locate the review5-path file and save its absolute path in /review5-disk/review5-path.txt
review5_path=$(find / -iname review5-path 2>/dev/null)
echo $review5_path > /review5-disk/review5-path.txt

# Step 5: Locate all files owned by contractor1 and contractor group with 640 permissions
find / -user contractor1 -group contractor -perm 640 2>/dev/null > /review5-disk/review5-perms.txt

# Step 6: Locate all files with exactly 100 bytes in size and save their paths in /review5-disk/review5-size.txt
find / -size 100c 2>/dev/null > /review5-disk/review5-size.txt

# Step 7: Verify the contents of all generated files
echo "Contents of /review5-disk/review5-path.txt:"
cat /review5-disk/review5-path.txt

echo "Contents of /review5-disk/review5-perms.txt:"
cat /review5-disk/review5-perms.txt

echo "Contents of /review5-disk/review5-size.txt:"
cat /review5-disk/review5-size.txt

# End of the script
