#!/bin/bash
# author: andreaswendlandt
# desc: download a file and check the date of it
# last modified: 13.06.2015

CURRENT_DAY=$(date +%e)
CURRENT_MONTH=$(date +%b)
LOCATION=your_location
FILE=your_file
URL=your_url

# go to the directory where you want do download the file
cd $LOCATION

# download the file
wget -S $URL/${FILE} >/dev/null 2>&1

# define the day and the month of the file
DAY=$(ls -l $FILE | awk '{print $7}')
MONTH=$(ls -l $FILE | awk '{print $6}')

# check if the file is from today and if it is not give out the date of the file 
if ! [ "$CURRENT_MONTH" == "$MONTH" -a $CURRENT_DAY -eq $DAY ]; then
  echo -e "File \"lieferheld_intelliad.csv\" was not uploaded today \n"
  echo "The last time it was uploaded was on the $DAY. of $MONTH"
fi

# remove the file
rm -f $FILE
