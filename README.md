# Nginx Throttle

A simple Docker container with TEngine as a forward proxy to rate limit http(s) requests


### Docker compose

```
version: '2'

services:
   nginx-rate-limiter:
     image: nxlogy/nginx-throttle:latest
     restart: always
     ports:
       - "3000:3000"
     environment:
       NGINX_THROTTLE_RATE_LIMIT: "200r/s"
			 NGINX_THROTTLE_BURST: "500"
			 NGINX_LISTEN_HOST: ""
			 NGINX_LISTEN_PORT: "3000"
```

### Just Docker

Start the `nginx-throttle` with a link to your app:
```
docker run \
	-d \
	--rm \
	--name=nginx-rate-limiter \
	-p 80:80 \
	-e NGINX_THROTTLE_RATE_LIMIT="200r/m" \
	nxlogy/nginx-throttle:latest
```

## Configuration

All settings are passed by environment variables:

|Variable                  |Default value|Required|
|--------------------------|-------------|--------|
|NGINX_THROTTLE_MEM_LIMIT  |`10m`        | No     |
|NGINX_THROTTLE_RATE_LIMIT |`100r/s`     | No     |
|NGINX_THROTTLE_BURST      |`10`         | No     |
|NGINX_PROXY_TIMEOUT       |`90`         | No     |
|NGINX_WORKER_CONNECTIONS  |`4096`       | No     |
|NGINX_LISTEN_HOST         |`0.0.0.0`    | No     |
|NGINX_LISTEN_PORT         |`80`         | No     |

### Details

##### NGINX_LISTEN_HOST
- Value type is _string_.
- Default value is `0.0.0.0`.

If specified as empty (""), it will not be specified in the nginx configs.

##### NGINX_LISTEN_PORT
- Value type is _number_.
- Default value is `80`.

Set the port where Nginx should listen on.

##### NGINX_PROXY_TIMEOUT
- Value type is _number_.
- Default value is `90`.

Number in seconds for proxy timeout.

##### NGINX_THROTTLE_BURST
- Value type is _number_.
- Default value is `10`.

Excessive requests are delayed until their number exceeds the maximum burst size in which case the request is terminated with an error 503 (Service Temporarily Unavailable). This Environment variable sets the size of the burst.

##### NGINX_THROTTLE_MEM_LIMIT
- Value type is _string_.
- Default value is `10m`.

Set the size of memory where the states are kept. In particular, the state stores the current number of excessive requests.

##### NGINX_THROTTLE_RATE_LIMIT
- Value type is _string_.
- Default value is `100r/s`.

Set the maximum rate of requests. The rate is specified in requests per second (r/s). If a rate of less than one request per second is desired, it is specified in request per minute (r/m). For example, half-request per second is 30r/m.

##### NGINX_WORKER_CONNECTIONS
- Value type is _number_.
- Default value is `4096`.

Set the number of connections that nginx worker can handle.
