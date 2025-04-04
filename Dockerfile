# 1. Katman: Bağımlılıkları kur
FROM node:18-slim AS deps
WORKDIR /app

# pnpm yükle
RUN corepack enable && corepack prepare pnpm@9.4.0 --activate

# Proje dosyalarını kopyala
COPY . .

# Bağımlılıkları yükle
RUN pnpm install --frozen-lockfile


# 2. Katman: Build işlemi
FROM node:18-slim AS builder
WORKDIR /app

RUN corepack enable && corepack prepare pnpm@9.4.0 --activate

# Bağımlılıkları al
COPY --from=deps /app /app

# Build al
RUN pnpm run build


# 3. Katman: Sadece çalıştırma için minimal katman
FROM node:18-slim AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# pnpm tekrar aktif et
RUN corepack enable && corepack prepare pnpm@9.4.0 --activate

# Build'lı projeyi kopyala
COPY --from=builder /app /app

# Port aç
EXPOSE 3000

# Railway burayı çalıştırır
CMD ["pnpm", "preview"]
