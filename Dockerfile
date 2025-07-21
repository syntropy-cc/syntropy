############# ETAPA DE BUILD #############
FROM node:20-alpine AS builder
RUN corepack enable
WORKDIR /app

COPY package.json pnpm-lock.yaml* ./
COPY .env.production ./
RUN pnpm install --frozen-lockfile --prod=false

COPY . .

RUN pnpm run build

############### ETAPA DE RUNTIME ############
FROM node:20-alpine
RUN corepack enable
WORKDIR /app
ENV NODE_ENV=production PORT=3000
COPY --from=builder /app ./
EXPOSE 3000
CMD ["pnpm","start"]
