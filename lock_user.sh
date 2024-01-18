#!/bin/bash
# author: andreaswendlandt
# desc: script to lock a given user on a given server(s) and outcomment all ssh keys in case they are present
# last modified: 03.11.2018

if [ $# -ne 2 ]; then
    echo "Error: this script needs two Parameters, the username you want to lock and the name or a list with names of servers"
    echo "Usage: $0 <user_to_lock> \"server1 server2\""
    exit 1
fi

servers="$2"

user_lock(){
    user_to_lock=$1
    if line=$(grep "$user_to_lock" /etc/passwd); then
        export newline=$(echo $line | sed -e s'/bash/false/')
        sudo sed -i "/$user_to_lock/d" /etc/passwd
        echo "$newline" | sudo tee -a /etc/passwd >/dev/null
        echo "User $user_to_lock locked in /etc/passwd"
        if ls -1 /home/${user_to_lock}/.ssh/authorized_keys >/dev/null 2>&1; then
            if sudo sed -i 's/^\(.\)/#\1/' /home/${user_to_lock}/.ssh/authorized_keys; then
                echo "All SSH Keys outcommented in Users' authorized_keys"
            fi
        else
            echo "User $user_to_lock has no authorized_keys file"
        fi
    else
        echo "$user_to_lock not present on this system"
    fi
}

for host in $servers; do

  ssh -t $host "$(declare -f user_lock); user_lock $1"

done
