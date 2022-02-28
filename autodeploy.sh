#!/bin/bash
cp -rf * /root/.
for i in $(findmnt  -lo target | grep "/media/"); do echo "Unmounting - $i"; sudo umount -l $i; done
umount -l /mnt
cd /root/
bash labdoo_sanitize_main.sh $1
