#!/bin/bash
# author: andreaswendlandt
# desc: this script is triggered from iwatch and copies a file from a directory to the outgoing directory of smstools
# last modified: 28.01.2018

logfile="/var/log/iwatch/log"
temp_file=/tmp/sms

log(){
  echo $(date) "$@" >>$logfile
}

for file in $(ls -1 "$1"); do
    if grep "$file" $temp_file >/dev/null 2>&1; then
        continue
    fi
    echo "$file" >>$temp_file
    rsync -abz "${1}/${file}" "${2}/${file}" && rm -r "${1}/${file}" || log "$file could not be moved from $1 to $2"
    sed -i "/$file/d" ${temp_file}
done
