#!/bin/bash

architecture=
case $(uname -m) in
    arm64)  architecture="arm64" ;;
esac
# Import ENV variables
set -o allexport
source .env
set +o allexport

kill $( ps aux | grep "node ab_system_monitor.js" | grep -v "grep" | awk '{print $2}' ) &> /dev/null
if [[ $architecture = "arm64" ]]
then
    docker-compose down
else
    docker stack rm ${STACKNAME}
fi