#!/bin/bash
# author: guerillatux
# desc: database dump per database, NOT all db's in one dump
# last modified: 6.4.2015

# ending for the dump
NOW=$(date +"%Y%m%d")

# with that you can check in the log 
#how long the dump of a database took
function logtime() {
echo "`date +%H:%M` o'clock"
}

# location of your dumps
dump_folder="path_to_your_backup_directory"

# as this script will dump all existing db's you can blacklist 
#databases you don't want to dump
database_blacklist=$(cat ${dump_folder}/blacklist | sed -e 's/ /|/g' 2>/dev/null)

if [ -z "$database_blacklist" ]; then
  databases=$(sudo -u postgres psql -At -c "select datname from pg_database where not datistemplate and datallowconn order by datname;" 2>/dev/null)
else
  databases=$(sudo -u postgres psql -At -c "select datname from pg_database where not datistemplate and datallowconn order by datname;" | egrep -v \ 
 "$database_blacklist" 2>/dev/null)
fi

# cleanup the dump folder
find $dump_folder -mtime +14 -type f -exec rm {} \;

for db in $databases
do
  echo $db
  logtime
  sudo -u postgres pg_dump -v --file=$dump_folder/${db}_${NOW} --format=custom --username=postgres --no-owner $db
  echo "exit_code=$? $db"
  logtime
done

exit 0
