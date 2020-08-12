#!/bin/sh

set -e
SCRIPT_DIR=`realpath $(dirname "$0")`

cd $SCRIPT_DIR

docker-compose down

./deleteNetwork.sh