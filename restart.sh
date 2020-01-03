##!/bin/bash
Service=$1
if [ -z "$Service" ]
then
	echo ""
	echo " restart.sh [service]  "
	echo "            --> provide the container ref to use"
	echo "                [ api_sails, db, etc... ]"
	echo ""
else
	ID_Service=`docker service ls | grep "$Service" | awk '{ print $1 }'`
	if [ -z "$ID_Service" ]
	then
		echo ""
		echo "couldn't find service matching '$Service' "
		echo ""
		echo "current services :"
		docker service ls
		echo ""
	else
    	docker service scale  $ID_Service=0
		docker service scale  $ID_Service=1
		echo ""
		echo "services:"
		docker service ls
		echo ""
		echo "processes:"
		docker ps
		echo ""
		./logs.js 
	fi
fi
