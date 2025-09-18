#!/bin/sh
set -e

# Garante que a pasta de uploads exista
mkdir -p /app/public/uploads

# Ajusta permissões do volume (sempre root:root no primeiro start)
chown -R 1001:1001 /app/public/uploads || true

# Troca para o usuário strapi e roda o comando final
exec su-exec strapi "$@"
