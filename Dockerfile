# 1. Katman: Bağımlılıkları kur
FROM node:18-slim AS deps
WORKDIR /app

# Gerekli sistem paketleri (git dahil)
RUN apt-get update && apt-get install -y git

# pnpm yükle
RUN corepack enable && corepack prepare pnpm@9.4.0 --activate

# Proje dosyalarını kopyala
COPY . .

# Bağımlılıkları yükle
RUN pnpm install --frozen-lockfile


# 2. Katman: Build işlemi
FROM node:18-slim AS builder
WORKDIR /app

# Gerekli sistem paketleri (git dahil)
RUN apt-get update && apt-get install -y git

# pnpm yükle
RUN corepack enable && corepack prepare pnpm@9.4.0 --activate

# Bağımlılıkları ve kodu kopyala
COPY --from=deps /app /app

# Build işlemi
RUN pnpm run build


# 3. Katman: Sadece çalıştırma için minimal katman
FROM node:18-slim AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# pnpm yükle
RUN corepack enable && corepack prepare pnpm@9.4.0 --activate

# Build edilmiş dosyaları kopyala
COPY --from=builder /app /app

# Port aç
EXPOSE 3000

# Railway'in çalıştıracağı komut
CMD ["pnpm", "preview"]
