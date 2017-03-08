# Nginx Throttle

A simple Docker container with Nginx reverse proxy for Apps that are behind an **AWS ELB** and need to throttle HTTP requests.

Reference: http://nginx.org/en/docs/http/ngx_http_limit_req_module.html
## Usage

### Inside a POD file

```
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  hostNetwork: true
  containers:
  - name: myapp
    image: myapp-image
    env:
      - name: MY_APP_VAR
        value: "my app value"
    ports:
    - containerPort: 3000
      protocol: TCP
    livenessProbe:
      failureThreshold: 3
      httpGet:
        path: /health
        port: 3000
        scheme: HTTP
      initialDelaySeconds: 30
      periodSeconds: 10
      successThreshold: 1
      timeoutSeconds: 5
  - name: nginx
    image: vivareal/nginx-throttle:latest
    env:
      - name: NGINX_BACKEND_ADDR
        value: "localhost"
      - name: NGINX_BACKEND_PORT
        value: "3000"
      - name: NGINX_THROTTLE_RATE_LIMIT
        value: "200r/s"
      - name: NGINX_SET_NODELAY
        value: "true"
    ports:
    - containerPort: 80
      protocol: TCP
    livenessProbe:
      failureThreshold: 3
      httpGet:
        path: /health
        port: 80
        scheme: HTTP
      initialDelaySeconds: 30
      periodSeconds: 10
      successThreshold: 1
      timeoutSeconds: 5
```

### Docker compose

```
version: '2'

services:
   myapp:
     image: myapp-image
     restart: always
     ports:
       - "3000:3000"
     environment:
       MY_APP_VAR: "my app value"

   nginx:
     depends_on:
       - myapp
     image: vivareal/nginx-throttle:latest
     ports:
       - "80:80"
     environment:
       NGINX_BACKEND_ADDR: myapp
       NGINX_BACKEND_PORT: 3000
       NGINX_THROTTLE_RATE_LIMIT: "200r/s"
       NGINX_SET_NODELAY: true
```

### Just Docker

Start your app:
```
docker run -d --name=myapp -p 3000:3000 myapp-image
```
Now start the `nginx-throttle` with a link to your app:
```
docker run -d --name=nginx --link myapp -p 80:80  -e NGINX_THROTTLE_RATE_LIMIT="200r/m" -e NGINX_BACKEND_ADDR=myapp -e NGINX_BACKEND_PORT=3000 -e NGINX_SET_NODELAY=true vivareal/nginx-throttle:latest
```

## Configuration

All settings are passed by environment variables:

|Variable|Default value|Required|
|--------|-------------|--------|
|NGINX_BACKEND_ADDR| - | **YES** |
|NGINX_BACKEND_PORT| - | **YES** |
|NGINX_LISTEN_PORT| `80` | No |
|NGINX_SET_NODELAY| `false` | No |
|NGINX_THROTTLE_BURST|`10`| No|
|NGINX_THROTTLE_MEM_LIMIT| `10m`| No|
|NGINX_THROTTLE_RATE_LIMIT| `100r/s` | No |

### Details

##### NGINX_BACKEND_ADDR
- This is a required setting.
- Value type is _string_.
- There is no default value for this setting.

Set the address of your app for Nginx proxy pass. This can be the DNS record, IP address, the container name or `localhost`.

##### NGINX_BACKEND_PORT
- This is a required setting.
- Value type is _number_.
- There is no default value for this setting.

Set the port where your app is listening Eg.: `8080`.

##### NGINX_LISTEN_PORT
- Value type is _number_.
- Default value is `80`.

Set the port where Nginx should listen on.

##### NGINX_SET_NODELAY
- Value type is _boolean_.
- Default value is `false`.

Set to `true` if you want Nginx to drop requests instead of delaying excessive requests.

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
