#!/bin/bash 
# author: andreaswendlandt
# desc: this script shows all versions of a file with the corresponding date when that file was backed up
# last modified: 8.5.2017
                                                                                                                                                                                                                                                    
if [ $# -ne 1 ]; then
    echo "ERROR, this script needs one parameter, the filename to check for"
    echo "Usage: $0 <filename>"
    exit 1
fi

file_to_check=$1
 
file=$(mysql -u root -e "select * from bacula.Filename where name like '${file_to_check}%';" | sed -e '1,1d')

echo -e "$file" | while read line; do
    file_id=$(echo $line | awk '{print $1}')
    filename=$(echo $line | awk '{print $2}')
    modtime_lstat=$(mysql -u root -e "select LStat from bacula.File where FilenameId='${file_id}';"| awk '{print $13}')
    echo -e "$modtime_lstat" | while read modtime; do
        if ! [ -z $modtime ]; then
            result=$(./lstat.php $modtime)
            backup_time=$(date --date="@$result")
            echo $backup_time $line
        fi
    done
done
exit 0
