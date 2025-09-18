#!/bin/sh
set -e

mkdir -p /app/public/uploads
chown -R 1001:1001 /app/public/uploads || true

exec su strapi -s /bin/sh -c "$*"
