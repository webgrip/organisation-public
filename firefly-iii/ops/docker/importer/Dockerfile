# Firefly III Data Importer container using official upstream image
# Base: Official Firefly III Data Importer image from Docker Hub
# Upstream: https://hub.docker.com/r/fireflyiii/data-importer
# Version: Pinned to specific release for stability
FROM fireflyiii/data-importer:version-1.7.10

# The official image comes with everything needed for the Data Importer
# It includes PHP, nginx, and all dependencies pre-configured

# Optional: Add any organization-specific customizations
# COPY ops/docker/importer/custom-config.php /var/www/html/config/custom.php

# The official image already:
# - Exposes port 8080
# - Runs as www-data user
# - Has proper health checks
# - Includes all necessary services

# Use the default CMD from the official image
