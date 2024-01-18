#!/bin/bash
# author: andreaswendlandt
# desc: trigger a backup in the jira webgui through the rest api,\
# desc: create a zip file and download that file afterwards
# last modified: 13.06.2015

USERNAME=your_user
PASSWORD=your_password
INSTANCE=your_jira_url
LOCATION=your_backup_location
 
# grabs cookies and creates the backup
TODAY=`date +%Y%m%d`
COOKIE_FILE_LOCATION=jiracookie
curl --silent -u $USERNAME:$PASSWORD --cookie-jar $COOKIE_FILE_LOCATION https://${INSTANCE}/Dashboard.jspa --output /dev/null

curl -s --cookie $COOKIE_FILE_LOCATION --header "X-Atlassian-Token: no-check" -H "X-Requested-With: XMLHttpRequest" -H "Content-Type: application/json" -X\
 POST https://${INSTANCE}/rest/obm/1.0/runbackup -d '{"cbAttachments":"true" }' 
rm $COOKIE_FILE_LOCATION
 
#ensure that the backup is created and ready for downloading
until wget --user=$USERNAME --password=$PASSWORD --spider https://${INSTANCE}/webdav/backupmanager/JIRA-backup-${TODAY}.zip >/dev/null 2>/dev/null; do
sleep 30
done
 
#now that we are sure that the backup exists on the webdav, the file get's copied to your_backup_location
wget --user=$USERNAME --password=$PASSWORD -t 0 --retry-connrefused https://${INSTANCE}/webdav/backupmanager/JIRA-backup-${TODAY}.zip -P $LOCATION >/dev/null 2>/dev/null
