# 1. Aşama: pnpm ve bağımlılıkların kurulması
FROM node:18-alpine AS deps

# pnpm yüklü değil, elle kuracağız
RUN corepack enable && corepack prepare pnpm@9.4.0 --activate

WORKDIR /app

# package.json ve lock dosyasını kopyala
COPY package.json pnpm-lock.yaml ./

# node_modules kurulumu
RUN pnpm install --frozen-lockfile

# 2. Aşama: Projenin build edilmesi
FROM node:18-alpine AS builder

# Aynı şekilde pnpm tekrar yüklenmeli
RUN corepack enable && corepack prepare pnpm@9.4.0 --activate

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Remix + Vite ile build al
RUN pnpm run build

# 3. Aşama: Sadece statik dosyaların olduğu çalışma katmanı
FROM node:18-alpine AS runner

RUN corepack enable && corepack prepare pnpm@9.4.0 --activate

WORKDIR /app

# Prod node_modules gerekiyorsa buradan alınabilir
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/build ./build
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

CMD ["pnpm", "preview"]
