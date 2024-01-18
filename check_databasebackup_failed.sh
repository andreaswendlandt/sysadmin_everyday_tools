#!/bin/bash
# author: andreaswendlandt
# desc: creates a list of databases where the backup failed
# desc: and sends this list via email
# last modified: 18.04.2015

logfile_to_check="path_to_your_logfile"
mail_to="your_address"
databases_failed=$(grep 'exit_code=1' $logfile_to_check | awk '{print $2}' | grep -v '^$' | uniq)

if ! [ -z "$databases_failed" ]; then
        echo -e "$databases_failed" | mail -s "these databases failed at todays dump on $HOSTNAME" -t $mail_to
fi
