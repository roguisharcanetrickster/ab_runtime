#!/usr/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport

if [ "$PLATFORM" = "podman" ]
then
    CMD="podman logs"
else
    CMD="docker service logs"
fi

case "$1" in
    "db")
        $CMD --tail 100 -f ${STACKNAME}_db_1
        ;;
    "web")
        $CMD --tail 100 -f ${STACKNAME}_web_1
        ;;
    "ab")
        $CMD --tail 100 -f ${STACKNAME}_appbuilder_1
        ;;
    "sails")
        $CMD --tail 500 -f ${STACKNAME}_api_sails_1
        ;;
    "redis")
        $CMD --tail 100 -f ${STACKNAME}_redis_1
        ;;
    "pm")
        $CMD --tail 100 -f ${STACKNAME}_process_manager_1
        ;;
    "ne")
        $CMD --tail 100 -f ${STACKNAME}_notification_email_1
        ;;
    "system")
        journalctl --user -u pod-${STACKNAME}.service -n 500 -f
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

