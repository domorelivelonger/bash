#!/bin/bash

# MySQL info
DB_USER='your-db-user'
DB_PSWD='your-db-password'
DB_HOST='localhost'

# Backup path, no trailing slash!
BACKUP_PATH='/backup/sql/path'

## End editing!
DATE_BAK="$(date +"%Y-%m-%d")"

echo "Converting InnoDB to MyISAM.."
echo "==========================================================="

CMDDB="$(echo show databases | MYSQL_PWD=$DB_PSWD mysql -u $DB_USER -h $DB_HOST | grep -v Database)"

for DB in $CMDDB
do 
	echo "Found database: $DB"
	echo "-----------------------------------------------------------"

	echo "Backing up before executing, just in case.."
	echo "..........................................................."
	MYSQL_PWD=$DB_PSWD mysqldump -u $DB_USER -h $DB_HOST | gzip -9 > $BACKUP_PATH/bak-$DB-$DATE_BAK.sql.gz
	echo "Backup done. Saved to "$BACKUP_PATH/bak-$DB-$DATE_BAK.sql.gz

	CMDTB="$(echo "show tables" | MYSQL_PWD=$DB_PSWD mysql -u $DB_USER -h $DB_HOST $DB | grep -v Tables_in_)"

	## Find FOREIGN KEYs and drop it
	CHKFRGN="$(echo "SELECT i.TABLE_NAME, i.CONSTRAINT_NAME, k.COLUMN_NAME, k.REFERENCED_TABLE_NAME, k.REFERENCED_COLUMN_NAME FROM information_schema.TABLE_CONSTRAINTS i LEFT JOIN information_schema.KEY_COLUMN_USAGE k ON i.CONSTRAINT_NAME = k.CONSTRAINT_NAME WHERE i.CONSTRAINT_TYPE = 'FOREIGN KEY' AND i.TABLE_SCHEMA = DATABASE()" | MYSQL_PWD=$DB_PSWD mysql -u $DB_USER -h $DB_HOST $DB | grep -v TABLE)"
	OIFS=$IFS
	IFS=$'\n'
	for FKEY in $CHKFRGN
	do
		## Parse Keys
		declare -a A_FKEY
		FFKEY="$(echo $FKEY | sed -e 's/[[:space:]]/ /g')"
		IFS=' ' read -a A_FKEY <<< "$FFKEY"
		
		F_TB_NAME=${A_FKEY[0]}
		F_TB_CONS=${A_FKEY[1]}
		F_TB_COL=${A_FKEY[2]}
		F_TB_REF=${A_FKEY[3]}
		F_TB_REF_COL=${A_FKEY[4]}
		
		## Drop
		F_DROP="ALTER TABLE $F_TB_NAME DROP FOREIGN KEY $F_TB_CONS"
		echo $F_DROP | MYSQL_PWD=$DB_PSWD mysql -u $DB_USER -h $DB_HOST $DB
	done
	OIFS=$IFS
	
	## Now find the InnoDBs!
	for TABLE in $CMDTB
	do
		TABLE_TYPE="$(echo "show create table $TABLE" | MYSQL_PWD=$DB_PSWD mysql -u $DB_USER -h $DB_HOST $DB | grep -v 'Create Table' | sed -e 's/.*ENGINE=\([[:alnum:]]*\).*/\1/')"
		#echo "> $TABLE"

		if [ $TABLE_TYPE = "InnoDB" ]
		then
			echo "> $TABLE"
			MYSQL_PWD=$DB_PSWD mysqldump -u $DB_USER -h $DB_HOST $DB $TABLE | gzip -9 > $BACKUP_PATH/bak-$DB-$TABLE-$DATE_BAK.sql.gz
			echo ">> Converting to MyISAM!"
			echo "ALTER TABLE $TABLE ENGINE=MyISAM" | MYSQL_PWD=$DB_PSWD mysql -u $DB_USER -h $DB_HOST $DB
		fi
	done

	## Just print separator
	echo " "

done
