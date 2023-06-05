#!/usr/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport

./Down.sh

echo -n "Waiting for containers to stop..."
while [ "`podman ps --noheading | grep ${STACKNAME}`" != "" ]
do
    echo -n "."
    sleep 1
done
echo "OK"

echo "Starting again"
./UP.sh

