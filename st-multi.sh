#!/bin/bash
#==============================================================================
#title           :st.sh
#description     :This script will take screenshots from multiple environments to compare images
#author          :Facundo M. (facundo.nah (at) gmail.com)
#date            :20170628
#version         :0.2
##usage          :bash st.sh
#notes           :Firefox needs to be installed - curl needs to be installed - chromiun needs to be installed - beyond compare is recommended to compare the screenshots 
#==============================================================================

#========= Environments =============
ENV_1="YYYYY" #NO SPACES
ENV_2="CCCCC"		#NO SPACES
ENV_3="RRRR"	#NO SPACES
ENV_1_URL="https://rerererer.net/"
ENV_2_URL="https://uiuyuyy.com/"
ENV_3_URL="https://fdfdfdfd.net/"

#========= Settings =============
BROWSER="chromium"
S_WIDTH="1280"
S_HEIGHT="10000"
GET_TAGS=0  #1 to get the code
GET_HTML=0	#1 to get the code
VALIDATE_SITES=0 	#1 to validate the site if open
FOR_BEYOND_COMPARE=1 #to split screenshots in folders and facilitate comparison
UNIFY_LOG=0 #all runs into a single file
URL_FILE="pages.txt"

folder_base="screenshots"

#========= System Constants =============
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
CYAN='\033[1;36m'
ORANGE='\033[1;33m'
PURPLE='\033[0;35m'
BLUE='\033[1;34m'
COUNT=0
PAGE_COUNT=0
PAGE_FROM=0
PAGE_TO=0

#========= Functions =============
get_screenshot ()
{
	ENV_URL=$1
	ENV=$2
	FOL=$3
	PAGE=${4%$'\r'}
	
	if [[ $FOR_BEYOND_COMPARE == 1 ]]
	then
		FILE="$3/$ENV/$5.png"
		echo "$(date "+%m%d%Y %T") : File Name Set for Beyond Compare: $FILE" >> $LOG_FILE 2>&1
	else
		FILE="$3/$5-$ENV.png"
		echo "$(date "+%m%d%Y %T") : File Name Set: $FILE" >> $LOG_FILE 2>&1
	fi
	
	echo -e "For ${BLUE} $ENV ${NC}..."
	SECONDS=0 
	
	case $BROWSER in 
	"chromium")
		chromium --headless --disable-gpu --screenshot=$FILE --hide-scrollbars $ENV_URL$PAGE --window-size=$S_WIDTH,$S_HEIGHT
		;;
	"firefox")
		firefox -screenshot $FILE $ENV_URL$PAGE
		;;
	esac
	
	echo -e "Done ${GREEN} $FILE${NC} ($SECONDS seconds)" 
	echo "$(date "+%m%d%Y %T") : Screenshot Created using $BROWSER: $FILE" >> $LOG_FILE 2>&1
	echo $ENV_URL$PAGE
	
	if [[ $GET_HTML == 1 ]]
	then
		echo "curl -k $ENV_URL$PAGE -o $3/$5-$ENV-HTMLcode.txt"
		curl -k $ENV_URL$PAGE -o $3/$5-$ENV-HTMLcode.txt
		cp $3/$5-$ENV-HTMLcode.txt $3/$ENV/$5-HTMLcode.txt
		echo "$(date "+%m%d%Y %T") : GET HMLT Code: $3/$5-$ENV-HTMLcode.txt" >> $LOG_FILE 2>&1
	fi

	if [[ $GET_TAGS == 1 ]]
	then
		echo "curl -k $ENV_URL$PAGE -o $3/$5-$ENV-code.txt"
		curl -k $ENV_URL$PAGE -o $3/$5-$ENV-code.txt
		cat $3/$5-$ENV-code.txt | grep -o "<[^>]*>"  > $3/$5-$ENV-tags.txt
		#curl $ENV_URL$PAGE >> $3/$5-$ENV-code.txt
		sed -i -e "s_.*_$PAGE|&_" $3/$5-$ENV-tags.txt
		cat $3/$5-$ENV-tags.txt >> $3/all-tags.txt
	fi
}

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

select_env ()
{
	read -p "Do you want to check $ENV_1? [Y/n]" -n 1 -r check_ENV_1
	echo
	read -p "Do you want to check $ENV_2? [Y/n]" -n 1 -r check_ENV_2
	echo
	read -p "Do you want to check $ENV_3? [Y/n]" -n 1 -r check_ENV_3
	echo
}

set_folder_name_default ()
{
	echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Creating Folder"
	foldername=$(date +%Y%m%d%H%M)
	echo "$(date "+%m%d%Y %T") : Force folder name to: $force_folder_name " >> $LOG_FILE 2>&1
	mkdir -p  "$folder_base/$foldername"
	echo "$(date "+%m%d%Y %T") : Folders created $folder_base/$foldername/$ENV_1, $ENV_2, $ENV_3 -  " >> $LOG_FILE 2>&1

	if [[ $FOR_BEYOND_COMPARE == 1 ]]
	then
		mkdir -p  "$folder_base/$foldername/$ENV_1"
		mkdir -p  "$folder_base/$foldername/$ENV_2"
		mkdir -p  "$folder_base/$foldername/$ENV_3"
		echo "Folders created: $folder_base/$foldername/$ENV_1, $ENV_2, $ENV_3"
		echo "$(date "+%m%d%Y %T") : Folders created $folder_base/$foldername/$ENV_1, $ENV_2, $ENV_3 -  " >> $LOG_FILE 2>&1
	else
		mkdir -p  "$folder_base/$foldername"
		echo "Folder created: $folder"
		echo "$(date "+%m%d%Y %T") : Folder Created: $folder" >> $LOG_FILE 2>&1
	fi

	folder="$folder_base/$foldername"
}

set_folder_name ()
{
	#create folder for screenshots
	echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Creating Folder"
	#foldername=$(date +%Y%m%d%H%M)
	force_folder_name="none"

	echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	read -p 'Force Folder Name (empty for datetime):  ' force_folder_name 
	echo "$(date "+%m%d%Y %T") : Force folder name to: $force_folder_name " >> $LOG_FILE 2>&1
	echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

	if [[ $force_folder_name == "none" ]]
	then
		foldername=$(date +%Y%m%d%H%M)
		mkdir -p  "$folder_base/$foldername"
		echo "Folder created: $folder"
		echo "$(date "+%m%d%Y %T") : Folder Created: $folder" >> $LOG_FILE 2>&1
	else
		#let foldername=$force_folder_name
		foldername=$(echo $force_folder_name)
		#printf -v $foldername "$force_folder_name"
		echo "$(date "+%m%d%Y %T") : Force folder name to: $force_folder_name " >> $LOG_FILE 2>&1
		mkdir -p  "$folder_base/$foldername"
		echo "$(date "+%m%d%Y %T") : Folders created $folder_base/$foldername/$ENV_1, $ENV_2, $ENV_3 -  " >> $LOG_FILE 2>&1
	fi



	if [[ $FOR_BEYOND_COMPARE == 1 ]]
	then
		mkdir -p  "$folder_base/$foldername/$ENV_1"
		mkdir -p  "$folder_base/$foldername/$ENV_2"
		mkdir -p  "$folder_base/$foldername/$ENV_3"
		echo "Folders created: $folder_base/$foldername/$ENV_1, $ENV_2, $ENV_3"
		echo "$(date "+%m%d%Y %T") : Folders created $folder_base/$foldername/$ENV_1, $ENV_2, $ENV_3 -  " >> $LOG_FILE 2>&1
	else
		mkdir -p  "$folder_base/$foldername"
		echo "Folder created: $folder"
		echo "$(date "+%m%d%Y %T") : Folder Created: $folder" >> $LOG_FILE 2>&1
	fi

	folder="$folder_base/$foldername"
}

process_pages_all ()
{
	#Page Processing 
	echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	#echo "Procesing pages..."

	while read p; do
		#echo $ENV_2_URL$p
		INPUT=$p
		PROC_COUNT=$((PROC_COUNT+1))

		file_name=$(echo $INPUT| cut -d'/' -f 2,3,4,5,6 | tr '/' _ | tr -cd '[[:alnum:]]._-')

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
}

process_pages_lines ()
{
	echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	read -p 'From Line Number:  ' PAGE_FROM
	read -p 'To Line Number:  ' PAGE_TO
	echo "$(date "+%m%d%Y %T") : From page $PAGE_FROM to $PAGE_TO " >> $LOG_FILE 2>&1
	echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

	#Page Processing 
	echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	#echo "Procesing pages..."

	while read p; do
		#echo $ENV_2_URL$p
		INPUT=$p
		PROC_COUNT=$((PROC_COUNT+1))

		file_name=$(echo $INPUT| cut -d'/' -f 2,3,4,5,6 | tr '/' _ | tr -cd '[[:alnum:]]._-')

		echo "$(date "+%m%d%Y %T") : Parsing $p - $file_name" >> $LOG_FILE 2>&1

		if [[ $PROC_COUNT -ge $PAGE_FROM  &&  $PROC_COUNT -le $PAGE_TO ]]
		then
			echo "$(date "+%m%d%Y %T") : Processing Page as per : $PROC_COUNT [$PAGE_FROM of $PAGE_TO]" >> $LOG_FILE 2>&1
			echo "Processing Page as per: $PROC_COUNT [$PAGE_FROM of $PAGE_TO] - $p"


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

		else
			echo "$(date "+%m%d%Y %T") : Skipping Page as per : $PROC_COUNT [$PAGE_FROM of $PAGE_TO]" >> $LOG_FILE 2>&1
			echo "Skipping Page as per: $PROC_COUNT [$PAGE_FROM of $PAGE_TO] - $p"
		fi

	done < $URL_FILE

	echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "$(date "+%m%d%Y %T") : All Pages Procesed" >> $LOG_FILE 2>&1

}

validate_env ()
{
	echo "Checking Sites..."
		echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		validate_status $ENV_1_URL $ENV_1
		validate_status $ENV_2_URL $ENV_2
		validate_status $ENV_3_URL $ENV_3
		echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

list_pages ()
{
	echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo -e "List of Pages to Check ($URL_FILE):"
	while read p; do
		#echo $ENV_2_URL$p
		  INPUT=$p
		file_name=$(echo $INPUT| cut -d'/' -f 2,3)
		let COUNT=$COUNT+1
		echo -e "$COUNT - ${YELLOW}$file_name${NC}"
	done < $URL_FILE
	echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}




#count of files to process
NUMOFLINES=$(wc -l < "$URL_FILE")
PROC_COUNT=0

if [[ $UNIFY_LOG == 1 ]]
then
	LOG_FILE="screenshots/ScreenshotTool_log.txt"
else
	LOG_FILE="screenshots/$(date +%Y%m%d%H%M)_log.txt"
fi


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

echo "$(date "+%m%d%Y %T") : Starting Program" > $LOG_FILE 2>&1

read -n 1 -s -r -p "Press any key to continue"
echo



echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
PS3='Please enter your choice: '
options=("Quick Run" "Full Validated Run" "From Line X to Y" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Quick Run")
			select_env
			set_folder_name_default
			process_pages_all
			break
            ;;
        "Full Validated Run")
			list_pages
			validate_env
			select_env
			set_folder_name
			process_pages_lines
            break
			;;
        "From Line X to Y")
			list_pages
			select_env
			set_folder_name
			process_pages_lines
			#echo "you chose choice $REPLY which is $opt"
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done


: <<'END'




echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo -e "List of Pages to Check ($URL_FILE):"
while read p; do
    #echo $ENV_2_URL$p
      INPUT=$p
    file_name=$(echo $INPUT| cut -d'/' -f 2,3)
	let COUNT=$COUNT+1
    echo -e "$COUNT - ${YELLOW}$file_name${NC}"
done < $URL_FILE
echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


echo "Killing Firefox..."
################################pkill -f firefox
#echo "Firefox Killed"
echo "$(date "+%m%d%Y %T") : Firefox Killed" >> $LOG_FILE 2>&1
#Checking site status

if [[ $VALIDATE_SITES == 1 ]]
	then
		echo "Checking Sites..."
		echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		validate_status $ENV_1_URL $ENV_1
		validate_status $ENV_2_URL $ENV_2
		validate_status $ENV_3_URL $ENV_3
		echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	fi

echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
read -p 'From Line Number:  ' PAGE_FROM
read -p 'To Line Number:  ' PAGE_TO
echo "$(date "+%m%d%Y %T") : From page $PAGE_FROM to $PAGE_TO " >> $LOG_FILE 2>&1
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
force_folder_name="none"

echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
read -p 'Force Folder Name (empty for datetime):  ' force_folder_name 
echo "$(date "+%m%d%Y %T") : Force folder name to: $force_folder_name " >> $LOG_FILE 2>&1
echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

if [[ $force_folder_name == "none" ]]
then
	mkdir -p  "$folder_base/$foldername"
	echo "Folder created: $folder"
	echo "$(date "+%m%d%Y %T") : Folder Created: $folder" >> $LOG_FILE 2>&1
else
	#let foldername=$force_folder_name
	foldername=$((force_folder_name))
	echo "$(date "+%m%d%Y %T") : Force folder name to: $force_folder_name " >> $LOG_FILE 2>&1
	mkdir -p  "$folder_base/$foldername"
	echo "$(date "+%m%d%Y %T") : Folders created $folder_base/$foldername/$ENV_1, $ENV_2, $ENV_3 -  " >> $LOG_FILE 2>&1
fi



if [[ $FOR_BEYOND_COMPARE == 1 ]]
then
	mkdir -p  "$folder_base/$foldername/$ENV_1"
	mkdir -p  "$folder_base/$foldername/$ENV_2"
	mkdir -p  "$folder_base/$foldername/$ENV_3"
	echo "Folders created: $folder_base/$foldername/$ENV_1, $ENV_2, $ENV_3"
	echo "$(date "+%m%d%Y %T") : Folders created $folder_base/$foldername/$ENV_1, $ENV_2, $ENV_3 -  " >> $LOG_FILE 2>&1
else
	mkdir -p  "$folder_base/$foldername"
	echo "Folder created: $folder"
	echo "$(date "+%m%d%Y %T") : Folder Created: $folder" >> $LOG_FILE 2>&1
fi

folder="$folder_base/$foldername"

#Page Processing 
echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
#echo "Procesing pages..."

while read p; do
    #echo $ENV_2_URL$p
    INPUT=$p
	PROC_COUNT=$((PROC_COUNT+1))

	file_name=$(echo $INPUT| cut -d'/' -f 2,3,4,5,6 | tr '/' _ | tr -cd '[[:alnum:]]._-')

	echo "$(date "+%m%d%Y %T") : Parsing $p - $file_name" >> $LOG_FILE 2>&1

	if [[ $PROC_COUNT -ge $PAGE_FROM  &&  $PROC_COUNT -le $PAGE_TO ]]
	then
		echo "$(date "+%m%d%Y %T") : Processing Page as per : $PROC_COUNT [$PAGE_FROM of $PAGE_TO]" >> $LOG_FILE 2>&1
		echo "Processing Page as per: $PROC_COUNT [$PAGE_FROM of $PAGE_TO] - $p"


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
		
	else
		echo "$(date "+%m%d%Y %T") : Skipping Page as per : $PROC_COUNT [$PAGE_FROM of $PAGE_TO]" >> $LOG_FILE 2>&1
		echo "Skipping Page as per: $PROC_COUNT [$PAGE_FROM of $PAGE_TO] - $p"
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


#sudo snap install --classic notepadqq
#sudo apt-get install curl
#wget https://www.scootersoftware.com/bcompare-4.2.6.23150_amd64.deb
#sudo apt-get update
#sudo apt-get install gdebi-core
#sudo gdebi bcompare-4.2.6.23150_amd64.deb

END
