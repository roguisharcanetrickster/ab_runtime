#!/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport

if [ "$PLATFORM" = "podman" ]
then
	systemctl --user stop pod-${STACKNAME}.service
else
	docker stack rm ${STACKNAME}
fi
