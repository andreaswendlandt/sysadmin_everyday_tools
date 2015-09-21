#!/bin/bash
# author: guerillatux
# required packages: duplicity, python-paramiko, python-boto
# desc: doing a backup to amazon s3 using duplicity
# last modified: 22.07.2015

# amazon s3 configuration, note that these variables need to 
# be environment variables, otherwise duplicity will fail 
export PASSPHRASE=$(cat passphrase_file)
export AWS_ACCESS_KEY_ID=$(cat aws_key_id_file)
export AWS_SECRET_ACCESS_KEY=$(cat aws_secret_key_file)
export BUCKET_NAME=$(cat bucket_name_file)

# as this script works in 2 stages you can decide here what
# you want to backup locally and what should only go to amazon s3
BACKUP_DIRS=$(cat backup_dir_file 2>/dev/null)
NO_LOCAL_BACKUP_DIRS=$(cat no_local_backup_dir_file 2>/dev/null)

# create a testfile for nagios to check
DATE=$(date +%c)
DATE_FOR_NAGIOS=$(date +%F)
SEARCHFILE=test-${DATE_FOR_NAGIOS}
 
# verbosity level (9 is the highest)
VLEVEL=9

# logfile
LOGFILE=/var/log/duplicity.log

# log function
function log(){
  echo "$DATE $@" | tee -a $LOGFILE
}

# delete old Logfile
rm -f $LOGFILE 2>/dev/null

if ! touch $LOGFILE; then
  echo "Could not create $LOGFILE" | logger -t $0
  exit 1
fi

# check that all necessary credentials are in place
if [ "$PASSPHRASE" == "" -o "$AWS_ACCESS_KEY_ID" == "" \
  -o "$AWS_SECRET_ACCESS_KEY" == "" -o "$BUCKET_NAME" == "" ]; then
  log "Could not fetch S3 credentials!"
  exit 1
fi

# define which directories should be in backup or use the default
# ones (/etc and /root)
if [ "$BACKUP_DIRS" == "" ]; then
  BACKUP_DIRS="/etc /root"
  log "Defaulting to '$BACKUP_DIRS' because no file provided!"
fi

# time to keep backups 
export COUNT="1M"

# creating a testfile for checking via nagios if duplicity worked
touch /backup/data/${SEARCHFILE}

# directories which are included
export INCLUDEDIR="--include /backup"

# copy directories local or put them only to s3
log "doing local backup of $BACKUP_DIRS"

for dir in $BACKUP_DIRS
do
  if ! echo " $NO_LOCAL_BACKUP_DIRS " | grep " $dir " >/dev/null; then
    rsync -a --delete --exclude '.cache' "$dir/" \
    "/backup/data/$(basename $dir)/" && log "rsync -a $dir/ \
    /backup/data/$(basename $dir)/" || log "rsync $dir failed"
  else
    log "$dir not locally dumped"
    log "INCLUDEDIR=$INCLUDEDIR --include $dir"
    INCLUDEDIR="$INCLUDEDIR --include $dir"
  fi
done

log "Localbackup done"

nice -n 19 duplicity --full-if-older-than $COUNT $INCLUDEDIR --exclude\
 '**' / --verbosity $VLEVEL --log-file $LOGFILE \
--allow-source-mismatch --s3-use-new-style --num-retries 50 --timeout \
60 s3+http://$BUCKET_NAME &&  log "Backup done" || log "Backup failed"

# remove old backups
nice -n 19 duplicity remove-older-than $COUNT --verbosity $VLEVEL \
--log-file $LOGFILE --s3-use-new-style --force s3+http://$BUCKET_NAME

rm -rf /backup/data/${SEARCHFILE}

# for a faster nagios check execution the next command is necessary
# it downloads the content of the s3 bucket and the nagios check
# below only needs to grep for the created (and uploaded) testfile
 
CACHEFILE="/tmp/.s3-backup-listing"
nice -n 19 duplicity list-current-files --s3-use-new-style \
"s3+http://$BUCKET_NAME" | tail -n +4 | awk '{print $6}' >$CACHEFILE

