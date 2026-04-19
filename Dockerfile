FROM node:20-slim AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY server.ts ./
COPY src ./src
COPY tsconfig.json vite.config.ts index.html metadata.json data.json ./

RUN npm run build
RUN npx tsc

# --- Runner Stage ---
FROM node:20-slim AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/data.json ./

RUN npm install --omit=dev


HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (res) => res.statusCode === 200 ? process.exit(0) : process.exit(1))"

EXPOSE 3000


USER node

CMD ["node", "dist/server.js"]