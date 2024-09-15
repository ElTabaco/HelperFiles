#!/bin/bash

sudo fdisk -l
echo "Clone SD-Card"
sudo dd bs=4M if=/dev/mmcblk0 of=ssServer_`date +%y%m%d`.img
echo "Resize Immage"
df -h

# https://askubuntu.com/questions/1174487/re-size-the-img-for-smaller-sd-card-how-to-shrink-a-bootable-sd-card-image
echo "Resize SD-Card"
sudo fdisk /dev/mmcblk0
sudo resize2fs /dev/mmcblk0




echo "$(sudo parted -s /dev/sda unit MB print free | tail -n 2 | grep Free | awk '{print $3}' | awk -F 'MB' '{print $1}')"
echo "$(sudo parted -s /dev/sda unit MB print free | grep Free | tail -1 | awk '{print $2}' | grep -o '[0-9]\+')"

sudo parted -s /dev/mmcblk0 resizepart 3 <END> 
sudo e2fsck -fy /dev/mmcblk0




