#!/bin/bash

SRV_NAME='test'
TIME=`date +%y%m%d`
FTPU="user1"
FTPP="user1pass"
FTPS="test.com"



for i in `cat /etc/passwd| grep -v "nobody" | cut -d: -f1,3 | sed 's/:/ /g' | awk '$2 >= 1000  {print $1;}'`; do
    SRCDIR=/home/$i/public/
    DESDIR=/home/$i/backups/
    DB_NAME=$i"_db"
    FILENAME=backup-files-$i.tar.gz
    echo "- backup user $i"

    mkdir -p $DESDIR
    find $DESDIR -name "backup-*" -exec rm -f {} \;
    mysqldump $DB_NAME --single-transaction --quick --lock-tables=false > $DESDIR/backup-db-$i.sql
    tar -cpzf $DESDIR/$FILENAME $SRCDIR
    lftp -u $FTPU,$FTPP -e "mkdir -p /$SRV_NAME/$TIME; mkdir -p /$SRV_NAME/$TIME/$i/ ; mirror -R $DESDIR /$SRV_NAME/$TIME/$i/ ; quit" $FTPS
    find $DESDIR -name "backup-*" -exec rm -f {} \;
done
