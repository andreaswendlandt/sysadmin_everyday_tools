#!/bin/bash
# author: guerillatux
# desc: checks if the mysql partition has less than 10% space left, in that case it purges old binlogs(older than 2 hours)
# last modified: 28.9.2017

used_space=$(df -h | grep mysql | awk '{print $5}' | sed 's/\%//')
if [ $used_space -ge 90 ]; then
    mysql_root_pw=$(cat /root/.mysql_root_pw)
    back_in_time=$(date --date="2 hours ago" +%Y-%m-%d\ %T)
    if mysql -uroot -p$mysql_root_pw -e "PURGE BINARY LOGS BEFORE \'$back_in_time\';" >/dev/null; then
        echo $(date) "...gelöscht" >/tmp/purge.log
    else
        echo $(date) "konnte nichts löschen, bitte manuell prüfen" >/tmp/purge.log
    fi
    unset $mysql_root_pw
else
   echo $(date) "es musste nichts gelöscht werden, es sind aktuell ${used_space}% belegt" >/tmp/purge.log
fi
