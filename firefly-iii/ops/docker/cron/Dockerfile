# Firefly III cron/scheduler container using official upstream image
# Handles recurring tasks like scheduled transactions, email reports, etc.
# Base: Official Firefly III image from Docker Hub
# Upstream: https://hub.docker.com/r/fireflyiii/core
# Version: Pinned to specific release for stability
FROM fireflyiii/core:version-6.3.2

# The official image already has Firefly III set up
# We just need to add cron functionality for scheduled tasks

# Switch to root for cron setup
USER root

## Install cron package
# Upstream base image (fireflyiii/core) is Debian/Ubuntu based (uses apt-get), not Alpine.
# Use non-interactive apt installation and clean up to keep image small.
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends cron; \
    rm -rf /var/lib/apt/lists/*;

## Create dedicated unprivileged cron user (if not already present)
# (Debian style adduser/addgroup syntax)
RUN set -eux; \
    if ! getent group cron >/dev/null; then groupadd --system cron; fi; \
    if ! id -u cron >/dev/null 2>&1; then useradd --system --no-create-home --gid cron --shell /usr/sbin/nologin cron; fi

# Copy cron configuration and entrypoint
COPY ops/docker/cron/crontab /var/spool/cron/crontabs/cron
COPY ops/docker/cron/entrypoint.sh /entrypoint.sh

# Set proper permissions
RUN set -eux; \
    chmod +x /entrypoint.sh; \
    chown -R cron:cron /var/www/html; \
    chown cron:cron /var/spool/cron/crontabs/cron; \
    chmod 0600 /var/spool/cron/crontabs/cron

# Create necessary directories
RUN set -eux; mkdir -p /var/log/cron; chown cron:cron /var/log/cron

## Keep running as root in the container so startup tasks can set permissions on mounted volumes
# The cron daemon will run in foreground from the entrypoint; jobs can still run as non-root users
# if desired by writing user-specific crontabs. Avoid switching to an unprivileged user here because
# that prevents chmod/chown on volume-mounted files during container startup.
# USER cron

# Health check to ensure cron is running
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    CMD pgrep cron || exit 1

# Start cron service
CMD ["/entrypoint.sh"]
