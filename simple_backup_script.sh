#!/usr/bin/env bash

# this script read the backup location from . backup.conf please make sure to check backup.conf before running this script.

date="$(date +%Y-%m-%H%M%S)"
dir=$(cat backup.conf)
# checks if the backup.conf is avaible before executing the script.

function check_backup.conf(){

[ -s $(pwd)/backup.conf ] && echo -e "\e[32mbackup.conf was found.\e[0m" || echo -e "\e[31mError: backup.conf was not found, please check newly generated backup.conf in the current directory.\e[0m" && touch $(pwd)/backup.conf
}

function empty.conf(){

 [ -s $(pwd)/backup.conf ]
}


function create_tar(){

 tar -czf backup.$date.tar.gz $dir &> /dev/null && md5sum backup.$date.tar.gz &>> $(pwd)/backup.log ; echo -e "\e[32mBackup was done, please check the log file\e[0m"

}

function delete_old_tar(){

 dir_tar=$(pwd)
 files=$(ls -t $dir_tar/*.tar.gz)
 count=$(echo "$files"|wc -l)

 if [ $count -gt 5 ]; then
        oldest=$(echo "$files"|tail -1)
        sudo rm $oldest
        echo -e "\e[31mCleaning old backups...\e[0m" ; sleep 2 && echo -e "\e[32mCleaned old backup successfully.\e[0m"
 fi

}

file_check=check_backup.conf
empty=empty.conf
start_backup=create_tar
clean_tar=delete_old_tar
$empty || echo -e "\e[31mError: newly generated backup.conf file is empty, please verify if backup.conf is not empty.\e[0m"
$empty && echo -e "\e[32mCreating backup of [$(cat backup.conf)] ...\e[0m" && $start_backup && $clean_tar
