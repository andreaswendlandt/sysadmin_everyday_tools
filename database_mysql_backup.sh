#!/bin/bash
# author: guerillatux
# desc: database dump per database, NOT all db's in one dump
# last modified: 6.4.2015

# ending for the dump
NOW=$(date +"%Y%m%d")

# with that you can check in the log
# how long the dump of a database took
function logtime() {
echo "`date +%H:%M` o'clock"
}

# location of your dumps
dump_folder="path_to_your_backup_directory"

# for your own security his file should only be readable for root
root_password=$(cat path_to_your_password 2>/dev/null)

# as this script will dump all existing db's you can blacklist
# databases you don't want to dump
database_blacklist=$(cat $dump_folder/blacklist | sed -e 's/ /|/g' 2>/dev/null)

if [ -z "$database_blacklist" ]; then
  databases=$(mysql -u root -p$root_password -e "show databases;" | egrep -v $databse_blacklist)
else
  databases=$(mysql -u root -p$root_password -e "show databases;")
fi

# cleanup the dump folder
find $dump_folder -mtime +14 -type f -exec rm {} \;


for db in $databases
do
  echo $db
  logtime
  mysqldump --single-transaction -u root  -p$root_password $db > $dump_folder/${db}_${NOW}.sql 
  echo "exit_code=$? $db"
  logtime
done

unset root_password

exit 0
