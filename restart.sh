#!/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport

./Down.sh

if [ "$PLATFORM" = "podman" ]
then
   CMD="podman ps --noheading"
else
   CMD="docker ps"
fi

echo -n "Waiting for containers to stop..."
while [ "`${CMD} | grep ${STACKNAME}`" != "" ]
do
    echo -n "."
    sleep 1
done
echo "OK"

echo "Starting again"
./UP.sh
