#!/bin/bash
# author: andreaswendlandt
# desc: script to autogenerate the needed iwatch xml config file
# last modified: 28.4.2017

configfile=/etc/iwatch.xml
rm $configfile

echo "<?xml version=\"1.0\" ?>
<!DOCTYPE config SYSTEM \"/etc/iwatch/iwatch.dtd\" >

<config charset=\"utf-8\">
  <guard email=\"root@localhost\" name=\"IWatch\"/>
  <watchlist>
    <title>Transferdirectory</title>
    <contactpoint email="root@localhost" name=\"Administrator\"/>" >$configfile
user=$(ls -1 /path_to_your_surveilled_directory)
echo -e "$user" | while read line; do
    unix_user=$(ls -la /path_to_your_surveilled_directory | grep "$line" | awk '{print $3}')
    echo "    <path type=\"recursive\" alert=\"off\" syslog=\"on\" exec=\"/usr/local/sbin/transfer.sh '/path_to_your_surveilled_directory/"$line"/' /path_to_your_target_dir/"$unix_user"/\" events=\"create,move,close_write\">/path_to_your_surveilled_directory/"$line"</path>">>/$configfile
done
echo "</watchlist>
</config>" >>/$configfile
service iwatch stop
sleep 5
service iwatch start && echo "a new iwatch config was created and the daemon was restarted" || echo "something went wrong with restarting the daemon, please check manually"
