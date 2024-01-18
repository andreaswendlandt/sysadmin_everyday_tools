#!/bin/bash
# author: andreaswendlandt
# desc: creates a file that can be copied to a server
# desc: where a sms gateway is running (smstools)
# last modified: 28.01.2018

if [ $# -ne 2 ]; then
    echo "ERROR, this script needs two parameters"
    echo "Usage: $0 <88884444> <\"your text\">"
    exit 1
fi

# check that the given phone number contains only digits
not_a_valid_number=$(echo $1 | sed -e 's/[[:digit:]]//g')
if [ $not_a_valid_number ]; then
    echo "Your phone number contains other characters than digits, please try again"
    exit 1
fi  

# create the sms file and copy it to your gateway server
sms_file=sms_$(date +%s)
echo -e "To: $1\n\n$2" >$sms_file
scp $sms_file user@your_server:/path/to/dest
