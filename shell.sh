#!/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport

ID=`${PLATFORM} container ls -f name=${STACKNAME}_api_sails --format={{.ID}}`
if [ "$ID" == "" ]
then
    echo "${STACKNAME} is not running"
else
    ${PLATFORM} exec -it "$ID" bash
fi

