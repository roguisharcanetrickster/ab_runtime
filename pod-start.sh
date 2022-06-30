#!/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport

systemctl --user start pod-${STACKNAME}.service
