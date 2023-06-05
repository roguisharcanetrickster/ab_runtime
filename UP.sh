#!/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport

if [ "$PLATFORM" = "podman" ]
then
	systemctl --user start pod-${STACKNAME}.service
else
	docker stack deploy -c docker-compose.yml -c docker-compose.override.yml ${STACKNAME}
fi
