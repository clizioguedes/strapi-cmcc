# syntax=docker.io/docker/dockerfile:1

FROM node:22-alpine AS base

# Install dependencies only when needed
RUN apk add --no-cache python3 make g++ libc6-compat build-base gcc autoconf automake zlib-dev libpng-dev nasm bash vips-dev git
WORKDIR /app

# ---------------------------
# Install dependencies based on the preferred package manager
# ---------------------------
FROM base AS deps
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* .npmrc* ./
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i --frozen-lockfile; \
  else echo "Lockfile not found." && exit 1; \
  fi

# ---------------------------
# Rebuild the source code only when needed
# ---------------------------
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN \
  if [ -f yarn.lock ]; then yarn build; \
  elif [ -f package-lock.json ]; then npm run build; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm run build; \
  else echo "Lockfile not found." && exit 1; \
  fi

# ---------------------------
# Runner
# ---------------------------
FROM base AS runner
WORKDIR /app

RUN addgroup --system --gid 1001 strapi
RUN adduser --system --uid 1001 strapi

COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app ./

RUN mkdir -p /app/public/uploads \
    && chown -R strapi:strapi /app/public/uploads \
    && chmod -R 777 /app/public/uploads

USER strapi

EXPOSE 1337

ENV NODE_ENV=production
ENV PORT=1337

ENV HOST="0.0.0.0"

CMD ["npm", "run", "start"]
