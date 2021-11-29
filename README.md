

UPDATED!!! Working with Labdoo 20
===========

Description
===========

The scripts bellow allow you to prepare a LABDOO laptop within seconds just by calling the one script launch_autodeploy.sh from a terminal
This script can be used after booting:
via a Labtix, PartedMagic or any other liveCD linux distribution either in graphical mode or after a console boot (if you are experiencing problems to boot LiceCD in graphical mode)


These scripts are designed to automate the restoration of the
images and the content of the labdoo Images shared under http://ftp.labdoo.org/download/install-disk/
allowing to perform a complete end-to-end sanitazion of the laptop in an
unattended way including the additional installaiton of KIWIX resources to enrich the images from the FTP

### **autodeploy.sh** :

This is the main script that starts the whole process
since version 3 you dont need to copy this script locally to the Laptop you are restoring

Just make sure the laboo_labtix (this) folder is in the USB Harddrive that you will use for the images. After booting, mount the HD, call this script (#~> bash autodeploy.sh) and it will take care of invoking the correct commands


### **labdoo_sanitize_main.sh** :

Gathers input from the user on the Drives to be restored/used to store the IMAGES

shredding of the harddrive (optional)

restoration of the selected image

configuration of a new hostid

additional customizations (removal of autostart programs)

deployment of all the additional kiwix contents (shared for Labdoo under http://ftp.labdoo.org/download/install-disk/additional_kiwix_contents )of the languages you choose automatically

### **install_labdoo_contents_kiwix.sh** :

restore all contents that fit on the HD (based upon a configurable
“priority list” of the contents \[kiwix\] downloaded in the
HD) that fit in the HD (leaving an acceptable \[and configurable\]
margin of free space)

### **labdoo_erase_disk.sh** :

It is only called if the user wants to perform an ATA Secure erase in the HDs

Where to obtain the latest version of the scripts
=================================================

You can download or contribute to the code on the github project:

[*https://github.com/jprisab/labdoo\_labtix*](https://github.com/jprisab/labdoo_labtix)



A version of these scripts is included as well in the Labtix iso CD but
because of the release cycle of the Labtix solution it might not contain
the latest corrections/features and hence it is recommended to always
use the newer version of the scripts as described on the chapter
“Copying the scripts after booting Labtix”

Starting the scripts after booting Labtix
========================================

for being sure I work with the latest version of the scripts \[to be
downloaded from https://github.com/jprisab/labdoo_labtix (always may include some improvement or the addition of the extra
content of a new language…) I always have them copied in the same USB HD
where I have the Images and the content I want to restore

1.- Open the File Explorer



2.- select the directory where the scripts are copied



3.- call launch_autodeploy.sh



------------

DISCLAIMER: we are under constant development

latest updated version of this document was for scripts version v3.0

Please visit labdoo.org to keep up with the new developments and submit
your ideas in the forums (and report any bug you may find), submit any
doubt you might have to labdoo support wall

https://www.labdoo.org/content/labdoo-global-support-lgs/activities

Please feel free to modify any script to adapt to your requirements and
preferences
