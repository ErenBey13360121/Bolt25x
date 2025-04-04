# 1. Aşama: bağımlılıkları yükle
FROM node:18-alpine AS deps

WORKDIR /app

COPY . .

RUN corepack enable && corepack prepare pnpm@9.4.0 --activate
RUN pnpm install --frozen-lockfile

# 2. Aşama: production build
FROM node:18-alpine AS builder

WORKDIR /app

ENV NODE_OPTIONS="--max-old-space-size=2048"

COPY --from=deps /app /app

RUN pnpm run build

# 3. Aşama: final çalıştırma aşaması
FROM node:18-alpine AS runner

WORKDIR /app

COPY --from=builder /app /app

EXPOSE 3000
ENV PORT=3000
CMD ["pnpm", "run", "preview"]
