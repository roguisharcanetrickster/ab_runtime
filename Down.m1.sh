#!/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport

kill $( ps aux | grep "node ab_system_monitor.js" | grep -v "grep" | awk '{print $2}' ) &> /dev/null
# docker stack rm ${STACKNAME}
## Apple M1 fix: use docker-compose until we fix the docker stack issues:
docker-compose down