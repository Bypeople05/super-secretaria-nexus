FROM node:20-slim AS frontend
WORKDIR /app/frontend
COPY dashboard/frontend/package*.json ./
RUN npm install
COPY dashboard/frontend/ ./
RUN npm run build

FROM python:3.11-slim
WORKDIR /app
COPY --from=frontend /app/frontend/dist ./dashboard/frontend/dist
COPY . .
RUN pip install uv
RUN uv sync
EXPOSE 8080
CMD ["uv", "run", "python", "dashboard/backend/app.py"]