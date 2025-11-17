#!/bin/sh
set -e

# Set defaults if not provided
TINYPROXY_USER=${TINYPROXY_USER:-admin}
TINYPROXY_PASSWORD=${TINYPROXY_PASSWORD:-changeme}
TINYPROXY_PORT=${TINYPROXY_PORT:-8888}
TINYPROXY_TIMEOUT=${TINYPROXY_TIMEOUT:-600}

# Generate tinyproxy.conf
cat > /etc/tinyproxy/tinyproxy.conf <<EOF
Port ${TINYPROXY_PORT}
Listen 0.0.0.0
Timeout ${TINYPROXY_TIMEOUT}
Allow 127.0.0.1
Allow 172.18.0.0/16
BasicAuth ${TINYPROXY_USER} ${TINYPROXY_PASSWORD}
EOF

echo "TinyProxy configuration generated with user: ${TINYPROXY_USER}"

# Start tinyproxy in foreground
exec /usr/bin/tinyproxy -d
