#!/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport

ID=`podman container ls -f name=${STACKNAME}_api_sails --format={{.ID}}`
if [ "$ID" == "" ]
then
    echo "${STACKNAME} is not running"
else
    podman exec -it "$ID" bash
fi

