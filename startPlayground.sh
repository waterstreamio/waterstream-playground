#!/bin/sh

set -e
SCRIPT_DIR=`realpath $(dirname "$0")`

LICENSE_FILE=waterstream.license

if test -f "$LICENSE_FILE"; then
  echo License file found
else
  echo You need lincense file $LICENSE_FILE to proceed 1>&2
  exit 1
fi

ARCH=$(uname -m)
case ${ARCH} in
  arm64|aarch64|arm64v8)
    echo ARM CPU detected: $ARCH
    ENV_SRC=".env.arm64"
  ;;
  *)
    echo x86 CPU detected: $ARCH
    ENV_SRC=".env.x86"
  ;;
esac

#Copy without overwriting
cp -nv config_examples/* . || true
cp -nv config_examples/${ENV_SRC} ./.env || true

echo Making sure that network exists..
./createNetwork.sh || true

echo Starting the containers..
docker-compose up -d
