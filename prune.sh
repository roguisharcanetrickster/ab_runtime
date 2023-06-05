#!/bin/sh

# Import ENV variables
set -o allexport
source .env
set +o allexport


# Clean out unused old images
$PLATFORM image prune -a -f --filter "until=24h"

