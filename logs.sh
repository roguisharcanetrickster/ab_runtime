#!/bin/bash
Service=$1
if [ -z "$Service" ]
then
	echo ""
	echo " logs.sh [service]  "
	echo "            --> provide the container ref to use"
	echo "                [ api_sails, db, file_processor, etc... ]"
	echo ""

###
### Attempt to combine all logs into 1 feed:
###
# 	ID_Service=`docker service ls | grep "ab_" | awk '{ print $1 }'`
# echo "$ID_Service"
# echo "-----------"
# 	MultiService=""
# 	for ID in $ID_Service; do 
# 		if [ -z "$MultiService" ]
# 		then
# 			MultiService+="docker service logs -f $ID"
# 		else
# 			MultiService+=" & docker service logs -f $ID"
# 		fi
# 	done; 
# 	Command="($MultiService) | sort"

# echo "$Command"
# 	eval $Command

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
        docker service logs -f $ID_Service
	    # docker service logs -f soa_$Service
	fi
fi
