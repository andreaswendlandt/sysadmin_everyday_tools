#!/bin/bash
# author: guerillatux
# desc: compare the size of database dumps with the previous day, 
# desc: in case they are for a given percentage bigger or smaller, 
# desc: a list of those db dumps will be generated and send to an
# desc: email address
# last modified: 28.4.15

mail_to="your_address"
current=$(date -d "1 day ago" +"%Y%m%d")
previous=$(date -d "2 day ago" +"%Y%m%d")
databases_to_check=$(grep 'exit_code=0' /var/log/mysql/db_dump.log\
 | grep -v '^+' | awk '{print $2}' | grep -v '^$' | sort | uniq)

# location of your dumps
dump_folder="path_to_your_backup_directory"

list_difference_bigger=
list_difference_smaller=

for db in $databases_to_check; do 
  size1=$(du -s ${dump_folder}/${db}_$current 2>/dev/null | awk '{print $1}')
  size2=$(du -s ${dump_folder}/${db}_$previous 2>/dev/null | awk '{print $1}')
  if ! [ -z "$size1" ]; then
    if ! [ -z "$size2" ]; then
      result1=$(echo $size2 | awk '{printf( "%5.2f\n", $1*1.05)}')
      result2=$(echo $size2 | awk '{printf( "%5.2f\n", $1/1.05)}')
      if [ $(echo "if (${size1} > ${result1}) 1 else 0" | bc) -eq 1 ]; then
        list_difference_bigger=$(echo -e $list_difference_bigger $db)
      fi
      if [ $(echo "if (${size1} < ${result2}) 1 else 0" | bc) -eq 1 ]; then
        list_difference_smaller=$(echo -e $list_difference_smaller $db)
      fi
    fi
  fi
done

if ! [ "$list_difference_bigger" == "" ]; then
   mail_content1="these dumps are bigger: $list_difference_bigger"
fi
if ! [  "$list_difference_smaller" == "" ]; then
  mail_content2="these dumps are smaller: $list_difference_smaller"
fi
if  [ ! "$mail_content1" == "" -o ! "$mail_content2" == "" ]; then
  echo -e "$mail_content1 \n \n$mail_content2" | mail -s "the dumps of these databases are either 5% bigger or smaller than the day before on $HOSTNAME" -t $mail_to
fi
