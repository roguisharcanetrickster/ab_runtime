#!/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport

if [ "$PLATFORM" = "podman" ]
then
    CMD="podman logs"
    SUFFIX="_1"
else
    CMD="docker service logs"
    SUFFIX=""
fi

case "$1" in
    "db")
        $CMD --tail 100 -f ${STACKNAME}_db${SUFFIX}
        ;;
    "web")
        $CMD --tail 100 -f ${STACKNAME}_web${SUFFIX}
        ;;
    "ab")
        $CMD --tail 100 -f ${STACKNAME}_appbuilder${SUFFIX}
        ;;
    "sails")
        $CMD --tail 500 -f ${STACKNAME}_api_sails${SUFFIX}
        ;;
    "redis")
        $CMD --tail 100 -f ${STACKNAME}_redis${SUFFIX}
        ;;
    "pm")
        $CMD --tail 100 -f ${STACKNAME}_process_manager${SUFFIX}
        ;;
    "ne")
        $CMD --tail 100 -f ${STACKNAME}_notification_email${SUFFIX}
        ;;
    "system")
        if [ "$PLATFORM" = "podman" ]
        then
            journalctl --user -u pod-${STACKNAME}.service -n 500 -f
        else
            node logs.js
        fi
        ;;
    *)
        echo "Usage:"
        echo "  $0 db"
        echo "  $0 web"
        echo "  $0 ab"
        echo "  $0 sails"
        echo "  $0 redis"
        echo "  $0 pm"
        echo "  $0 ne"
        echo "  $0 system"
        ;;
esac

