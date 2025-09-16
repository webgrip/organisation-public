# Official Redis image with pinned tag
# Upstream: https://hub.docker.com/_/redis
# Version: Latest 8.2.x minor release on Alpine 3.22
FROM redis:8.2.1-alpine3.22

# Redis configuration for Firefly III
# Following upstream documentation for session and cache storage
COPY ops/docker/redis/redis.conf /usr/local/etc/redis/redis.conf

# Use custom configuration
CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]