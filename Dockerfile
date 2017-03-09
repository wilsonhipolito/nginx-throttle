FROM nginx:1.11.10-alpine
RUN  apk --update add bash
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY 10-throttle.conf.template /etc/nginx/conf.d/10-throttle.conf.template

COPY docker_entrypoint.sh /docker_entrypoint.sh
ENTRYPOINT ["/docker_entrypoint.sh"]
