# Official Nginx image with pinned tag for reverse proxy
# Upstream: https://hub.docker.com/_/nginx
# Version: Latest 1.27.x minor release on Alpine
FROM nginx:1.27.3-alpine

# Copy reverse proxy configuration
COPY ops/docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ops/docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Create nginx user if not exists and set permissions
RUN mkdir -p /var/cache/nginx /var/log/nginx \
    && chown -R nginx:nginx /var/cache/nginx /var/log/nginx /etc/nginx

# Use non-root user
USER nginx

# Expose only the reverse proxy port
EXPOSE 8080