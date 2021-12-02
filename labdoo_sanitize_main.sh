#!/bin/bash
#version 0.61 by Javier Prieto Sabugo (javier.prieto@labdoo.org, Labdoo Hub München (Germany)) [09/2019]
#version 2.0 by Javier Prieto Sabugo (javier.prieto@labdoo.org, Labdoo Hub München (Germany)) [05/2021]
#Changed the contents install for call to install_labdoo_contents_kiwix.#!/bin/sh
#Add option to remove autostart firefox and teams
#version 3.1 by Javier Prieto Sabugo (javier.prieto@labdoo.org, Labdoo Hub München (Germany)) [11/2021]
#Include calling ATA Secure Erase if possible

red_colour=$'\e[1;31m'
yellow_colour=$'\e[1;33m'
end_colour=$'\e[1;0m'

#Size to leave free in the HD, when installing additional contents, we need to set a thereshold to guarantee that disk is not getting full
HDSIZELEAVEFREE=10000

#
#INDEX OF THE PARTS OF THE SCRIPT
####
# CONFIGURATION REQUIRED!!! Please configure in PART0 the Images you have in your Hard Drive
###
# PART0: CONFIG PARAMETERS
# PART 1 : Select disks
# PART2: Check that the configured SOURCE path has some images on it select image
# PART4: Ask the desired language of the IMAGE and propose and calculate images to install based on architecture and disksize
# PART3: Ask Some additional questions (change hositid, skip shredding, what to do when finished)
# PART4: Since the deletion is going to start and give you some time, gather the parameters, in case you want to copy down
# PART5: Shreding
# PART6: RESTORE Redimension the partition table, check filesystem and call it a day
# PART7: If user selected, set the new hostid, install contents, additional config
# PART8: If user selected, shut down or suspend
###

#READ VALUES FROM CONNECTED DISKS
mapfile -t AVAILABLE_DISKS < <(fdisk -l | grep Disk | grep sd | awk -F',| ' '{print $2" "$3" "$4}' )
mapfile -t AVAILABLE_PARTITIONS < <(fdisk -l  | grep '^/dev/'  )

printf "${red_colour}Welcome to the LABDOO shreding and restoring tool! ${end_colour}
The following script will allow you in a very easy way to perform the steps to:
1.- Delete all the contents of the internal Hard Disk of the laptop where it is being executed
2.- Restore one of the Labdoo Prepared images in one of our main Languages (ES,EN,DE,FR) if available in your connected USB Hard Drive
3.- Set the hostname of the restored machine
4.- If desired, automatically copy additional KIWIX contents if available in your connected USB Hard Drive
For this to success, we wpill need to gather some information before all the automatization starts
"


#PART 1 : Select disks

printf "\n-------------------------------------------------------------------------"
printf "\n${yellow_colour}Select the DISK you want to have ${red_colour}ERASED${yellow_colour}, where the Labdoo image will be restored afterwards${end_colour}\n"
for i in "${!AVAILABLE_DISKS[@]}"
do
	echo "$i - ${AVAILABLE_DISKS[$i]}"
done

read -p "[ 0 / 1 / 2 / 3 ... ]
->  " ANSWER

target_disk=$(echo ${AVAILABLE_DISKS[$ANSWER]} | awk -F':' '{print $1}')
printf "${red_colour}SELECTED: $target_disk ${end_colour}\n"

printf "\n-------------------------------------------------------------------------"
printf "\n${yellow_colour}Select the PARTITION where you have stored the Labdoo IMAGES to restore${end_colour} \n"

for i in "${!AVAILABLE_PARTITIONS[@]}"
do
	echo "$i - ${AVAILABLE_PARTITIONS[$i]}"
done

read -p "[ 0 / 1 / 2 / 3 ... ]
->  " ANSWER

source_partition=$(echo ${AVAILABLE_PARTITIONS[$ANSWER]} | awk -F' ' '{print $1}')
printf "${red_colour}SELECTED: $source_partition ${end_colour}\n"

printf "\n-------------------------------------------------------------------------"
printf "\n${yellow_colour}Select the PARTITION where you have stored the ADDITIONAL CONTENT ${end_colour} Or enter for not adding additional content at all\n"

for i in "${!AVAILABLE_PARTITIONS[@]}"
do
	echo "$i - ${AVAILABLE_PARTITIONS[$i]}"
done

read -p "[ 0 / 1 / 2 / 3 ... ]
->  " ANSWER

addcontent_disk=$(echo ${AVAILABLE_PARTITIONS[$ANSWER]} | awk -F' ' '{print $1}')
printf "${red_colour}SELECTED: $source_partition ${end_colour}\n"




umount $source_partition 2> /dev/null
printf "\n--------------------------------------------------------------------------"
printf "\n\nPROGRAM WILL ERASE  ${red_colour} $target_disk ${end_colour} and restore an image stored in ${red_colour} $source_partition ${end_colour}\n"
read -p "Press Ctrl-C to exit or Enter to continue<-  " ANSWER
umount /home/partimag 2> /dev/null
rmdir /home/partimag 2> /dev/null
mkdir /home/partimag
mount $source_partition /home/partimag





###
# PART2: Check the paramters of the system
###
#Evaluate disk size
disksize=$(lsblk -b $target_disk -n -o SIZE |head -n 1)
disksizeGB=$(expr $disksize / 1073741824)    # Get the size and Gb will be much more clear

echo "Disksize Available in the Hard DRIVE  ${target_disk} ${red_colour} $disksizeGB Gbs ${end_colour}"
echo "Searching for labdoo images in your External USB HD ${source_partition}"


AVAILABLE_IMGS=($(find  /home/partimag -maxdepth 5 -type d -print | grep PAE | grep -E 'LTS'))
printf "\n--------------------------------------------------------------------------"
printf "\n${yellow_colour}These are the Images you can install,So Select the number representing the option you want to install  ${end_colour}\n keep in mind the notation:  \n <language> is the main language of the system restored [ES/EN/DE/FR] \n <minSize> is the minimum required HD size of the machine where you restore that Image\n"
for i in "${!AVAILABLE_IMGS[@]}"
do
	echo "$i - ${AVAILABLE_IMGS[$i]}"
done


read -p "[ 0 / 1 / 2 / 3 ... ]
->  " ANSWER

IMAGEDIRTOINSTALL=$(echo ${AVAILABLE_IMGS[$ANSWER]})
printf "${red_colour}SELECTED: $IMAGEDIRTOINSTALL ${end_colour}\n"

#Check if no image found, exit here
if [ ! -d "$IMAGEDIRTOINSTALL" ]; then
	echo "The Selected Image directory $IMAGEDIRTOINSTALL does not exist in the HD root directory, please check it.
...Exiting...."
    exit 1
fi

###
# PART3: Ask Some additional questions (change hositid, skip shredding, what to do when finished)
###

# PART3a: Ask if you want to change hostid
printf "\n--------------------------------------------------------------------------"
printf "\n${yellow_colour}If you want to want to set already a host-id, it can be automatically set during restore, just need to give me the 5 last numbers labdoo-0000xxxxx${end_colour}\n"
read -p "Write the xxxxx in labdoo-0000xxxxx if your input is empty, then the hostid will not be modified by this script <-  " ANSWER
hostidnumber="labdoo-00001xxxx"
echo $ANSWER| grep "[0-9][0-9][0-9][0-9][0-9]"
if  [[ $? -eq "0" ]]; then
	printf "${yellow_colour}Selection registered${end_colour}\n"
	hostidnumber="labdoo-0000${ANSWER}"
	echo  "NEW host ID will be set to $hostidnumber"
else
	printf "${yellow_colour}Ok, but do not forget to set a new hostid yourself after the restore ${end_colour}\n"
fi


#PART3b: Ask if you want to SKIP SHRED [For part 7]
printf "\n--------------------------------------------------------------------------"
printf "\n${yellow_colour}Do you want to avoid shreding? ${end_colour} Remember that Labdoo.org commits to the deletion of all the contents on the laptops provided
Dont choose this if you dont have a real good reason (brand new HD for example). \n"

read -p "If you are COMPLETELY sure you want to skip disk deletion type exactly [YeS] (or 1 or 2)  [NORMALLY JUST PRESS ENTER for normal Labdoo restoration]
->  " avoid_shred


#PART3c: Ask additional contents installation[For part 9-b]
printf "\n -------------------------------------------\n
 ${red_colour}YOU CAN INSTALL ADDITIONAL CONTENTS!! ${end_colour}
 Remember that you need to have the install_content_labdoo script properly configured and the contents to install stored in your SOURCE disk following an specific directory tree structure (please check the documentation if you have any doubt) \n "
printf "\nSelect the languages you want the labdoo_install_content to install afterwards:
Do not be afraid, if something was already installed, the script will skip it
The disk will never get full (we leave a 10Gb free space)
Indicate the comma separated values for the contents you want to install (empty if none)
${yellow_colour} Currently supported languages: [ES / EN / SW / AR / HI / DE / FR / NE / ID / PT / ZH / RU / RO / IT / FA] ${end_colour}
Comma separated values will install multiple languages: ie: EN (English only) / SW,EN (Swahili+English) / ES,SW,EN (Spanish+Swahili+English)   ...ES,EN,SW,AR,HI,DE,FR,NE,ID,PT,ZH,RU,RO,IT,FA (all of them :) )"

read -p "[ EN / SW,EN / ES,FA,EN / ... ]
->  " languages_contents

OIFS=$IFS
IFS=","
languages_install=($languages_contents);


#PART3d: Ask if you want to REMOVE autostart [For part 7]
printf "\n -------------------------------------------\n${yellow_colour}Do you want to remove autostart of Firefox and Teams in the installed system? ${end_colour}
Some users do not want to have firefox automatically started \n"

read -p "If you want to remove it type [y] [JUST PRESS ENTER for normal Labdoo restoration]
->  " remove_autostart

###
#PART3e : Ask if you want to shutdown after finishing the deployment [Question for part 10]
###

printf "${yellow_colour}After everything finishes please select if you want the program to suspend or shutdown the machine
0) Do Nothing
1) PowerOff
2) Suspend (recommended)  ${end_colour} \n"

read -p " Select [ 0 / 1 / 2 ]
->  " shutdown_after_deploy



###
# PART4: Since the deletion is going to start and give you some time, gather the parameters, in case you want to copy down
###
#Javier: Collect and show some info, to make the wait a bit shorter :)
no_of_CPU_cores=`lscpu | grep -m 1 "CPU(s)" | awk -F ' ' '{print $2}'`

CPU_freq_max_MHz=`lscpu | grep -m 1 "max MHz:" | awk -F ' ' '{print $4}' | awk -F ',' '{print $1}'`

DISK_size_Gb=`lsblk -b --output SIZE -n -d $target_disk`
DISK_size_Gb=$((DISK_size_Gb / 1000000000))

MEM_size_Mb=`free mem | grep -m 1 "Mem:" | awk -F ' ' '{print $2}'`
MEM_size_Mb=$((MEM_size_Mb / 1000))

SERIAL_NUMBER=`dmidecode -s system-serial-number`




echo "--------------------------------------------------"
echo "These are the values on your system"
echo "--------------------------------------------------"
    echo "Labdoo ID Number: $hostidnumber"
    echo "Nr of CPU cores:  $no_of_CPU_cores"
    echo "CPU max Freq:     $CPU_freq_max_MHz [MHz]"
    echo "HD Size:          $DISK_size_Gb [Gb]"
    echo "MEM_size_Mb:      $MEM_size_Mb [Mb]"
    echo "Serial Number:    $SERIAL_NUMBER"


###
# PART5: Shreding
###


if [ "$avoid_shred" = "YeS" ]; then
	printf "${red_colour}SKIPPING DELETION of $target_disk  will start now. I hope you had a REAL GOOD REASON for that. Deletion of the data on donated devices is a pilar of Labdoo.org... ${end_colour} \n"

elif [ "$avoid_shred" = "1" ]; then
	printf "${yellow_colour}Removing data from $target_disk  will start now. It will only go thorugh de disk 1 time, but you should already know... ${end_colour} \n"
 	shred -n 1 $target_disk -v -f

elif [ "$avoid_shred" = "2" ]; then
	printf "${yellow_colour}Removing data from $target_disk will start now. It will only go thorugh de disk 2 times... ${end_colour} \n"
 	shred -n2 $target_disk -v -f

else
	printf "\n--------------------------------------------------------------------------"
	printf "\nNew version [2021] of the script allows you to try a ${red_colour}ATA Secure Erase${end_colour}, wich is a much safer and faster metho to whipe the HardDrive (If the HD supports it. If it fails the script will perform a shred like the previous versions)"
	printf "\n${yellow_colour}Do you want to attempt ATA Secure delete on: $target_disk ${end_colour}?\n"
	while true; do
	    read -p "Select [y]es or [n]o?" yn
	    case $yn in
	        [Yy]* ) ATA_DELETE=1; break;;
	        [Nn]* ) ATA_DELETE=0; break;;
	        * ) echo "Please answer yes or no.";;
	    esac
	done

	if [ "$ATA_DELETE" == "1" ]; then
	    echo "You have selected to perform a ATA secure delete in $target_disk, calling:"
			echo "bash labdoo_erase_disk.sh $target_disk"
			bash labdoo_erase_disk.sh $target_disk
			if [ "$?" -eq 0 ]
				then
		 		echo "ATA ERASE EXECUTED CORRECTLY!!!"
			else
				echo "ATA ERASE FAILED!!!   It will continue the OLD autodeploy process with regular shreding of the disk. "
				printf "${yellow_colour}Removing data from $target_disk will start now. It will last a while (hours), shred will go through the disk 3 times...  ${end_colour} \n"
			 	shred $target_disk -v -f
			fi

	else
			    echo "You have selected to skip trying the ATA secure delete in $target_disk, so I will continue with the OLD autodeploy process with regular shreding of the disk. "
					printf "${yellow_colour}Removing data from $target_disk will start now. t will last a while (hours), shred will go through the disk 3 times...  ${end_colour}\n"
				 	shred $target_disk -v -f
	fi

fi



###
# PART6: RESTORE Redimension the partition table, check filesystem
###
IMAGETOINSTALL=${IMAGEDIRTOINSTALL//\/home\/partimag\/}
ocssr=$(which ocs-sr)

$ocssr -g auto -e1 auto -e2 -batch -r -icds -scr -j2 -p true restoredisk "$IMAGETOINSTALL" ${target_disk//\/dev\/}

rootuuid=$(blkid |grep ext4 |awk -F'\"' '{print $2}')


echo "rootuuid = $rootuuid"
startpart=$(parted $target_disk print |grep ext4 |awk '{print $2}')
parted -s $target_disk rm 1

#Recreate sda1 larger and reset UUID and boot flag
parted -s -a optimal $target_disk mkpart primary ext4 -- "$startpart" -0
target_disk_1="${target_disk}1"
tune2fs $target_disk_1 -U "$rootuuid"
parted -s $target_disk set 1 boot on

#Fsck FS and resize
sleep 2
e2fsck -pf $target_disk_1
sleep 2
resize2fs $target_disk_1

#Write install.log
mount $target_disk_1 /mnt
cp /root/labdoo_install.log /mnt/root/labdoo_install.log




###
# PART7: If user selected, set the new hostid
###
#Change hostid

if [ '$hostidnumber' = 'labdoo-00001xxxx' ]; then
	echo "Not Setting new hostid"
else
	echo "Setting new hostid ${hostidnumber} as requested"
	sed -i "s/labdoo-[^ ]*/${hostidnumber}/g" /mnt/etc/hosts
  sed -i "s/labdoo-[^ ]*/${hostidnumber}/g" /mnt/etc/hostname
fi


if [ "$remove_autostart" = "y" ]; then
	printf "${xellow_colour}REMOVING autostart of Firefox and MSTeams as requested ${end_colour} \n"
	rm /mnt/home/labdoo/.config/autostart/firefox.desktop
	rm /mnt/home/labdoo/.config/autostart/teams.desktop
	rm /mnt/home/student/.config/autostart/firefox.desktop
	rm /mnt/home/student/.config/autostart/teams.desktop
fi


#bash install_labdoo_contents.sh -l <language> -s <source contents> -d <destination contetns> -f <Megas to be left free during restoration>
if [[ ! -z "$addcontent_disk" ]]; then
	printf "Mounting additional content disk from $addcontent_disk"
	umount /home/partimag 2> /dev/null
	rmdir /home/partimag 2> /dev/null
	mkdir /home/partimag
	mount $addcontent_disk /home/partimag
fi

#SEARCH for the contents
ROOTDIRECTORYCONTENTS=$(find  /home/partimag -type d -print | grep '\/additional_kiwix_contents$')
#SEARCH for the install labdoo contents script, so that if creating the labtix iso thez put it somewhere else, we can still find it and use it
INSTCONTNTSCRIPT=$(find  . -print | grep install_labdoo_contents_kiwix.sh | head -1)
##LO QUE VENDRA EN 9-b
for line in "${languages_install[@]}"
do
	printf "\nTrying to the contents for language  ${yellow_colour} $line ${end_colour} as requested until disk is almost full [leaving $HDSIZELEAVEFREE Mb Free]\n "
	printf "\nEXECUTING: bash $INSTCONTNTSCRIPT -l $line -s $ROOTDIRECTORYCONTENTS -d /mnt/home/labdoo  \n "
	bash $INSTCONTNTSCRIPT -l $line -s $ROOTDIRECTORYCONTENTS -d /mnt/home/labdoo

done



umount /home/partimag
printf "You can find the restored content under /mnt in case you want to check something... \n "



###
# PART8: If user selected, shut down or suspend
###
#Optionally shutdown Computer
if [ $shutdown_after_deploy -eq 1 ]; then
	poweroff
elif [ $shutdown_after_deploy -eq 2 ]; then
	pm-suspend
	printf "\n${red_colour} ....WAKING UP ${end_colour} \n "
	printf "\n${red_colour} AUTODEPLOY SCRIPT FINISHED ${end_colour} \n "
else
	printf "\n${red_colour} AUTODEPLOY SCRIPT FINISHED ${end_colour} \n "
fi
