#!/bin/bash


function init
{

 dir=0			# number of directories present
 files=0		# of regular files present
 exe=0			# of executables present
 options=($(ls))	# array containing file names
 options[${#options[*]}]=".."	# add .. directory
 size=${#options[*]}		# store directory size
 trap quit INT			
return 0
}

function secret
{
 #Search for secret.key

 for string in "${options[@]}"; do

	if [ "$string" = "secret.key" ];then
		key=true
		fi
 	done

#if it exists then get the key
 if [ "$key" = "true" ];then
	read key < "secret.key"

#else ask for a key
	
 else
	read -p "Enter key: " key
	
	fi

 unset string
 openssl enc -d -a -k $key -aes-256-cbc -in secret
}

function quit
{
 # performs if ^C happens
 echo
 echo "Type 'q' as a choice to exit"
 read input
 if [ "$input" = "q" ];then
	echo "exiting!"
	exit 0
 else
	return 0
 fi
}

# Count directory stats
function Files
{
 for((i=0; $i<$size; ++i));do
	if [ -e ${options[$i]} ];then
		if [[ -d ${options[$i]} ]];then
			dir=$((dir+1))
			
		elif [[ -x ${options[$i]} ]];then
			exe=$((exe+1))
			
		else
			files=$((files+1))
		fi
	fi
 done
 echo "$dir directories, $files files, $exe executables"

 return 0
}
			
# Display menu and handle selection by user


function choose
{
 echo
 echo "-- cscomdr --"	
 pwd
 Files
 echo
 width=25
 i=0

 # Menu formatting

 while [ "$i" -lt "3" ];do
	it=$i
	
	while [ $it -lt "$size" ];do
	
	if [ -d ${options[$it]} ];then
		string="$(($it+1))) DIR:${options[$it]}"
		printf "%s" "$string"
	elif [ -x ${options[$it]} ];then
		string="$(($it+1))) EXE:${options[$it]}"
                printf "%s" "$string"
	else
		string="$(($it+1))) ${options[$it]}"
		printf "%s" "$string"
		fi
	
	printf "%$(($width-${#string}))s" " "	
	it=$((it+3))
	
	done
echo
 i=$((i+1))
 done

 read -p "Choose an entry from the list: " Selection
	
	#handle input
		if [ "${options[(($Selection-1))]}" = "secret" ];then
			secret
			

 		elif [[ -d ${options[$((Selection-1))]} ]];then
                        echo "Directory ${options[$((Selection-1))]}"
			cd ${options[$((Selection-1))]} 2>/dev/null
			if [ $? != 0 ];then
			 echo "${options[$((Selection-1))]} is locked"
			 fi

                elif [[ -x ${options[$((Selection-1))]} ]];then
			echo "Executing ${options[$((Selection-1))]}"
                        ./${options[$((Selection-1))]} 
                    
                else    
			echo "Paging ${options[$((Selection-1))]}"
                        cat ${options[$((Selection-1))]} 2>/dev/null
			if [ $? != 0 ];then
                         echo "${options[$((Selection-1))]} is locked"
                         fi
                fi

#unset local variables
unset string
unset it
unset i
unset width
return 0
 
}


 while [ 1 ];do 
 	init
 	choose
	unset options
 done
exit 0
