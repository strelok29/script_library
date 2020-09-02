#!/bin/sh

##CONFIG START##
DATE=`date +%Y-%m-%d`
#DIR where you want to put the local download
SRC='/home/'
REMOTEDIR="backup-$DATE"
ENDPOINT=''
#AWS access key
ACCESS_KEY=''
#AWS secret key
SECRET_KEY=''
REGION=""
BUCKET=""
BUCKET_HOST=""
##CONFIG END##


#create dir if not exist
mkdir -p $SRC
#use config.cnf to store mysql credentials or can use /etc/mysql/debian.cnf for debian
#backup every db in the server
for DB in $(mysql --defaults-extra-file=config.cnf -BNe 'show databases' | grep -Ev 'mysql|information_schema|performance_schema')
do
mysqldump --defaults-extra-file=config.cnf --force $DB > $SRC/$DB.sql
mysqlcheck --defaults-extra-file=config.cnf --auto-repair --optimize $DB
done

cd $SRC
#count exported db to make sure if correct
echo $(ls *sql| wc -l) 'databases has been backup'
#tar all of the exported db
tar -czPf $DATE-db-backup.tar.gz *.sql
#remove all of the exported db  
rm *.sql

#upload backup to s3 using s3cmd
s3cmd put --access_key=$ACCESS_KEY --bucket-host='$BUCKET_HOST' --secret_key=$SECRET_KEY --region=$REGION $SRC/$DATE-db-backup.tar.gz s3://$BUCKET/$REMOTEDIR/

#delete local backup
rm -r $SRC