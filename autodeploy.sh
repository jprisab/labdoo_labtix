#!/bin/bash
cp -rf * /root/.
umount -l $(findmnt -T . -o TARGET | grep "/")
umount -l /mnt
cd /root/
bash labdoo_sanitize_main.sh $1
