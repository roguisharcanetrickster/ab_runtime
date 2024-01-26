#!/usr/bin/bash

# Pulls all the latest AB docker images.

# Import ENV variables
set -o allexport
source .env
set +o allexport

${PLATFORM} image pull \
    docker.io/digiserve/ab-db:${AB_DB_VERSION} \
    docker.io/library/redis:latest \
    docker.io/digiserve/ab-api-sails:${AB_API_SAILS_VERSION} \
    docker.io/digiserve/ab-appbuilder:${AB_APPBUILDER_VERSION} \
    docker.io/digiserve/ab-custom-reports:${AB_CUSTOM_REPORTS_VERSION} \
    docker.io/digiserve/ab-definition-manager:${AB_DEFINITION_MANAGER_VERSION} \
    docker.io/digiserve/ab-file-processor:${AB_FILE_PROCESSOR_VERSION} \
    docker.io/digiserve/ab-log-manager:${AB_LOG_MANAGER_VERSION} \
    docker.io/digiserve/ab-notification-email:${AB_NOTIFICATION_EMAIL_VERSION} \
    docker.io/digiserve/ab-process-manager:${AB_PROCESS_MANAGER_VERSION} \
    docker.io/digiserve/ab-relay:${AB_RELAY_VERSION} \
    docker.io/digiserve/ab-tenant-manager:${AB_TENANT_MANAGER_VERSION} \
    docker.io/digiserve/ab-user-manager:${AB_USER_MANAGER_VERSION} \
    docker.io/digiserve/ab-web:${AB_WEB_VERSION}
