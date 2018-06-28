#!/bin/bash
#==============================================================================
#title           :st.sh
#description     :This script will take screenshots from multiple environments to compare images
#author          :Facundo M. (facundo.nah@gmail.com)
#date            :20170628
#version         :0.1
##usage          :bash st.sh
#notes           :Firefox needs to be installed
#==============================================================================

#environments
ENV_1="DEVELOPMENT"
ENV_2="QUALITY"
ENV_3="PRODUCTION"
ENV_1_URL="http://www.DEVELOPMENT.com/"
ENV_2_URL="http://www.DEVELOPMENT.com/"
ENV_3_URL="http://www.DEVELOPMENT.com/"

URL_FILE="urls.txt"
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



clear

echo -e "${YELLOW} ____                               _           _     _____           _     ${NC}"
echo -e "${YELLOW}/ ___|  ___ _ __ ___  ___ _ __  ___| |__   ___ | |_  |_   _|__   ___ | |    ${NC}"
echo -e "${YELLOW}\___ \ / __| '__/ _ \/ _ \ '_ \/ __| '_ \ / _ \| __|   | |/ _ \ / _ \| |    ${NC}"
echo -e "${YELLOW} ___) | (__| | |  __/  __/ | | \__ \ | | | (_) | |_    | | (_) | (_) | |    ${NC}"
echo -e "${YELLOW}|____/ \___|_|  \___|\___|_| |_|___/_| |_|\___/ \__|   |_|\___/ \___/|_|    ${NC}"
echo -e "${YELLOW}                                                                            ${NC}"
echo -e "${RED}Developed by Facundo M. - Jun 2018                                      ${NC}"
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

echo "Checking Sites..."
XP_STATUS=$(curl -Is $ENV_1_URL | head -1)
QA_STATUS=$(curl -Is $ENV_2_URL | head -1)
CONTENT_STATUS=$(curl -Is $ENV_3_URL | head -1)
echo "$(date "+%m%d%Y %T") : Sites Checked " >> $LOG_FILE 2>&1


echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
if [[ $ENV_1_URL_STATUS = *"200"* ]]; then
      echo -e "$ENV_1 Environment is ${GREEN}OK${NC} - $ENV_1_URL"
  else
      echo -e "$ENV_1 Environment is ${RED}LOCKED${NC} - $ENV_1_URL"
fi

if [[ $ENV_2_URL_STATUS = *"200"* ]]; then
      echo -e "$ENV_2 Environment is ${GREEN}OK${NC} - $ENV_2_URL"
  else
      echo -e "$ENV_2 Environment is ${RED}LOCKED${NC} - $ENV_2_URL"
fi

if [[ $ENV_3_URL_STATUS = *"200"* ]]; then
      echo -e "$ENV_3 Environment is ${GREEN}OK${NC} - $ENV_3_URL"
  else
      echo -e "$ENV_3 Environment is ${RED}LOCKED${NC} - $ENV_3_URL"
fi
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


file_name=$(echo $INPUT| cut -d'/' -f 2,3 | tr '/' _)

#echo "$string" | tr xyz _


echo "$(date "+%m%d%Y %T") : Parsing $p - $file_name" >> $LOG_FILE 2>&1
    
    echo -e "-----------Processing${YELLOW} $file_name${NC} -----------"
    if [[ $check_ENV_1 =~ ^[Yy]$ ]]
    then
        #echo -e "Processing${YELLOW} $file_name${NC} in${YELLOW} XP${NC} "
        echo -e "For ${BLUE}XP${NC}..."
        SECONDS=0 
        firefox -screenshot $folder/$file_name-XP.png $ENV_1_URL$p
        echo -e "Done ${GREEN} $file_name-XP.png${NC} ($SECONDS seconds)" 
    fi
    
    if [[ $check_ENV_2 =~ ^[Yy]$ ]]
    then
        #echo -e "Processing${YELLOW} $file_name${NC} in${PURPLE} QA${NC}"
        echo -e "For ${ORANGE} QA${NC}..."
        SECONDS=0 
        firefox -screenshot $folder/$file_name-QA.png $ENV_2_URL$p
        echo -e "Done ${GREEN} $file_name-QA.png${NC} ($SECONDS seconds)" 
    fi
    
    if [[ $check_ENV_3 =~ ^[Yy]$ ]]
    then
        #echo -e "Processing${YELLOW} $file_name${NC} in${CYAN} CONTENT${NC}"
        echo -e "For ${CYAN} CONTENT${NC}..."
        SECONDS=0 
        firefox -screenshot $folder/$file_name-CONTENT.png $ENV_3_URL$p
        echo -e "Done ${GREEN} $file_name-CONTENT.png${NC} ($SECONDS seconds)" 
    fi
    
done < $URL_FILE
echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "$(date "+%m%d%Y %T") : All Pages Procesed" >> $LOG_FILE 2>&1

FILES_COUNT=$(ls -l $folder | grep -v ^d | wc -l)
NUMOFLINES=$(wc -l < "$URL_FILE")

echo -e "File Parse Completed - ${YELLOW}$NUMOFLINES ${NC}URLs to parse"
echo -e "Finished - ${YELLOW}$FILES_COUNT ${NC}screenshots created"

echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

ls $folder -lh
