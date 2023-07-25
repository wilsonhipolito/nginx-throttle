#!/usr/bin/env bash

VERSION=$1
EXTRA_PARAMS=$2
MODULE=nginx-throttle

if [ -z "$VERSION" ]; then
  docker build . --platform linux/amd64 -f Dockerfile -t ${MODULE}:latest -t nxlogy/${MODULE}:latest ${EXTRA_PARAMS}
else
  docker build . --platform linux/amd64 -f Dockerfile -t ${MODULE}:latest -t nxlogy/${MODULE}:latest \
    -t ${MODULE}:${VERSION} -t nxlogy/${MODULE}:${VERSION} ${EXTRA_PARAMS}
fi
