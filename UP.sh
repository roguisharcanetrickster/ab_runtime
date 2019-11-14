#!/bin/bash
Dev=$1
File="docker-compose.dev.yml"
if [ -z "$Dev" ]
then
	File="docker-compose.yml"
fi
docker stack deploy -c $File ab
./logs.js