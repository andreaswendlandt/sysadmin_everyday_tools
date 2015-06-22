#!/bin/bash
# author: guerillatux
# desc: creates an ldif file with all the content 
# desc: of the given dit and compares afterwards the newly 
# desc: created file with the one from the day before, 
# desc: in case they are equal, the older one will be deleted
# last modified: 20.4.2015

NOW=$(date +"%Y%m%d")
YESTERDAY=$(date -d "1 day ago" +"%Y%m%d")
LDAP_ADMIN_PASSWORD=$(cat /root/ldap_admin_password >/dev/null 2>&1)
USERNAME=$(cat /root/ldap_admin_name >/dev/null 2>&1)
DUMP_FOLDER="path_to_your_backup_directory"

ldapsearch -x -D "$USERNAME" -w $LDAP_ADMIN_PASSWORD >$DUMP_FOLDER/_${NOW}.ldif

unset LDAP_ADMIN_PASSWORD
unset USERNAME

# compare the current file with the previous one, 
# in case they are the same delete the older one
TODAY_SIZE=$(ls -la $DUMP_FOLDER/${NOW}.ldif | awk '{print $5}')
YESTERDAY_SIZE=$(ls -la $DUMP_FOLDER/${YESTERDAY}.ldif | awk '{print $5}')

if [ $YESTERDAY_SIZE -eq $TODAY_SIZE ]; then
  rm ${DUMP_FOLDER}/${YESTERDAY}.ldif >/dev/null
fi

exit 0
