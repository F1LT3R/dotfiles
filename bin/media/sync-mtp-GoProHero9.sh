#!/bin/bash

##echo "running" >> /home/user/test.txt

# Replace /media/mtpdevice with the mount point of your MTP device
MTP_MOUNT_POINT="/run/user/1000/gvfs/mtp:host=GoPro_HERO9_C3441324652331/GoPro MTP Client Disk Volume/DCIM"
# Replace /path/to/destination/folder with the actual path to your local destination folder
DESTINATION_FOLDER="/media/user/Data/MediaSync/GoProHero9DCIM"

#fusermount -u "$MTP_MOUNT_POINT"

# Mount the MTP device
#jmtpfs "$MTP_MOUNT_POINT"

# ls -la "$MTP_MOUNT_POINT" > /home/user/test.txt

# Sync the contents from the MTP device to the destination folder
rsync -avP --info="progress2" "$MTP_MOUNT_POINT/" "$DESTINATION_FOLDER/" &

Receip numer Lahey Health: 72-57-689