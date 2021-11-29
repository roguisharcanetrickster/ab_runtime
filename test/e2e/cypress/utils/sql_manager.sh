#!/bin/bash
Folder=$1
Service=$2_db

# Check we have enough arguments
if [ $# -lt 3 ]
then
	echo "Missing expected arguments."
	echo "sql_manager folder stack file1 file2 ..."
	exit
fi

# Check the db service exists
ID_Service=`docker ps | grep $Service | awk '{ print $1 }'`
if [ -z "$ID_Service" ]
then
	echo ""
	echo "couldn't find process matching '$Service' "
	echo ""
	echo "current processes :"
	docker ps
	echo ""
	exit
fi

for FILE_SQL in "$@"; do
	# Skip first 2 arguments
	if [ $FILE_SQL == $1 ] || [ $FILE_SQL == $2 ]
	then
		continue
	fi

	DB_Init=`cat ./cypress/integration/$Folder/test_setup/sql/$FILE_SQL`
	docker exec $ID_Service bash -c "echo '$DB_Init' > ./sql/$FILE_SQL"
	docker exec $ID_Service bash -c "mysql -u root -proot \"appbuilder-admin\" < ./sql/$FILE_SQL"
	docker exec $ID_Service bash -c "rm ./sql/$FILE_SQL"
done
