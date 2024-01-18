#!/bin/bash
# author: andreaswendlandt
# desc: function for grepping in (config)files for a search pattern and check if the line where the search pattern
# desc: occurs is outcommented
# last modified: 15.9.2019

search_pattern=$1
search_file=$2

config_grep(){
    if [ $# -ne 2 ]; then
        echo "error: 2 parameters are needed"
        echo "USAGE: ${FUNCNAME} 'search pattern' 'search file'"
        return 1
    fi
    if [ -f $2 ]; then
        result=$(grep -i $1 $2 2>/dev/null | awk '{if (substr($1,1,1) ~ /#|;/) {print "outcommented"} else {print "match"}}')
        if [ -z $result ]; then
            result="no occurence"
        fi
        echo $result
    else
        echo "$2 does not exist"
        return 1
    fi
}

config_grep $search_pattern $search_file
