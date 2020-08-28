#!/bin/bash
# desc: check_mk plugin for checking the difference between wsrep last committed values of galera nodes
# author: guerillatux
# last modified: 26.06.2020

# mysql root password - only root can read this file, nobody can change it, not even chuck norris
password="$(cat /root/.mysql_root_pw)"

# exit codes
OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

# functions to check if all values make sense and are "values"
is_int(){
    if [ -z "$(echo "$1" | sed -e 's/[[:digit:]]//g')" ]; then
        return 0
    else
        return 1
    fi
}

is_empty(){
    if [ -z "$1" ]; then
        return 0
    else
        return 1
    fi
}

# limits for the check_mk graph
warn_limit=30
crit_limit=50

wsrep_last_committed_server1=$(mysql -u root -p${password} -e "show global status like 'wsrep_last_committed';" | tail -n1 | awk '{print $2}')
wsrep_last_committed_server2=$(mysql -u root -p${password} -e "show global status like 'wsrep_last_committed';" -h server2.comback.de | tail -n1 | awk '{print $2}')
wsrep_last_committed_server3=$(mysql -u root -p${password} -e "show global status like 'wsrep_last_committed';" -h server3.comback.de | tail -n1 | awk '{print $2}')

# check that all all wsrep last committed values have been fetched and are integer values
if is_empty $wsrep_last_committed_server1 || is_empty $wsrep_last_committed_server2 || is_empty $wsrep_last_committed_server3; then
    echo ${UNKNOWN_STATE} Service_Galera_wsrep_last_committed_diff - "Could not fetch the last commits, please check manually!"
    exit ${UNKNOWN_STATE}
else
    if ! is_int $wsrep_last_committed_server1 || ! is_int $wsrep_last_committed_server2 || ! is_int $wsrep_last_committed_server3; then
        echo ${UNKNOWN_STATE} Service_Galera_wsrep_last_committed_diff - "The last commits have wrong values, please check manually!"
        exit ${UNKNOWN_STATE}
    fi
fi
    
# diff server1 to server2
if [ $wsrep_last_committed_server1 -eq  $wsrep_last_committed_server2 ]; then
    diff_server1_server2=0
elif [ $wsrep_last_committed_server1 -lt $wsrep_last_committed_server2 ]; then
    diff_server1_server2=$((wsrep_last_committed_server2-wsrep_last_committed_server1))
elif [ $wsrep_last_committed_server1 -gt $wsrep_last_committed_server2 ]; then
    diff_server1_server2=$((wsrep_last_committed_server1-wsrep_last_committed_server2))
else 
    echo ${UNKNOWN_STATE} Service_Galera_wsrep_last_committed_diff - "Could not determine the diff between server1 and server2, please check manually!"
fi

if [ $diff_server1_server2 -eq 0 ]; then
    echo ${OK_STATE} Service_Galera_wsrep_last_committed_diff_server1_to_server2 commit_diff_server1_to_server2=$diff_server1_server2\;$warn_limit\;$crit_limit "the commit diff between server1 and server2 is 0"
elif [ $diff_server1_server2 -lt 50 ]; then
    echo ${OK_STATE} Service_Galera_wsrep_last_committed_diff_server1_to_server2 commit_diff_server1_to_server2=$diff_server1_server2\;$warn_limit\;$crit_limit "the commit diff between server1 and server2 is less than 50 ($diff_server1_server2)"
else
    echo ${WARNING_STATE} Service_Galera_wsrep_last_committed_diff_server1_to_server2 commit_diff_server1_to_server2=$diff_server1_server2\;$warn_limit\;$crit_limit "the commit diff between server1 and server2 is more than 50 ($diff_server1_server2)"
fi 

# diff server1 to ref server3
if [ $wsrep_last_committed_server1 -eq  $wsrep_last_committed_server3 ]; then
    diff_server1_server3=0
elif [ $wsrep_last_committed_server1 -lt $wsrep_last_committed_server3 ]; then
    diff_server1_server3=$((wsrep_last_committed_server3-wsrep_last_committed_server1))
elif [ $wsrep_last_committed_server1 -gt $wsrep_last_committed_server3 ]; then
    diff_server1_server3=$((wsrep_last_committed_server1-wsrep_last_committed_server3))
else
    echo ${UNKNOWN_STATE} Service_Galera_wsrep_last_committed_diff - "Could not determine the diff between server1 and server3, please check manually!"
fi

if [ $diff_server1_server3 -eq 0 ]; then
    echo ${OK_STATE} Service_Galera_wsrep_last_committed_diff_server1_to_server3 commit_diff_server1_to_server3=$diff_server1_server3\;$warn_limit\;$crit_limit "the commit diff between server1 and server3 is 0"
elif [ $diff_server1_server3 -lt 50 ]; then
    echo ${OK_STATE} Service_Galera_wsrep_last_committed_diff_server1_to_server3 commit_diff_server1_to_server3=$diff_server1_server3\;$warn_limit\;$crit_limit "the commit diff between server1 and server3 is less than 50 ($diff_server1_server3)"
else
    echo ${WARNING_STATE} Service_Galera_wsrep_last_committed_diff_server1_to_server3 commit_diff_server1_to_server3=$diff_server1_server3\;$warn_limit\;$crit_limit "the commit diff between server1 and server3 is more than 50 ($diff_server1_server3)"
fi

# unset the mysql root password
unset password
