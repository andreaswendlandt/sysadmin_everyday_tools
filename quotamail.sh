#!/bin/bash
# author: guerillatux
# desc: sending a mail to all users over quota and a copy to the bofh
# last modified: 26.7.2017

if /etc/init.d/quota status | grep "Active: active" >/dev/null; then
    user=$(repquota /dev/your_filesystem | sed -e '1,5d' | grep -v "^$" | while read line; do  echo $line | awk '$2 ~ "+" {print $1 " " $6 " " $3}'; done)
    if [ -z "$user" ]; then
        exit 0
    fi
    echo -e "$user" | while read line; do
        quota_user=$(echo $line | awk '{print $1}') #adjust this one for your mailaddress scheme
        quota_time=$(echo $line | awk '{print $2}')
        user_dir_size=$(du -sh /dev/your_filesystem/${quota_user} | awk '{print $1}')
        if echo "$quota_time"  | grep none >/dev/null; then
            continue
        fi     
        if echo "$quota_time"  | grep days >/dev/null; then
            quota_time=$(echo $line | awk '{print $2}' | grep -o [[:digit:]])
            echo "hi,

please cleanup the space within the next $quota_time in your home directory on  $HOSTNAME, you are using  ${user_dir_size}b in the moment, allowed are only your_value gb

best regards
bofh" | mail -a "Content-Type: text/plain; charset=UTF-8" -s "space on $HOSTNAME" user@mailaddress
        else
            echo "hi,

today is the last day to free up the space on  $HOSTNAME, you are using ${user_dir_size}b, allowed are only your_value gb, from tomorrow on no new files can be created!

best regards
bofh" | mail -a "Content-Type: text/plain; charset=UTF-8" -s "space on $HOSTNAME" user@mailaddress -c bofh@hell.com
        fi
done
else
    echo "the service quota is not running in the moment on $HOSTNAME !!!" | mail -a "Content-Type: text/plain; charset=UTF-8" -s "please switch on quota again" bofh@hell.com
fi
