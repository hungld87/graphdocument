# QUICKSTART — DocumentGraph cho User Mới

Hướng dẫn từ zero đến chạy MCP kết nối Copilot với DocumentGraph.
**Tất cả tài liệu của User được indexing và lưu trữ trên chính máy của User**

## Bước 1: Clone hoặc tạo workspace mới

```bash
# Option A: Nếu bạn đã có repo
cd /your/workspace
git clone https://github.com/hungld87/graphdocument.git
cd documentgraph

# Option B: Nếu tạo workspace mới
mkdir my-documentgraph-workspace
cd my-documentgraph-workspace
git clone https://github.com/hungld87/graphdocument.git .
```

## Bước 2: Chuẩn bị cấu trúc thư mục

```bash
# Tạo thư mục input
mkdir -p docs/raw

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

```bash
Install Ollama trên local: https://ollama.com/
```

Pull models **trên host machine**:
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

## Cấu hình máy tối thiểu:

Để chạy ổn định DocumentGraph + Ollama (`llama3.2` + `nomic-embed-text`) trên máy local:

- CPU: tối thiểu 4 cores (Apple Silicon M1 hoặc Intel i5 đời mới trở lên)
- RAM: tối thiểu 16GB (8GB vẫn có thể chạy nhưng sẽ chậm khi ingest/query)
- Disk trống: tối thiểu 20GB (chứa Docker images, Neo4j/Qdrant data, Ollama models)
- Docker Desktop: đang chạy ổn định, nên cấp ít nhất 6GB RAM cho Docker

Mốc đề xuất để trải nghiệm tốt hơn:
- RAM 24GB+ nếu tài liệu nhiều hoặc ingest file lớn
- Apple Silicon (M1/M2/M3) cho tốc độ xử lý tốt hơn CPU-only truyền thống

### Lưu ý về image

- Hiện tại hệ thống **chưa đọc được nội dung từ ảnh** (PNG/JPG/JPEG, ảnh scan trong PDF) do chưa tích hợp OCR.
- Nếu tài liệu của bạn là ảnh scan, cần OCR trước rồi mới ingest để truy vấn chính xác.

## Bước 6: Cấu hình MCP trong VS Code

1. Mở VS Code tại thư mục root workspace
2. Nếu chưa có, cài extension **GitHub Copilot Chat**
3. Tạo folder .vscode tại workspace, tạo file mcp.json
4. Paste nội dung sau vào `mcp.json`:

```json
{
  "servers": {
    "documentgraph": {
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
        "RAWDATA=/workspace/docs/raw",
        "-e",
        "PARSER=/workspace/.graph_rag/parsed",
        "-e",
        "NEO4J_URI=bolt://host.docker.internal:7687",
        "-e",
        "QDRANT_URL=http://host.docker.internal:6333",
        "hungld7/documentgraph:latest"
      ]
    }
  }
}
```
Note
```json
RAWDATA: docs/raw - là thư mục chứa file gốc
PARSER: .graph_rag/parsed - là các file đã được parser thành txt
```

5. Lưu file

## Bước 7: Kiểm tra MCP server

1. Mở Copilot Chat (`Cmd+K`)
2. Gõ /docHelp

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
2. Trả lời có dẫn chứ từ tài liệu (file, text_unit_id, trích dẫn)

Nếu cần reset DB: `docker restart documentgraph-neo4j documentgraph-qdrant`

## Troubleshooting

| Vấn đề | Giải pháp |
|---|---|
| MCP server không kết nối | Check docker ps, neo4j/qdrant có running không |
| Ollama model not found | Chạy `ollama ls` kiểm tra, pull lại nếu cần |
| File ảnh không tìm được nội dung | Hiện chưa có OCR, cần chuyển ảnh/scan sang text trước khi ingest |
| Timeout khi ingest file lớn | Tăng `TOP_K` trong .env hoặc split file |
| DocumentGraph không tìm được info | Kiểm tra tài liệu đã index chưa bằng tool `health()` |
