#!/bin/sh

# Clean out unused old images


podman image prune -a -f --filter "until=24h"

