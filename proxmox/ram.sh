#sudo mount -t tmpfs -o size=20480M tmpfs /ram/disktoram/

#!/bin/bash

#probe the device
modprobe brd rd_size=22000000

#create the device
pvcreate /dev/ram0


#create volumegroup
vgcreate vgramdisk /dev/ram0

#create lvm partition
lvcreate -L 20G -n ramstorage vgramdisk

#make filsystem
mkfs.ext2 /dev/vgramdisk/ramstorage

#mount the filesystem
mount -o noatime /dev/vgramdisk/ramstorage /mnt/ramstorage
sleep 10
echo "ramstorage created"

