FROM node:22-slim AS frontend
WORKDIR /app/frontend
COPY dashboard/frontend/package*.json ./
RUN npm install
COPY dashboard/frontend/ ./
RUN npm run build

FROM node:22-slim
WORKDIR /app

# System deps (python3 + build tools required for node-pty native addon)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    nginx \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Install claude (Anthropic) and openclaude (other providers)
RUN npm install -g @anthropic-ai/claude-code @gitlawb/openclaude

# Install uv (manages Python)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Install terminal-server deps
COPY dashboard/terminal-server/package*.json ./dashboard/terminal-server/
RUN cd dashboard/terminal-server && npm install

COPY --from=frontend /app/frontend/dist ./dashboard/frontend/dist
COPY . .

# Install Python deps
RUN uv sync

# nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
