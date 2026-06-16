# ---- Étape build ----
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build          # Vite génère /app/dist

# ---- Étape runtime ----
FROM nginxinc/nginx-unprivileged:1.27-alpine AS runtime
# image qui tourne déjà en non-root (uid 101) et écoute sur 8080
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --retries=3 --start-period=5s \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/ || exit 1