# Firefly III application container using official upstream image
# Base: Official Firefly III image from Docker Hub
# Upstream: https://hub.docker.com/r/fireflyiii/core
# Version: Pinned to specific release for stability
FROM fireflyiii/core:version-6.3.2

# The official image comes with everything needed for Firefly III
# It includes PHP, nginx, and all dependencies pre-configured

# Optional: Add any organization-specific customizations
# COPY ops/docker/application/custom-config.php /var/www/html/config/custom.php

# The official image already:
# - Exposes port 8080
# - Runs as www-data user
# - Has proper health checks
# - Includes all necessary services

# Use the default CMD from the official image
