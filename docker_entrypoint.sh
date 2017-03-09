#!/bin/bash

if ! [[  $NGINX_BACKEND_ENDPOINT ]] ; then
  echo "You must define NGINX_BACKEND_ENDPOINT variable!"
  exit 1
fi
if [[ $NGINX_SET_NODELAY -eq "true" ]] ; then
  export NODELAY="nodelay"
fi
export ZONE_MEMORY=${NGINX_THROTTLE_MEM_LIMIT:-10m}
export RATE_LIMIT=${NGINX_THROTTLE_RATE_LIMIT:-100r\/s}
export LISTEN_PORT=${NGINX_LISTEN_PORT:-80}
export BURST=${NGINX_THROTTLE_BURST:-10}
export APPLICATION_ENDPOINT=${NGINX_BACKEND_ENDPOINT}
export PROXY_TIMEOUT=${NGINX_PROXY_TIMEOUT:-90}
export WORKER_CONNECTIONS=${NGINX_WORKER_CONNECTIONS:-4096}
envsubst '${ZONE_MEMORY} ${RATE_LIMIT} ${LISTEN_PORT} ${BURST} ${APPLICATION_ENDPOINT} ${NODELAY} ${PROXY_TIMEOUT}' < /etc/nginx/conf.d/10-throttle.conf.template > /etc/nginx/conf.d/default.conf
envsubst '${WORKER_CONNECTIONS}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
nginx -g "daemon off;"
