#!/bin/bash
# desc: check_mk plugin for checking some galera cluster values(status, size, weight, connected, local state comment, ready, last committed) 
# author: andreaswendlandt
# last modified: 19.06.2020

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

is_alpha(){
    if [ -z "$(echo "$1" | sed -e 's/[[:alpha:]]//g')" ]; then
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

wsrep_last_committed_before=$(mysql -u root -p${password} -e "show global status like 'wsrep_last_committed';" | tail -n1 | awk '{print $2}')
sleep 3
check_mysql_galera_wsrep_value(){
    correct_value=""
    result=$(mysql -u root -p${password} -e "show global status like '"$1"';" | tail -n1 | awk '{print $2}')
    if ! is_empty "$result"; then
        if [ "$3" == "alpha" ]; then
            if is_alpha $result; then
                correct_value=1
            else
                correct_value=0
            fi
        elif [ "$3" == "int" ]; then
            if is_int $result; then
                correct_value=1
            else
                correct_value=0
            fi
        else
            correct_value=0
        fi
        if [ $correct_value -eq 1 ]; then
            if [ "$result" == "$2" ]; then
                echo ${OK_STATE} Service_Galera_${1} - "$1 is $result"
            else
                echo ${CRITICAL_STATE} Service_Galera_${1} - "$1 is not $2 (it is $result)"
            fi
        else
            echo ${UNKNOWN_STATE} Service_Galera_${1} - "$1 seems to have inconsistent data, please check manually!"
        fi
    else
            echo ${WARNING_STATE} Service_Galera_${1} - "Could not determine the status of $1"
    fi   
}

check_mysql_galera_wsrep_value wsrep_cluster_status Primary alpha
check_mysql_galera_wsrep_value wsrep_cluster_size 3 int
check_mysql_galera_wsrep_value wsrep_cluster_weight 3 int
check_mysql_galera_wsrep_value wsrep_connected ON alpha
check_mysql_galera_wsrep_value wsrep_local_state_comment Synced alpha
check_mysql_galera_wsrep_value wsrep_ready ON alpha

wsrep_last_committed_after=$(mysql -u root -p${password} -e "show global status like 'wsrep_last_committed';" | tail -n1 | awk '{print $2}')

if  [ $wsrep_last_committed_before -lt $wsrep_last_committed_after ]; then
    echo ${OK_STATE} Service_Galera_wsrep_last_committed - "wsrep_last_committed commits are increasing as they should do"
else
    echo ${CRITICAL_STATE} Service_Galera_wsrep_last_committed - "wsrep_last_committed commits are not increasing as they should do"
fi

# unset the mysql root password
unset password
