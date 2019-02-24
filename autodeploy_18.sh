#!/bin/bash
#version 0.50 by Javier Prieto Sabugo (javier.prieto@labdoo.org, Labdoo Hub München (Germany)) [30/08]
#Cosmetic Corrections
#Modified to offer offer all the languages added in the v0.50 of install_labdoo_contents [ES / EN / SW / AR / HI / DE / FR / NE / ID / PT / ZH / RU / RO / IT / FA]
#Modified to call install_labdoo_contents leaving 10Gb free disk space

#This script comes without  warranty.

red_colour=$'\e[1;31m'
yellow_colour=$'\e[1;33m'
end_colour=$'\e[1;0m'

#
#INDEX OF THE PARTS OF THE SCRIPT 
####
# CONFIGURATION REQUIRED!!! Please configure in PART0 the Images you have in your Hard Drive
###
# PART0: CONFIG PARAMETERS
# PART1: CHECK THAT OS is booted is in the same architecture as the system is, to avoid restoring in a wrong OS mode
# PART2: Check that the configured SOURCE path has some images on it
# PART3: Check the paramters of the system to see wich images we can use (Architecture and disk size)
# PART4: Ask the desired language of the IMAGE and propose and calculate images to install based on architecture and disksize 
# PART5: Ask Some additional questions (change hositid, skip shredding, what to do when finished)
# PART6: Since the deletion is going to start and give you some time, gather the parameters, in case you want to copy down
# PART7: Shreding
# PART8: RESTORE Redimension the partition table, check filesystem and call it a day
# PART9: If user selected, set the new hostid
# PART10: If user selected, shut down or suspend
###
 
 
#NOW IS WHERE YOU DEFINE YOUR IMAGES
#ARCHITECTURE,LANGUAGE,MIN_DISK_SIZE.NAME_OF_IMAGE they are the directories you have
AVAILABLE_IMGS=(
        "32,EN,40,PAE32_18_04_LTS"
	"32,EN,80,PAE32_18_04_LTS_EN_80"
	"32,ES,80,PAE32_18_04_LTS_ES"
	"32,FR,80,PAE32_18_04_LTS_FR"
        "64,EN,40,PAE64_18_04_LTS"
        "64,EN,80,PAE64_18_04_LTS_EN_80"
	"64,EN,160,PAE64_18_04_LTS_EN_160"
	"64,EN,200,PAE64_18_04_LTS_EN_250"
	"64,ES,80,PAE64_18_04_LTS_ES"
	"64,FR,80,PAE64_18_04_LTS_FR"
	"64,DE,120,PAE64_18_04_LTS_Refugees_DE"
)


#PART 0 : Select disks
AVAILABLE_DISKS=$(fdisk -l | grep Disk | grep sd | awk -F',' '{print $1}')


printf "${red_colour}Welcome to the LABDOO shreding and restoring tool! Thank you for helping the project${end_colour}\n"
printf "${yellow_colour}Select the DISK you want to ${red_colour}DELETE${yellow_colour} and RESTORE your image IN${end_colour} \n"
read -p "Available DISKS:
$AVAILABLE_DISKS
[Valid format: sda / sdb / sdc /...]
->" target_disk

printf "${yellow_colour}Select the DISK you want to use as ${red_colour}SOURCE ${yellow_colour} of the images to restore ${end_colour} (please be aware that the script is expecting a determined directory tree structure, please read the instrucitons for further info)\n"
read -p "$AVAILABLE_DISKS
[Valid format: sda / sdb / sdc /... / (samba) ]
->" source_disk





if [ $source_disk = "samba" ]; then
	# mount the following CIFS Share (uncomment and adjust settings to your CIFS/SMB share if available)
	#SMB 1.0: mount -t cifs -o user="administrator,domain=images,password=xxxxxxx" "//192.168.1.xx/images" /home/partimag
	#SMB 2.0: mount -t cifs -o vers=2.0,username=administrator,domain=images,password=xxxxxxx //192.168.1.xx/images /home/partimag
	printf "${yellow_colour}SAMBA MOUNTING Selected${end_colour}: This will mount the folder, you configured, using samba on the script into the folder [/home/partimag] If something fails, please review next line of script to adjust to your system settings\n"
	mount -t cifs -o vers=2.0,username=administrator,domain=images,password=xxxx //192.168.2.94/images /home/partimag
	if [ $?  -eq 0 ]; then
		printf "Looks like the samba mounting succeeded, please continue\n"
	else
		printf "Looks like the samba mounting ${red_colour}FAILED ${end_colour} as stated previously I would recommend you to review the mounting command\n"
		read -p "Press Ctrl-C to exit or Enter to continue<-  " ANSWER
	fi
		
else
	source_disk="${source_disk}1"
	umount /dev/$source_disk
	printf "PROGRAM WILL WORK USING ${red_colour}/dev/${source_disk} as SOURCE HD ${end_colour} to read the images from and ${red_colour} $target_disk as DESTINATION${end_colour} (will be deleted), if that is NOT what you wanted, please exit immediatly BEFORE YOU DELETE THE WRONG DISK\n"
	read -p "Press Ctrl-C to exit or Enter to continue<-  " ANSWER
	umount /home/partimag 2> /dev/null
	rmdir /home/partimag 2> /dev/null
	mkdir /home/partimag
	mount /dev/$source_disk /home/partimag 
fi






printf "${yellow_colour}THESE ARE THE IMAGES that I can see in the directory. They should match the ones you have configured in the script${end_colour}\n"

ls  -alrt /home/partimag | grep PAE






###
# PART1: CHECK THAT OS is booted is in the same architecture as the system is, to avoid restoring in a wrong OS mode
###
#
#Evaluate architecture of processor
lscpu | grep 64-bit
if [ $? -eq 0 ]
then 
architecture="64"
else
architecture="32"
fi

#Evaluate architecture in which the OS is booted
architecture_os=$(uname -m) # i686 if 32b / x86_64 if 64bit

#Check that both match otherwise exit
if [[ ( "$architecture" -eq 64 && "$architecture_os" = "x86_64" ) || ( "$architecture" -eq 32 && "$architecture_os" = "i686" ) ]]; then
	echo "OS is $architecture_os and Processor is $architecture bit. The architecture are aligned, continue."
else
	printf "${red_colour}OS is $architecture_os and Processor is $architecture bit. If you are using LABTIX You can go ahead
If you are using Parted Magic you should reboot in $architecture Bit Mode. Otherwise your restore might not work (this problem is only seen in PartedMagic)${end_colour}\n"
	read -p "Press Ctrl-C to exit or Enter to continue<-  " ANSWER
fi






###
# PART2: Check that the configured SOURCE path has some images on it // Removed, it will be checked after selecting the image
###




###
# PART3: Check the paramters of the system to see wich images we can use (Architecture and disk size)
###
#Evaluate disk size

disksize=$(lsblk -b /dev/$target_disk -n -o SIZE |head -n 1)
echo "Disksize read: $disksize" >/root/labdoo_install.log
disksizeGB=$(expr $disksize / 1073741824)    # Get the size and Gb will be much more clear
echo "Disksize read by autodeploy script in Gb: $disksizeGB" >/root/labdoo_install.log
echo "Disksize read by autodeploy script in Gb: $disksizeGB"
echo "Architecture read: $architecture" >>/root/labdoo_install.log
echo "Architecture read: $architecture"

###
# PART4: Ask the desired language of the IMAGE and propose and calculate images to install based on architecture and disksize
###

printf "${yellow_colour}Images CONFIGURED as Available ${end_colour}\n"
printf "${yellow_colour}ARCHITECTURE,LANGUAGE,MIN_DISK_SIZE.NAME_OF_IMAGE ${end_colour}\n"	
for line in "${AVAILABLE_IMGS[@]}"
do
	echo "$line"
done


if [ "$architecture" -eq 64 ]; then
	USABLE_IMGS=(${AVAILABLE_IMGS[@]//32*})
elif [ "$architecture" -eq 32 ]; then
	USABLE_IMGS=(${AVAILABLE_IMGS[@]//64*})
else
	echo "I AM HAVING PROBLEM FINDING IMAGES FOR YOUR ARCHITECTURE"
	echo "SORRY, NEED TO LEAVE"
	exit
fi


USABLE_IMGS2=()
read -p "

So the OPERATIVE SYSTEM DISK IMAGE of which of these language do you want to install? [ EN / DE / ES / FR ] <-  " ANSWER
LANGUAGE=`echo $ANSWER | awk '{print toupper($0)}'`	
UANSWER=",$LANGUAGE,"
for line in "${USABLE_IMGS[@]}"
do
	if [[ $line = *"$UANSWER"* ]]; then

	        USABLE_IMGS2+=("$line")
	fi
done

USABLE_IMGS3=()
for line in "${USABLE_IMGS2[@]}"
do
	imagesize=$(echo $line | awk -F',' '{print $3}')
	if  [[ $imagesize -lt $disksizeGB ]]; then
		USABLE_IMGS3+=("$line")	
	fi
done
printf "${yellow_colour}Images I CAN Deploy in this computer based on your ARCHITECTURE = $architecture, your LANGUAGE DECISSION = $LANGUAGE and your DISK SIZE = $disksizeGB GB ${end_colour} \n"

printf "${yellow_colour}ARCHITECTURE,LANGUAGE,MIN_DISK_SIZE.NAME_OF_IMAGE ${end_colour}\n"		
for i in "${!USABLE_IMGS3[@]}"
do
	echo "$i - ${USABLE_IMGS3[$i]}"
done


read -p "

So Select the number representing the option you want to install [ 0 / 1 / ... ] 
->  " ANSWER

IMAGEDIRTOINSTALL=$(echo ${USABLE_IMGS3[$ANSWER]} | awk -F',' '{print $4}')
printf "${red_colour}SELECTED: $IMAGEDIRTOINSTALL ${end_colour}\n"		

#Check if no image found, exit here
if [ ! -d "/home/partimag/$IMAGEDIRTOINSTALL" ]; then
	echo "The Selected Image directory $IMAGEDIRTOINSTALL does not exist in the HD root directory, please check it. 
...Exiting...."
    exit 1
fi

###
# PART5: Ask Some additional questions (change hositid, skip shredding, what to do when finished)
###

# PART5a: Ask if you want to change hostid
printf "${yellow_colour}If you want to want to set already a host-id, it can be automatically set during restore, just need to give me the 5 last numbers labdoo-0000xxxxx${end_colour}\n"		
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


#PART5b: Ask if you want to SKIP SHRED [For part 7]
printf "\n -------------------------------------------\n${yellow_colour}Do you want to avoid shreding? ${end_colour} Remember that Labdoo.org commits to the deletion of all the contents on the laptops provided
Dont choose this if you dont have a real good reason (brand new HD for example). \n"



read -p "If you are COMPLETELY sure you want to skip disk deletion type exactly [YeS] (or 1 or 2)  [NORMALLY JUST PRESS ENTER for normal Labdoo restoration]
->  " avoid_shred


#PART5c: Ask additional contents installation[For part 9-b]
printf "\n -------------------------------------------\n  ${yellow_colour}YOU CAN INSTALL ADDITIONAL CONTENTS!! ${end_colour} Remember that you need to have the install_content_labdoo script properly configured and the contents to install stored in your SOURCE disk following an specific directory tree structure (please check the documentation if you have any doubt) \n "



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





###
#PART5d : Ask if you want to shutdown after finishing the deployment [Question for part 10]
###

printf "${yellow_colour}After everything finishes please select if you want the program to suspend or shutdown the machine
0) Do Nothing
1) PowerOff
2) Suspend (recommended)  ${end_colour} \n"

read -p " Select [ 0 / 1 / 2 ]<-  " shutdown_after_deploy



###
# PART6: Since the deletion is going to start and give you some time, gather the parameters, in case you want to copy down
###
#Javier: Collect and show some info, to make the wait a bit shorter :)
no_of_CPU_cores=`lscpu | grep -m 1 "CPU(s)" | awk -F ' ' '{print $2}'`

CPU_freq_max_MHz=`lscpu | grep -m 1 "MHz:" | awk -F ' ' '{print $3}' | awk -F ',' '{print $1}'`

DISK_size_Gb=`lsblk -b --output SIZE -n -d /dev/$target_disk`
DISK_size_Gb=$((DISK_size_Gb / 1000000000))
 
MEM_size_Mb=`free mem | grep -m 1 "Mem:" | awk -F ' ' '{print $2}'`
MEM_size_Mb=$((MEM_size_Mb / 1000))

#Commenting Serial Number, LabtiX does not have lshw installed
#SERNUM=`sudo lshw | grep -m 1 -i seri | awk -F ' ' '{print $2}'`


echo "--------------------------------------------------"
echo "    These are the current values, you might want to write them down"
echo "--------------------------------------------------"
    echo "Nr of CPU cores:  $no_of_CPU_cores"
    echo "CPU max Freq:     $CPU_freq_max_MHz [MHz]"
    echo "HD Size:          $DISK_size_Gb [Gb]"
    echo "MEM_size_Mb:      $MEM_size_Mb [Mb]"
 #   echo "Serial Number:    $SERNUM"
echo "--------------------------------------------------"

echo "--------------------------------------------------" >>/root/labdoo_install.log
echo "    These are the current values, you might want to write them down" >>/root/labdoo_install.log
echo "--------------------------------------------------" >>/root/labdoo_install.log
    echo "Nr of CPU cores:  $no_of_CPU_cores" >>/root/labdoo_install.log
    echo "CPU max Freq:     $CPU_freq_max_MHz [MHz]" >>/root/labdoo_install.log
    echo "HD Size:          $DISK_size_Gb [Gb]" >>/root/labdoo_install.log
    echo "MEM_size_Mb:      $MEM_size_Mb [Mb]" >>/root/labdoo_install.log
#    echo "Serial Number:    $SERNUM" >>/root/labdoo_install.log
echo "--------------------------------------------------" >> /root/labdoo_install.log



###
# PART7: Shreding
###
#Shred disk

if [ "$avoid_shred" = "YeS" ]; then
	printf "${red_colour}SKIPPING DELETION of $target_disk  will start now. I hope you had a REAL GOOD REASON for that. Deletion of the data on donated devices is a pilar of Labdoo.org... ${end_colour} \n"

elif [ "$avoid_shred" = "1" ]; then
	printf "${yellow_colour}Removing data from $target_disk  will start now. It will only go thorugh de disk 1 time, but you should already know... ${end_colour} \n"
 	shred -n 1 /dev/$target_disk -v -f

elif [ "$avoid_shred" = "2" ]; then
	printf "${yellow_colour}Removing data from $target_disk will start now. It will only go thorugh de disk 2 times... ${end_colour} \n"
 	shred -n2 /dev/$target_disk -v -f

else
	printf "${yellow_colour}Removing data from $target_disk will start now. It will last a while, shred will do through the disk 3 times...  ${end_colour} \n"
 	shred /dev/$target_disk -v -f
fi



###
# PART8: RESTORE Redimension the partition table, check filesystem
###

ocssr=$(which ocs-sr)
$ocssr -g auto -e1 auto -e2 -batch -r -icds -scr -j2 -p true restoredisk "$IMAGEDIRTOINSTALL" $target_disk	

rootuuid=$(blkid |grep ext4 |awk -F'\"' '{print $2}')


echo "rootuuid = $rootuuid"
startpart=$(parted /dev/$target_disk print |grep ext4 |awk '{print $2}')
echo "Partition start at: $startpart" >>/root/labdoo_install.log
echo "UUID ROOT: $rootuuid" >>/root/labdoo_install.log
parted -s /dev/$target_disk rm 1

#Recreate sda1 larger and reset UUID and boot flag
parted -s -a optimal /dev/$target_disk mkpart primary ext4 -- "$startpart" -0
target_disk_1="${target_disk}1"
tune2fs /dev/$target_disk_1 -U "$rootuuid"
parted -s /dev/$target_disk set 1 boot on

#Fsck FS and resize
sleep 2
e2fsck -pf /dev/$target_disk_1
sleep 2
resize2fs /dev/$target_disk_1

#Write install.log
mount /dev/$target_disk_1 /mnt
cp /root/labdoo_install.log /mnt/root/labdoo_install.log




###
# PART9: If user selected, set the new hostid
###
#Change hostid

if [ '$hostidnumber' = 'labdoo-00001xxxx' ]; then
	echo "Not Setting new hostid"
else
	echo "Setting new hostid ${hostidnumber} as requested"
	echo "autodeploy setted a new hostid ${hostidnumber} as requested" >> /root/labdoo_install.log
	sed -i "s/labdoo-00001xxxx/${hostidnumber}/g" /mnt/etc/hosts
        sed -i "s/labdoo-00001xxxx/${hostidnumber}/g" /mnt/etc/hostname
	
fi;




#bash install_labdoo_contents.sh -l <language> -s <source contents> -d <destination contetns> -f <Megas to be left free during restoration>

 ##LO QUE VENDRA EN 9-b
for line in "${languages_install[@]}"
do
	printf "\nTrying to the contents for language  ${yellow_colour} $line ${end_colour} as requested until disk is almost full [leave 10Gb Free]\n "
	printf "\nEXECUTING: bash install_labdoo_contents.sh -l $line -s <source contents> -d <destination contetns> -f 10000 \n " 
	bash install_labdoo_contents.sh -l $line -s /home/partimag -d /mnt/home/labdoo/Public -f 10000

done



umount /home/partimag
printf "You can find the restored content under /mnt in case you want to check something... \n " 
#umount /mnt




###
# PART10: If user selected, shut down or suspend
###
#Optionally shutdown Computer
if [ $shutdown_after_deploy -eq 1 ]; then
	poweroff
elif [ $shutdown_after_deploy -eq 2 ]; then
	pm-suspend
	printf "\n${red_colour} ....WAKING UP ${end_colour} \n "
	printf "\n${red_colour} AUTODEPLOY SCRIPT FINISHED ${end_colour} \n "
	read -p "Press Ctrl-C to exit or Enter to continue<-  " ANSWER
else
	printf "\n${red_colour} AUTODEPLOY SCRIPT FINISHED ${end_colour} \n "
	read -p "Press Ctrl-C to exit or Enter to continue<-  " ANSWER	
fi

