#!/bin/bash

if ! [[  $NGINX_BACKEND_PORT ||  $NGINX_BACKEND_ADDR ]] ; then
  echo "You must define NGINX_BACKEND_ADDR and NGINX_BACKEND_PORT variables!"
  exit 1
fi
if [[ $NGINX_SET_NODELAY -eq "true" ]] ; then
  export NODELAY="nodelay"
fi
export ZONE_MEMORY=${NGINX_THROTTLE_MEM_LIMIT:-10m}
export RATE_LIMIT=${NGINX_THROTTLE_RATE_LIMIT:-100r\/s}
export LISTEN_PORT=${NGINX_LISTEN_PORT:-80}
export BURST=${NGINX_THROTTLE_BURST:-10}
export APPLICATION_NAME=${NGINX_BACKEND_ADDR}
export APPLICATION_PORT=${NGINX_BACKEND_PORT}

envsubst '${ZONE_MEMORY} ${RATE_LIMIT} ${LISTEN_PORT} ${BURST} ${APPLICATION_NAME} ${APPLICATION_PORT} ${NODELAY}' < /etc/nginx/conf.d/10-throttle.conf.template > /etc/nginx/conf.d/default.conf

nginx -g "daemon off;"
