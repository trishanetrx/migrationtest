#!/bin/bash

# Step 1: Create a 2 GiB partition on the /dev/vdb disk for LVM
parted /dev/vdb mklabel msdos
parted /dev/vdb mkpart primary 1MiB 2GiB
parted /dev/vdb set 1 lvm on

# Step 2: Declare /dev/vdb1 as a physical volume and create the volume group
pvcreate /dev/vdb1
vgcreate extra_storage /dev/vdb1

# Step 3: Create a 1 GiB logical volume vol_home
lvcreate -L 1GiB -n vol_home extra_storage

# Step 4: Format the vol_home logical volume with the XFS file system
mkfs -t xfs /dev/extra_storage/vol_home

# Step 5: Create /user-homes directory and mount vol_home persistently
mkdir -p /user-homes
vol_home_uuid=$(blkid -s UUID -o value /dev/extra_storage/vol_home)
echo "UUID=$vol_home_uuid /user-homes xfs defaults 0 0" >> /etc/fstab
mount /user-homes

# Step 6: Create /local-share directory and configure NFS mount from servera
mkdir -p /local-share
echo "servera.lab.example.com:/share /local-share nfs rw,sync 0 0" >> /etc/fstab
mount /local-share

# Step 7: Create a 512 MiB swap partition on /dev/vdc and activate it
parted /dev/vdc mklabel msdos
parted /dev/vdc mkpart primary linux-swap 1MiB 513MiB
mkswap /dev/vdc1
swap_uuid=$(blkid -s UUID -o value /dev/vdc1)
echo "UUID=$swap_uuid swap swap defaults 0 0" >> /etc/fstab
swapon -a

# Step 8: Create production group and production1-4 users
groupadd production
for i in 1 2 3 4; do useradd -G production production$i; done

# Step 9: Configure /run/volatile for time-based deletion with 0700 permissions
echo "d /run/volatile 0700 root root 30s" > /etc/tmpfiles.d/volatile.conf
systemd-tmpfiles --create /etc/tmpfiles.d/volatile.conf

# End of script
