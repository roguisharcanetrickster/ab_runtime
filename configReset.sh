#!/bin/bash
docker stack rm ab
Up=$(docker stack deploy -c config-compose.yml ab 2>&1 >/dev/null )
while [ ! -z "$Up" ]
do
	echo "... not ready yet"
	sleep 1
	echo "    retrying"
	Up=$(docker stack deploy -c config-compose.yml ab 2>&1 >/dev/null )
done

Done=$(docker service logs ab_config | grep complete)
while [ -z "$Done" ]
do
	sleep 1
	Done=$(docker service logs ab_config | grep complete)
done
docker stack rm ab