# Official MariaDB image with pinned tag
# Upstream: https://hub.docker.com/_/mariadb
# Version: Latest 12.0.x minor release on Ubuntu Noble
FROM mariadb:12.0.2-noble

# MariaDB configuration for Firefly III
# Following upstream documentation: https://docs.firefly-iii.org/how-to/docker/
ENV MYSQL_INITDB_SKIP_TZINFO=1
ENV MARIADB_AUTO_UPGRADE=1

# Firefly III optimized configuration
COPY ops/docker/mariadb/my.cnf /etc/mysql/conf.d/firefly.cnf
