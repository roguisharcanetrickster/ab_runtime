#!/usr/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport

systemctl --user stop pod-${STACKNAME}.service

echo -n "Waiting for containers to stop..."
while [ "`podman ps --noheading | grep ${STACKNAME}`" != "" ]
do
    echo -n "."
    sleep 1
done
echo "OK"

echo "Starting again"
systemctl --user start pod-${STACKNAME}.service

