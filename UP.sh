#!/bin/bash
Dev=$1
File="docker-compose.yml"
if [ -z "$Dev" ]
then
	File="docker-compose.dev.yml"
fi
docker stack deploy -c $File ab
./logs.js
