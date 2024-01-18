#!/bin/bash
# author: andreaswendlandt
# desc: script for getting the size of a file backed up in bacula
# last modified: 16.3.2017

if [ $# -ne 1 ]; then
    echo "ERROR, this script needs one parameter, the filename to check for"
    echo "Usage: $0 <filename>"
    exit 1
fi

file_to_check=$1

filename_id=$(mysql -u root -e "select FilenameID from bacula.Filename where name='${file_to_check}';" | tail -n1)

lstat=$(mysql -u root -e "select LStat from bacula.File where FilenameId='${filename_id}';" | head -n2| tail -n1 | awk '{print $8}')

result=$(./lstat.php $lstat)

echo "the size of $1 is $result bytes"
exit 0
