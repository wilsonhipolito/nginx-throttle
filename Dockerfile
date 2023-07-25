#FROM nginx:1.25.1-alpine
#FROM axizdkr/tengine:alpine-3.17
FROM alpine:3.17

# Add all useful utilitaries for maintenance
RUN apk --update add bash vim curl gettext wget

run apk add parallel

# Create directory to have our custom scripts and template
RUN mkdir -p /app
WORKDIR /app

# Add required modules, compiling tengine from source
RUN wget https://tengine.taobao.org/download/tengine-3.0.0.tar.gz
RUN tar -xf /app/tengine-3.0.0.tar.gz -C /app
WORKDIR /app/tengine-3.0.0
RUN apk update
RUN apk upgrade
RUN apk add --update --no-cache build-base gcc musl-dev pcre pcre-dev libc6-compat libressl-dev zlib-dev

RUN ./configure \
	--add-module=./modules/ngx_http_proxy_connect_module

RUN make
RUN make install

WORKDIR /app

# Copy our custom templates, overwritten when the container start using environment variables
COPY nginx.conf.template /app/nginx.conf.template
COPY sysctl.conf.template /app/sysctl.conf.template
COPY 10-throttle.conf.template /app/10-throttle.conf.template

# Copy the custom script to run when the container start
COPY docker_entrypoint.sh /app/docker_entrypoint.sh

ENTRYPOINT ["/app/docker_entrypoint.sh"]
