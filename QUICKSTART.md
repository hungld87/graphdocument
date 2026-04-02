# QUICKSTART — DocumentGraph cho User Mới

Hướng dẫn từ zero đến chạy MCP kết nối Copilot với DocumentGraph.

## Bước 1: Clone hoặc tạo workspace mới

```bash
# Option A: Nếu bạn đã có repo
cd /your/workspace
git clone https://github.com/hungld7/documentgraph.git
cd documentgraph

# Option B: Nếu tạo workspace mới
mkdir my-documentgraph-workspace
cd my-documentgraph-workspace
git clone https://github.com/hungld7/documentgraph.git .
```

## Bước 2: Chuẩn bị cấu trúc thư mục

```bash
# Tạo thư mục input
mkdir -p docs/raw docs/text

# Copy template env
cp graph_rag/.env.example graph_rag/.env
```

## Bước 3: Điền thông tin vào .env (macOS)

Mở file `graph_rag/.env` và đảm bảo:

```dotenv
# LLM: Mặc định Ollama (local, không tốn chi phí)
LLM_PROVIDER=ollama
OLLAMA_HOST=http://host.docker.internal:11434
OLLAMA_CHAT_MODEL=llama3.2

# Embedding: Ollama
EMBEDDING_PROVIDER=ollama
EMBEDDING_MODEL_NAME=nomic-embed-text

# Database (để nguyên default)
NEO4J_URI=bolt://host.docker.internal:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=neo4jpassword
QDRANT_URL=http://host.docker.internal:6333
QDRANT_COLLECTION=graph_rag_chunks
TOP_K=5
```

## Bước 4: Chạy script cài đặt

```bash
cd graph_rag
chmod +x install.sh
./install.sh
```

Script sẽ tự chạy 3 service:
1. **Neo4j** (localhost:7687) — lưu knowledge graph
2. **Qdrant** (localhost:6333) — lưu vector embeddings
3. **SearXNG** (localhost:8080) — web search engine

Chờ khoảng 1-2 phút cho các container khởi động.

## Bước 5: Chuẩn bị LLM (chọn 1 trong 2)

### Option A: Ollama (local, miễn phí, mặc định)

Pull models **trên host machine** (không phải Docker):

```bash
ollama pull llama3.2
ollama pull nomic-embed-text
```

### Option B: Azure OpenAI (cloud, mất phí)

Nếu không muốn dùng Ollama, chỉnh lại `graph_rag/.env`:

```dotenv
LLM_PROVIDER=azure
AZURE_API_KEY=your_key_here
AZURE_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_DEPLOYMENT_ID=your_deployment
AZURE_API_VERSION=2024-02-15-preview

EMBEDDING_PROVIDER=azure
AZURE_EMBEDDING_DEPLOYMENT_ID=your_embedding_deployment
```

Sau đó rebuild image: `cd graph_rag && docker build -t hungld7/documentgraph:latest .`

**Tại sao pull Ollama ở ngoài Docker?**
- Ollama là app độc lập trên macOS, không nằm trong container
- DocumentGraph container kết nối tới Ollama trên host qua `http://host.docker.internal:11434`
- Models lưu ở `~/.ollama/models/` trên macOS, không cần copy vào Docker

## Bước 6: Cấu hình MCP trong VS Code

1. Mở VS Code tại thư mục root workspace
2. Nếu chưa có, cài extension **GitHub Copilot Chat**
3. Mở Command Palette (`Cmd+Shift+P`) và chạy: `Copilot: Edit Copilot Settings as JSON`
4. Paste nội dung của file `graph_rag/mcp.json` vào phần `mcpServers`:

```json
{
  "servers": {
    "graph-rag-kg": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-v",
        "${workspaceFolder}:/workspace",
        "-v",
        "${workspaceFolder}/graph_rag/.env:/app/.env:ro",
        "-e",
        "MCP_TRANSPORT=stdio",
        "-e",
        "MCP_WORKSPACE_ROOT=/workspace",
        "-e",
        "NEO4J_URI=bolt://host.docker.internal:7687",
        "-e",
        "QDRANT_URL=http://host.docker.internal:6333",
        "hungld7/documentgraph:latest"
      ]
    },
    "searxng": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-e",
        "SEARXNG_URL=http://host.docker.internal:8080",
        "mcp/searxng:latest"
      ]
    }
  }
}
```

5. Lưu file
6. Reload VS Code (`Cmd+Shift+P` → "Developer: Reload Window")

## Bước 7: Kiểm tra MCP server

1. Mở Copilot Chat (`Cmd+K`)
2. Gõ `@` để thấy danh sách MCP servers
3. Nên thấy 2 server:
   - `graph-rag-kg`
   - `searxng`

## Bước 8: Thêm tài liệu vào workspace

1. Đặt file `.md`, `.txt`, hay `.xlsx` vào thư mục `docs/raw/` hoặc `docs/text/`
2. Trong Copilot, gọi tool `ingest()` để index tất cả file vào KB
3. Kiểm tra status: tool `health()` sẽ cho biết có bao nhiêu entities, text units, relations đã được index

## Bước 9: Bắt đầu hỏi đáp

Ví dụ trong Copilot Chat:

```
Hỏi: Hệ thống yêu cầu SLA là gì?
```

Agent sẽ:
1. Gọi `semantic_search()` để tìm trong DocumentGraph
2. Nếu không đủ, gọi SearXNG để tìm web
3. Trả lời có dẫn chứ từ tài liệu (file, text_unit_id, trích dẫn)

## Lưu ý quan trọng

- **Neo4j web UI**: http://localhost:7474 (user: neo4j, password: neo4jpassword)
- **Qdrant web UI**: http://localhost:6333/dashboard
- **SearXNG web UI**: http://localhost:8080

Nếu cần reset DB: `docker restart documentgraph-neo4j documentgraph-qdrant`

## Troubleshooting

| Vấn đề | Giải pháp |
|---|---|
| MCP server không kết nối | Check docker ps, neo4j/qdrant có running không |
| Ollama model not found | Chạy `ollama ls` kiểm tra, pull lại nếu cần |
| Timeout khi ingest file lớn | Tăng `TOP_K` trong .env hoặc split file |
| DocumentGraph không tìm được info | Kiểm tra tài liệu đã index chưa bằng tool `health()` |
