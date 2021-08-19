#!/bin/bash
Dev=$1
File="docker-compose.yml"
if [ -z "$Dev" ]
then
	File="docker-compose.dev.yml"
fi
nohup node ab_system_monitor.js &> /dev/null & 
docker stack deploy -c $File -c docker-compose.override.yml ab
./logs.js
