FROM n8nio/n8n:latest

USER root

RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    ttf-liberation \
    udev \
    && rm -rf /var/cache/apk/*

RUN npm install -g puppeteer puppeteer-extra puppeteer-extra-plugin-stealth axios https-proxy-agent http-proxy-agent

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

USER node
