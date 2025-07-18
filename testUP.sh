#!/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport
# ? CYPRESS_STACK ??
docker stack deploy -c docker-compose.dev.yml -c ./test/setup/test-compose.yml test_$STACKNAME
