#!/bin/bash
# author: guerillatux
# desc: transforms an incoming sms to a mail and sends it
# last modified: 4.11.2018

if [ $(ls -1 /var/spool/sms/incoming | wc -l) -ne 0 ]; then
    for file in $(ls -1 /var/spool/sms/incoming); do
        mv /var/spool/sms/incoming/${file} /opt/sms_incoming/
        text=$(sed -n '/Length/,$ p' /opt/sms_incoming/${file} | egrep -av '^$|Length')
        if echo -e $text | mail -s "Received SMS from $HOSTNAME" your_mail_address; then
            mv /opt/sms_incoming/${file} /opt/sms_incoming/${file}_sent
        else
            echo "Something went wrong with sending the mail /opt/sms_incoming/${file}, please check manually"
        fi
    done
fi

find /opt/sms_incoming/ -type f -mtime +31 -delete
