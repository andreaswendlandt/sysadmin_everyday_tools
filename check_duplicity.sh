#!/bin/bash
# author: guerillatux
# simple nagios check to see if duplicity worked by grepping for a 
# testfile which is created within the backup script
# last modified: 22.07.2015


# check if stage 2 is configured
if [ ! -f /root/.s3_aws_access_key_id ]; then
  echo "Stage 2 backup is not configured!"
  exit 3
fi

# check the age of the logfile and the content
if find /var/log -maxdepth 1 -mtime -1 -name duplicity.log | grep \
duplicity.log >/dev/null; then
  if ! egrep 'Backup done' /var/log/duplicity.log >/dev/null; then
    echo "stage 2 S3 backup failed, check /var/log/duplicity.log!"
    exit 1
  fi
else
  echo "/var/log/duplicity.log older then one day"
  exit 1
fi

# check for stage 1 backup
if ! find /backup -name data -mtime -3 >/dev/null 2>&1; then
  echo "no stage 1 standard system backups in /backup/data!"
  exit 2
fi

# check backup listing file created during backup 
CACHEFILE="/tmp/.s3-backup-listing"
SEARCHFILE=test-$(date -u +%F)
if grep $SEARCHFILE $CACHEFILE >/dev/null; then
  echo "Backup is in S3 ($SEARCHFILE found)";
  exit 0
else
  echo "backup is not in s3 ($SEARCHFILE not found)"
  exit 2
fi
