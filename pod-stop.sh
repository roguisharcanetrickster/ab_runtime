#!/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport

systemctl --user stop pod-${STACKNAME}.service
