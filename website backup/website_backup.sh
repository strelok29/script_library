#!/bin/sh

##CONFIG START##
DATE=`date +%Y-%m-%d`
#website folder
WEBDIR='/var/www'
#nginx config folder
CONFIGDIR='/etc/nginx/sites-available'
DESTDIR='/home/'
REMOTEDIR="backup-$DATE"
ENDPOINT=''
ACCESS_KEY=''
SECRET_KEY=''
REGION=""
BUCKET=""
BUCKET_HOST=""
##CONFIG END##

mkdir -p $DESTDIR
cd $WEBDIR
#compress all of the sites file into 1 file and move it to $DESTDIR
tar -czPf $DATE-web-backup.tar.gz *
mv $DATE-web-backup.tar.gz $DESTDIR
cd $CONFIGDIR
#compress all of the nginx config file into 1 file and move it to $DESTDIR
tar -czPf $DATE-nginx-backup.tar.gz *
mv $DATE-nginx-backup.tar.gz $DESTDIR

#upload backup to s3 using s3cmd
#web files
s3cmd put --access_key=$ACCESS_KEY --bucket-host='$BUCKET_HOST' --secret_key=$SECRET_KEY --region=$REGION $DESTDIR/$DATE-web-backup.tar.gz s3://$BUCKET/$REMOTEDIR/
#nginx config files
s3cmd put --access_key=$ACCESS_KEY --bucket-host='$BUCKET_HOST' --secret_key=$SECRET_KEY --region=$REGION $DESTDIR/$DATE-nginx-backup.tar.gz s3://$BUCKET/$REMOTEDIR/

#delete local backup
rm -r $SRC