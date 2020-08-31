#!/bin/sh

set -e
SCRIPT_DIR=`realpath $(dirname "$0")`

LICENSE_FILE=waterstream.license
export KSQL_VERSION=4.1.4

echo KSQL_VERSION=$KSQL_VERSION

if test -f "$LICENSE_FILE"; then
  echo License file found
else
  echo You need lincense file $LICENSE_FILE to proceed 1>&2
  exit 1
fi

#Copy without overwriting
cp -nv config_examples/* . || true
cp -nv config_examples/.env . || true

echo Making sure that network exists..
./createNetwork.sh || true

docker-compose up -d
