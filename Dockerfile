# ==============================
# 1) Build Stage
# ==============================
FROM node:22-alpine AS builder

# Instala dependências básicas (sharp precisa de python e build-base)
RUN apk add --no-cache python3 make g++ libc6-compat build-base gcc autoconf automake zlib-dev libpng-dev nasm bash vips-dev git

WORKDIR /app

# Copia package.json e package-lock.json
COPY package*.json ./

# Instala dependências
RUN npm ci

# Copia todo o projeto
COPY . .

# Build da aplicação Strapi
RUN npm run build

# ==============================
# 2) Production Stage
# ==============================
FROM node:22-alpine AS runner

WORKDIR /app

# Instala apenas dependências necessárias para runtime
COPY package*.json ./
RUN npm ci --omit=dev

# Copia build e código do builder
COPY --from=builder /app/. /app/

# Porta padrão do Strapi
EXPOSE 1337

# Configura o host para rodar dentro de container
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=1337

CMD ["npm", "run", "start"]
