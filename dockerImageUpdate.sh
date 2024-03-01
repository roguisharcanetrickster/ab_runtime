#!/bin/bash
#---- dockerImageUpdate.sh -----------------------------------------------------
# equivalent to dockerImageUpdate.js but can be run without node
# - if node is installed `node dockerImageUpdate` will be faster as some tasks
# will get run in parallel.
# - requires jq (https://github.com/jqlang/jq)
#-------------------------------------------------------------------------------
# Import ENV variables
set -o allexport
source .env
set +o allexport

migrationContainer="update_script_db_migrations" # ref for cleaning up the migration container
cmd=${PLATFORM:-"docker"}
echo "Updating images for $cmd"

# Check dependencies
if ! command -v jq &> /dev/null
then
    echo "missing required tool: jq"
    exit 1
fi
# Check for docker / podman
if ! command -v "$cmd" &> /dev/null
then
    echo "missing required tool: $cmd"
    exit 1
fi
# Check that our stack is running
if [[ $($cmd ps | awk -v test="${STACKNAME}.api_sails" ' $0 ~ test { sum += 1} END {print sum}') -eq 0 ]];
then
   echo "This script expects the 'api_sails' service to be running with the stack name $STACKNAME"
   echo "We couldn't find it. Try running './UP.sh' first?"
   exit 1
fi

echo "Using runtime version $(jq -r '.version' version.json)"

# Read the latest Versions
declare -A services="($(
   jq -r '.services | to_entries | .[] | "[" + .key + "]=" + .value' version.json
))"

branchMigrate=${AB_MIGRATION_MANAGER_VERSION:-"master"}
images=("digiserve/ab-migration-manager:$branchMigrate")
# Update env variables and prepare image list to pull later
for service in "${!services[@]}";
do
   SERVICE_VAR="AB_$(echo "$service" | tr '[:lower:]' '[:upper:]')_VERSION"
   VERSION="${services[$service]}"
   # set the var in the current env
   eval "${SERVICE_VAR}=$VERSION"
   # update .env file
   sed -i "s/^${SERVICE_VAR}=.*/${SERVICE_VAR}=${VERSION}/" ./.env
   # add dockerimage to our images array
   images+=("docker.io/digiserve/ab-$(echo "$service" | tr "_" "-" ):$VERSION")
done

# Pull images from dockerhub
echo "Updating Images:"
for image in ${images[@]}
do
   eval "$cmd pull $image && echo "" && $cmd image ls | grep $(echo "$image" | tr ":" "\n" | head -1 )"
done

# Perform DB Migrations
echo "DB Migrations:"
eval "$cmd run --env-file .env --network=${STACKNAME}_default --name=$migrationContainer digiserve/ab-migration-manager:$branchMigrate node app.js"
eval "$cmd stop $migrationContainer"
sleep 1;
eval "$cmd rm $migrationContainer"

echo "Updating Services:"
if [[ "$cmd" = "podman" ]]; then
   # Podman compose up won't update running containers so bring down one by one
   # to update to the image
   toRestart=()
   for service in "${!services[@]}";
   do
      # Only restart if the image is different
      id=$(podman ps --format 'table {{.ID}}\t{{.Image}}\t{{.Names}}' | awk -v stack="$STACKNAME" -v service="$service" -v ver="${services[$service]}" '$3 ~ stack && $3 ~ service && $2 !~ ver { print $1 }')
      if [[ -n $id ]]; then
         toRestart+=("$id")
      fi
   done
   echo "${id[@]}"
   for id in $toRestart
   do
      echo "$id"
      podman stop $id
      podman rm $id
   done
   podman compose -f docker-compose.yml -f docker-compose.override.yml -p $STACKNAME up -d;
   # podman stop / rm //compose up
else
   docker stack deploy -c docker-compose.yml -c docker-compose.override.yml $STACKNAME;
fi

echo "Clean up old images"
# Don't remove images that are currently running or ab-migration-manager:master
# use Associative array to only get unique
declare -A usedImages=(["digiserve/ab-migration-manager:${branchMigrate}"]="")
eval "$($cmd ps --format "usedImages+=([\"{{.Image}}\"]=\"\");")"
doNotRemove=""
for used in ${!usedImages[@]}
do
   id="$($cmd images --format "{{.ID}}\\t{{.Repository}}:{{.Tag}}" | awk -v test="$used" '$2 ~ test {print $1}')"
   if [[ -n $id ]]; then
     doNotRemove+="\\|$id"
   fi
done
doNotRemove=${doNotRemove#\\|}
toRemove=""
# Only clean up ab-service-* images
for image in ${images[@]}
do
   repo=${image#docker.io/}
   repo=${repo%:*}
   result="$($cmd images --format "{{.ID}}\\t{{.Repository}}:{{.Tag}}" | grep -v "$doNotRemove" | awk -v test="${repo}" '$2 ~ test {print $1}')"
   if [[ -n $result ]]; then
      toRemove+="$(echo "$result" | tr "\n" " ")";
   fi
done
if [[ -n $toRemove ]]; then
# TODO: still removing some used images (which in podman kills running containers).
# Disable until can ensure it is safe.
echo "${toRemove[@]}"
#   eval "$cmd rmi $toRemove -f"
fi
echo "... done"
exit 0

