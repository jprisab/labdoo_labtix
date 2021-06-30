#!/bin/bash
cp -rf * /root/.
umount -l $(findmnt -T . -o TARGET | grep "/")
umount -l /mnt
cd /root/
bash autodeploy.sh
