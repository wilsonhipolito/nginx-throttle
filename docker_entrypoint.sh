#!/usr/bin/env bash

export ZONE_MEMORY=${NGINX_THROTTLE_MEM_LIMIT:-10m}
export RATE_LIMIT=${NGINX_THROTTLE_RATE_LIMIT:-100r\/s}
export LISTEN_PORT=${NGINX_LISTEN_PORT:-80}
export BURST=${NGINX_THROTTLE_BURST:-10}
export PROXY_TIMEOUT=${NGINX_PROXY_TIMEOUT:-90}
export WORKER_CONNECTIONS=${NGINX_WORKER_CONNECTIONS:-4096}

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

RESOLVER_IP="$(cat /etc/resolv.conf | grep -v '^#' | grep nameserver | awk '{print $2}' | head -n 1)"
export RESOLVER_IP

echo "Env variable declared : "
env
echo "-----"

echo "Copying template using envsubst using defined environment variables"
envsubst '${RESOLVER_IP} ${ZONE_MEMORY} ${RATE_LIMIT} ${LISTEN_HOST} ${LISTEN_PORT} ${BURST} ${PROXY_TIMEOUT}' \
	< /app/10-throttle.conf.template \
	> /usr/local/nginx/conf/default.conf

envsubst '${WORKER_CONNECTIONS}' \
	< /app/nginx.conf.template \
	> /usr/local/nginx/conf/nginx.conf

cp /app/sysctl.conf.template /etc/sysctl.conf

mkdir -p /var/log/nginx
touch /var/log/nginx/error.log

# Start the nginx process
echo "Starting the tengine nginx daemon"
 /usr/local/nginx/sbin/nginx -g "daemon off;"
