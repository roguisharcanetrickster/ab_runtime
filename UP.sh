#!/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport

Dev=
Test=
Quiet=
architecture=
case $(uname -m) in
    arm64)  architecture="arm64" ;;
esac
# Read flags -d for dev, -t for test, -q for no logs
while getopts dtq name
do
    case $name in
    d)    Dev="true";;
    t)    Test="true";;
    q)    Quiet="true"
    esac
done
File="docker-compose.dev.yml"
TestOveride=""
if [[ -n $Dev ]]
then
    File="docker-compose.dev.yml"
fi
if [[ -n $Test ]]
then
    TestOveride="-c ./test/setup/ci-test.overide.yml"
    if [[ $architecture = "arm64" ]]
    then
        TestOveride="-f ./test/setup/ci-test.overide.yml"
    fi
fi
nohup node ab_system_monitor.js &> /dev/null &
if [[ $architecture = "arm64" ]]
then
    docker-compose -f $File -f docker-compose.override.yml $TestOveride up -d
else
    docker stack deploy -c $File -c docker-compose.override.yml $TestOveride ${STACKNAME}
fi
if [[ -z $Quiet ]]
then
./logs.js
fi