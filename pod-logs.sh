#!/usr/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport

case "$1" in
    "db")
        podman logs --tail 100 -f ${STACKNAME}_db_1
        ;;
    "sails")
        podman logs --tail 500 -f ${STACKNAME}_api_sails_1
        ;;
    "redis")
        podman logs --tail 100 -f ${STACKNAME}_redis_1
        ;;
    "pm")
        podman logs --tail 100 -f ${STACKNAME}_process_manager_1
        ;;
    "ne")
        podman logs --tail 100 -f ${STACKNAME}_notification_email_1
        ;;
    "system")
        journalctl --user -u pod-${STACKNAME}.service -n 500 -f
        ;;
    *)
        echo "Usage:"
        echo "  $0 db"
        echo "  $0 sails"
        echo "  $0 redis"
        echo "  $0 pm"
        echo "  $0 ne"
        echo "  $0 system"
        ;;
esac

