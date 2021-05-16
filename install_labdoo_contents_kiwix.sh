#!/bin/bash
#Version 0.60 by Javier Prieto Sabugo (javier.prieto@labdoo.org, Labdoo Hub München (Germany))  30/08/2018
#Version 2 by Javier Prieto Sabugo (javier.prieto@labdoo.org, Labdoo Hub München (Germany))  15/05/2021



#sudo bash install_labdoo_contents.sh -l <language> -s <source contents> -d <destination contetns> -f <Megas to be left free during restoration>
red_colour=$'\e[1;31m'
yellow_colour=$'\e[1;33m'
end_colour=$'\e[1;0m'


LANG_CONTENT=""
SOURCE_DIR=""
DEST_DIR=""
MB_TO_BE_LEFT=""




#CHECK THAT THE SCRIPT IS RUN AS ROOT
if [ "$EUID" -ne 0 ]
  then
        echo "Please run as root, otherwise you might have some problems"
        printf "Invoke as:
	${red_colour}sudo ${end_colour} bash $0 -l <language> -s <source contents> -d <destination contents> -f <MBs to be left free during restoration> \n"
  exit
fi


#CHECK PROVIDER PARAMETERS
while getopts l:s:d:f: option
  do
    case "${option}"
        in
        l) LANG_CONTENT=${OPTARG};;
        s) SOURCE_DIR=${OPTARG};;
        d) DEST_DIR=${OPTARG};;
        f) MB_TO_BE_LEFT=$OPTARG;;
    esac
done

if [ ! -d  "$DEST_DIR" ];
	then
	  printf "${red_colour}\nERROR!!!!!!!!!!!!! ${end_colour} Provided Destination directory ${yellow_colour}$DEST_DIR${end_colour} does not exist\n\n"
elif [ ! -d  "$SOURCE_DIR" ];
	then
	  printf "${red_colour}\nERROR!!!!!!!!!!!!! ${end_colour} Provided Source directory ${yellow_colour}$SOURCE_DIR${end_colour} does not exist\n\n"
fi

if [ -z  "$LANG_CONTENT" ] || [ -z "$DEST_DIR" ] || [ -z  "$DEST_DIR" ] || [ ! -d  "$DEST_DIR" ] || [ ! -d  "$SOURCE_DIR" ];
then
  printf "${red_colour}\nERROR!!!!!!!!!!!!!${end_colour} \n ADDITIONAL LABDOO CONTENT INSTALLER Called with wrong paramters, please use: \n\n"
  printf "sudo bash $0 -l <language> -s <source contents> -d <destination contetns> [-f <MBs to be left free>] \n"
  printf "${yellow_colour}language ${end_colour}\n"
  printf "${yellow_colour}source contents${end_colour} should be shoud be one something similar to [/media/labdoo/233DBC957DA13B4D]\n"
  printf "${yellow_colour}destination ${end_colour}needs to be one either  [/home/labdoo] or [/mnt/home/labdoo] \n"
  printf "${yellow_colour}MBs to be left free...${end_colour}well it should be an integer - 10000Mb free is a good value\n"
  printf "${red_colour}\n....breaking.... ${end_colour}\n\n"
  exit 1
fi

#Use default value for the memory
if [  -z  "$MB_TO_BE_LEFT" ];
	then
	  MB_TO_BE_LEFT=10000
		printf "Assigned MB_TO_BE_LEFT=$MB_TO_BE_LEFT by default\n"
fi

    printf "${yellow_colour}LABDOO KIWIX CONTENT INSTALLER YOU HAVE CALLED THE SCRIPT WITH THE FOLLOWING PARAMTERS  ${end_colour}\n"
    printf "${yellow_colour}LANGUAGE:   ${end_colour} $LANG_CONTENT\n"
    printf "${yellow_colour}SOURCE_DIR:   ${end_colour} $SOURCE_DIR\n"
    printf "${yellow_colour}DEST_DIR:   ${end_colour} $DEST_DIR\n"
    printf "${yellow_colour}MB_TO_BE_LEFT:   ${end_colour} $MB_TO_BE_LEFT\n"




#READ THE PRECONFIGURED AVAILABLE CONTENT DEPENDING ON THE LANGUAGE

	if [ -f "$SOURCE_DIR/$LANG_CONTENT/library.xml" ];
		then
  	### Take action if $DIR exists ###
  	echo "Installing config files in $SOURCE_DIR/$LANG_CONTENT/library.xml..."
	else
  	echo "Error: $SOURCE_DIR/$LANG_CONTENT/library.xml not found. Can not continue."
  	exit 1
	fi


#Check if already exists a kiwix library, if not, create one empty
if [ ! -f "$DEST_DIR/.local/share/kiwix/library.xml" ];
	then
	mkdir -p $DEST_DIR/.local/share/kiwix/
	echo "<library version=\"20110515\">" >> $DEST_DIR/.local/share/kiwix/library.xml
  echo "</library>" >> $DEST_DIR/.local/share/kiwix/library.xml
fi


#For each book in the library in the content disk do everything (copy and so on)
while read line; do
if [[ "$line" == *"book"* ]]; then

		SIZEBOOK=$(echo $line | awk -F "size=\"" '{print $2}' | awk -F "\"" '{print $1}')
		FILEZIM=$(echo $line | awk -F "path=\"" '{print $2}' | awk -F "\"" '{print $1}' | awk -F "/" '{print $7}' )
		myFreeHD=$(df $DEST_DIR | tail -1 | awk '{print $4}')
		myFreeHD=$((myFreeHD/1024))  # in MBs
		SIZEBOOK=$((SIZEBOOK/1024))  # in MBs
		REMAINING_INSTALLABLE_MB=$((myFreeHD-MB_TO_BE_LEFT))
		echo "$FILEZIM - takes $SIZEBOOK Mbs"
		if [ "$REMAINING_INSTALLABLE_MB" -gt "$SIZEBOOK" ]; then
			echo "I can install still ${yellow_colour}$REMAINING_INSTALLABLE_MB${end_colour} Mbs so i will do it"
			cp $SOURCE_DIR/$LANG_CONTENT/$FILEZIM $DEST_DIR/Public/kiwix/wikis/.
			sed -i "`wc -l < $DEST_DIR/.local/share/kiwix/library.xml`i\\$line\\" $DEST_DIR/.local/share/kiwix/library.xml
		else
			echo "You only have ${yellow_colour}$myFreeHD${end_colour} Mbs so i SKIPPED it"
		fi
	fi
done < $SOURCE_DIR/$LANG_CONTENT/library.xml





#######
#PART4: Execute the update permissions script
########
chmod -R 777 $DEST_DIR/Public/kiwix/wikis/*
chmod -R 744 $DEST_DIR/.local/share/kiwix/library.xml
chown -R labdoo:labdoo $DEST_DIR/Public/kiwix/wikis/*
chown -R labdoo:labdoo $DEST_DIR/.local/share/kiwix/library.xml
sed -i -e 's/..\/..\/..\/Public/\/home\/labdoo\/Public/g' $DEST_DIR/.local/share/kiwix/library.xml
cp $DEST_DIR/.local/share/kiwix/library.xml $DEST_DIR/../student/.local/share/kiwix/library.xml
echo "copying $DEST_DIR/.local/share/kiwix/library.xml to $DEST_DIR/../student/.local/share/kiwix/library.xml "
chown -R student:labdoo $DEST_DIR/../student/.local/share/kiwix/library.xml

#echo -en "\nNOW WE EXECUTE /home/labdoo/Desktop/set-rights-folder-files-Public-correct.sh to correct permissions"
#commented out, it is not necessary to have access to the wiki and the xowas
#bash /home/labdoo/Desktop/set-rights-folder-files-Public-correct.sh >/dev/null 2>&1

myFreeHD=$(df  $DEST_DIR | tail -1 | awk '{print $4}')
myFreeHD=$((myFreeHD/1024))  # in MBs
printf "INSTALLATION of content for language  ${yellow_colour} $LANG_CONTENT  ${end_colour} concluded ${red_colour} SUCCESSFULLY ${end_colour}\n FREE space LEFT ${red_colour} $myFreeHD MBs ${end_colour}\n"

exit 0
