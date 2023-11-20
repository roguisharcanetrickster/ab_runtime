#!/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport

docker stack rm test_$STACKNAME
