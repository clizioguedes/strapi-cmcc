#!/bin/sh
set -e

# Garante que a pasta de uploads existe
mkdir -p /app/public/uploads

# Corrige permissões do volume persistente (source path: /data/strapi-uploads)
chown -R strapi:strapi /app/public/uploads || true

# Executa o comando passado (npm run start)
exec "$@"