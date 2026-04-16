FROM node:22-slim AS frontend
WORKDIR /app/frontend
COPY dashboard/frontend/package*.json ./
RUN npm install
COPY dashboard/frontend/ ./
RUN npm run build

FROM node:22-slim
WORKDIR /app

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install claude (Anthropic) and openclaude (all other providers)
RUN npm install -g @anthropic-ai/claude-code @gitlawb/openclaude

# Install uv (manages Python 3.12)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

COPY --from=frontend /app/frontend/dist ./dashboard/frontend/dist
COPY . .

RUN uv sync
EXPOSE 8080
CMD ["uv", "run", "python", "dashboard/backend/app.py"]
