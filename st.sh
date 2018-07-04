#!/bin/bash
#==============================================================================
#title           :st.sh
#description     :This script will take screenshots from multiple environments to compare images
#author          :Facundo M. (facundo.nah (at) gmail.com)
#date            :20170628
#version         :0.2
##usage          :bash st.sh
#notes           :Firefox needs to be installed
#==============================================================================

#environments
ENV_1="DEVELOPMENT" #NO SPACES
ENV_2="QUALITY"		#NO SPACES
ENV_3="PRODUCTION"	#NO SPACES
ENV_1_URL="http://www.DEVELOPMENT.com/"
ENV_2_URL="http://www.DEVELOPMENT.com/"
ENV_3_URL="http://www.DEVELOPMENT.com/"

URL_FILE="urls-short.txt"
LOG_FILE="$(date +%Y%m%d%H%M)_log.txt"

#echo "$(date "+%m%d%Y %T") : Starting work" >> $LOG_FILE 2>&1


#other variables
folder_base=screenshots
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
CYAN='\033[1;36m'
ORANGE='\033[1;33m'
PURPLE='\033[0;35m'
BLUE='\033[1;34m'

#Firefox parameters // DOES NOT WORK 
#--window-size=1366,768
MO="--window-size=1366,768"
TA="--window-size=1366,768"
DE="--window-size=1366,768"
TV="--window-size=1366,768"

#compare -verbose -metric RMSE -subimage-search global-diversity-and-inclusion-QA.png global-diversity-and-inclusion-XP.png glo-df.png

#count of files to process
NUMOFLINES=$(wc -l < "$URL_FILE")
PROC_COUNT=0


clear

echo -e "${YELLOW}  _____       _____            _                                      _       	${NC}"
echo -e "${YELLOW} |___ /      | ____|_ ____   _(_)_ __ ___  _ __  _ __ ___   ___ _ __ | |_ ___ 	${NC}"
echo -e "${YELLOW}   |_ \ _____|  _| | '_ \ \ / / | '__/ _ \| '_ \| '_ \` _ \ / _ \ '_ \| __/ __|	${NC}"
echo -e "${YELLOW}  ___) |_____| |___| | | \ V /| | | | (_) | | | | | | | | |  __/ | | | |_\__ \ ${NC}"
echo -e "${YELLOW} |____/      |_____|_| |_|\_/ |_|_|  \___/|_| |_|_| |_| |_|\___|_| |_|\__|___/	${NC}"
echo -e "${YELLOW}                                                                              	${NC}"
echo -e "${YELLOW}  ____                               _           _     _____           _ 		${NC}"
echo -e "${YELLOW} / ___|  ___ _ __ ___  ___ _ __  ___| |__   ___ | |_  |_   _|__   ___ | |		${NC}"
echo -e "${YELLOW} \___ \ / __| '__/ _ \/ _ \ '_ \/ __| '_ \ / _ \| __|   | |/ _ \ / _ \| |		${NC}"
echo -e "${YELLOW}  ___) | (__| | |  __/  __/ | | \__ \ | | | (_) | |_    | | (_) | (_) | |		${NC}"
echo -e "${YELLOW} |____/ \___|_|  \___|\___|_| |_|___/_| |_|\___/ \__|   |_|\___/ \___/|_|		${NC}"
echo -e "${YELLOW} 	 																			${NC}"
echo -e "${RED} Developed by Facundo M. - Jun 2018                                      			${NC}"
echo

echo "$(date "+%m%d%Y %T") : Starting Program" >> $LOG_FILE 2>&1

read -n 1 -s -r -p "Press any key to continue"
echo

echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo -e "List of Pages to Check ($URL_FILE):"
while read p; do
    #echo $ENV_2_URL$p
      INPUT=$p
    file_name=$(echo $INPUT| cut -d'/' -f 2,3)
    echo -e "#- ${YELLOW}$file_name${NC}"
done < $URL_FILE
echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


echo "Killing Firefox..."
pkill -f firefox
#echo "Firefox Killed"
echo "$(date "+%m%d%Y %T") : Firefox Killed" >> $LOG_FILE 2>&1
#Checking site status

validate_status ()
{
	ENV_URL=$1
	ENV=$2
	
	ENV_URL_STATUS=$(curl -Is $ENV_URL | head -1)
	if [[ $ENV_URL_STATUS = *"200"* ]]; then
     	 echo -e "$ENV Environment is ${GREEN}OK${NC} - $ENV_URL"
	  else
		  echo -e "$ENV Environment is ${RED}LOCKED${NC} - $ENV_URL"
	fi
	echo "$(date "+%m%d%Y %T") : Sites Checked " >> $LOG_FILE 2>&1
}


echo "Checking Sites..."

echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
validate_status $ENV_1_URL $ENV_1
validate_status $ENV_2_URL $ENV_2
validate_status $ENV_3_URL $ENV_3
echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

read -p "Do you want to check $ENV_1? [Y/n]" -n 1 -r check_ENV_1
echo
read -p "Do you want to check $ENV_2? [Y/n]" -n 1 -r check_ENV_2
echo
read -p "Do you want to check $ENV_3? [Y/n]" -n 1 -r check_ENV_3
echo


#create folder for screenshots
echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Creating Folder"
foldername=$(date +%Y%m%d%H%M)
mkdir -p  "$folder_base/$foldername"
folder="$folder_base/$foldername"
echo "Folder created: $folder"
echo "$(date "+%m%d%Y %T") : Folder Created: $folder" >> $LOG_FILE 2>&1

#Page Processing 
echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
#echo "Procesing pages..."

while read p; do
    #echo $ENV_2_URL$p
    INPUT=$p
	PROC_COUNT=$((PROC_COUNT+1))

file_name=$(echo $INPUT| cut -d'/' -f 2,3 | tr '/' _)

#echo "$string" | tr xyz _

get_screenshot ()
{
	ENV_URL=$1
	ENV=$2
	FOL=$3
	PAGE=$4
	FILE="$3/$5-$ENV.png"
	
	echo -e "For ${BLUE} $ENV ${NC}..."
	SECONDS=0 
	firefox -screenshot $FILE $ENV_URL$PAGE
	echo -e "Done ${GREEN} $FILE${NC} ($SECONDS seconds)" 
	echo "$(date "+%m%d%Y %T") : Screenshot Created: $FILE" >> $LOG_FILE 2>&1
}

echo "$(date "+%m%d%Y %T") : Parsing $p - $file_name" >> $LOG_FILE 2>&1
    
    echo -e "-----------Processing${YELLOW} $file_name${NC} [$PROC_COUNT of $NUMOFLINES]-----------"
    if [[ $check_ENV_1 =~ ^[Yy]$ ]]
    then
		get_screenshot "$ENV_1_URL" "$ENV_1" "$folder" "$p" "$file_name"
    fi
    
    if [[ $check_ENV_2 =~ ^[Yy]$ ]]
    then
		get_screenshot "$ENV_2_URL" "$ENV_2" "$folder" "$p" "$file_name"
    fi
    
    if [[ $check_ENV_3 =~ ^[Yy]$ ]]
    then
		get_screenshot "$ENV_3_URL" "$ENV_3" "$folder" "$p" "$file_name"
    fi
    
done < $URL_FILE
echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "$(date "+%m%d%Y %T") : All Pages Procesed" >> $LOG_FILE 2>&1

FILES_COUNT=$(ls -l $folder | grep -v ^d | wc -l)
FILES_COUNT=$((FILES_COUNT-1))  #to remove the .. 

echo -e "File Parse Completed - ${YELLOW}$NUMOFLINES ${NC}URLs to parse"
echo -e "Finished - ${YELLOW}$FILES_COUNT ${NC}screenshots created"

echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

ls $folder -lh



