#!/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport

if [[ -n "$SYSTEMD_SERVICE" ]]; then
   systemctl --user stop ${SYSTEMD_SERVICE}.service
elif [ "$PLATFORM" = "podman" ]; then
   podman compose -p $STACKNAME -f docker-compose.yml down
else
   kill $( ps aux | grep "node ab_system_monitor.js" | grep -v "grep" | awk '{print $2}' ) &> /dev/null
	docker stack rm ${STACKNAME}
fi
