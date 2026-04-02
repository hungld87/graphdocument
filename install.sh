#!/usr/bin/env sh
set -eu

NETWORK_NAME="documentgraph-net"
NEO4J_CONTAINER="documentgraph-neo4j"
QDRANT_CONTAINER="documentgraph-qdrant"
SEARXNG_CONTAINER="documentgraph-searxng"

NEO4J_IMAGE="neo4j:5.22"
QDRANT_IMAGE="qdrant/qdrant:v1.11.3"
SEARXNG_IMAGE="searxng/searxng:latest"

NEO4J_USER="${NEO4J_USER:-neo4j}"
NEO4J_PASSWORD="${NEO4J_PASSWORD:-neo4jpassword}"

echo "[1/6] Checking Docker..."
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed. Please install Docker Desktop first."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not running. Start Docker Desktop and retry."
  exit 1
fi

echo "[2/6] Ensuring network ${NETWORK_NAME}..."
docker network inspect "${NETWORK_NAME}" >/dev/null 2>&1 || docker network create "${NETWORK_NAME}" >/dev/null

echo "[3/6] Pulling images..."
docker pull "${NEO4J_IMAGE}" >/dev/null
docker pull "${QDRANT_IMAGE}" >/dev/null
docker pull "${SEARXNG_IMAGE}" >/dev/null

echo "[4/6] Starting Neo4j..."
if docker ps -a --format '{{.Names}}' | grep -qx "${NEO4J_CONTAINER}"; then
  docker start "${NEO4J_CONTAINER}" >/dev/null || true
else
  docker run -d \
    --name "${NEO4J_CONTAINER}" \
    --network "${NETWORK_NAME}" \
    -p 7474:7474 \
    -p 7687:7687 \
    -e "NEO4J_AUTH=${NEO4J_USER}/${NEO4J_PASSWORD}" \
    -v documentgraph_neo4j_data:/data \
    "${NEO4J_IMAGE}" >/dev/null
fi

echo "[5/6] Starting Qdrant..."
if docker ps -a --format '{{.Names}}' | grep -qx "${QDRANT_CONTAINER}"; then
  docker start "${QDRANT_CONTAINER}" >/dev/null || true
else
  docker run -d \
    --name "${QDRANT_CONTAINER}" \
    --network "${NETWORK_NAME}" \
    -p 6333:6333 \
    -p 6334:6334 \
    -v documentgraph_qdrant_data:/qdrant/storage \
    "${QDRANT_IMAGE}" >/dev/null
fi

echo "[6/6] Starting SearXNG..."
if docker ps -a --format '{{.Names}}' | grep -qx "${SEARXNG_CONTAINER}"; then
  docker start "${SEARXNG_CONTAINER}" >/dev/null || true
else
  docker run -d \
    --name "${SEARXNG_CONTAINER}" \
    --network "${NETWORK_NAME}" \
    -p 8080:8080 \
    "${SEARXNG_IMAGE}" >/dev/null
fi

echo "Done. Services are running:"
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' | grep -E 'documentgraph-(neo4j|qdrant|searxng)|NAMES' || true

echo "Tip: now run 'ollama pull llama3.2' and 'ollama pull nomic-embed-text' if not already installed."
