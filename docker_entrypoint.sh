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
export SERVICE_HOSTNAME=${NGINX_SERVICE_HOSTNAME:-netfeedr-ratelimit-proxy}

echo "Env variable declared : "
env
echo "-----"

if [[ -v NGINX_LISTEN_HOST ]]; then
	# it is set, but could be empty
	echo "NGINX_LISTEN_HOST is set (${NGINX_LISTEN_HOST})"
	if [[ -z "${NGINX_LISTEN_HOST}" ]]; then
		# it is empty
		echo "NGINX_LISTEN_HOST is empty"
		LISTEN_HOST=""
	else
		echo "NGINX_LISTEN_HOST is not empty"
		LISTEN_HOST="${NGINX_LISTEN_HOST}:"
	fi
else
	# it is not set
	echo "NGINX_LISTEN_HOST is not set"
	LISTEN_HOST="0.0.0.0:"
fi

export LISTEN_HOST

envsubst '${ZONE_MEMORY} ${RATE_LIMIT} ${LISTEN_HOST} ${LISTEN_PORT} ${BURST} ${APPLICATION_ENDPOINT} ${NODELAY} ${PROXY_TIMEOUT} ${SERVICE_HOSTNAME}' < /etc/nginx/conf.d/10-throttle.conf.template > /etc/nginx/conf.d/default.conf
envsubst '${WORKER_CONNECTIONS}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
nginx -g "daemon off;"
