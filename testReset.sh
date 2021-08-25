#!/bin/bash
ID_Service=`docker ps | grep 'test_ab_db' | awk '{ print $1 }'`
if [ -z "$ID_Service" ]
then
	echo ""
	echo "couldn't find process matching '$Service' "
	echo ""
	echo "current processes :"
	docker ps
	echo ""
else
	docker exec $ID_Service bash reset.sh
fi
