---
description: "Hien thi huong dan nhanh cho user moi de cai dat va su dung DocumentGraph"
name: "docHelp"
argument-hint: "Muc can tro giup (tu chon): setup, mcp, indexing, troubleshoot"
agent: "agent"
tools: [documentgraph/*]
---
Muc tieu: hien thi huong dan tung buoc de user moi co the chay DocumentGraph va bat dau hoi dap trong Copilot.

Yeu cau thuc hien:
1. Goi `health()` de kiem tra nhanh tinh san sang cua Neo4j va Qdrant.
2. Dua huong dan theo 4 nhom ngan gon, de thuc hien ngay:
   - Setup nhanh: docs/raw, docs/text, graph_rag/.env, install.sh.
   - Cau hinh MCP: file .vscode/mcp.json va cach verify ket noi.
   - Index du lieu: parse_rawdata -> ingest -> health.
   - Hoi dap: cach dat cau hoi va ky vong output co dan chung.
3. Neu `health()` cho thay he thong chua san sang, them muc Troubleshooting voi goi y cu the (docker ps, restart service, kiem tra model embedding).

Rang buoc:
- Tra loi bang tieng Viet, ngan gon, than thien cho user moi.
- Dung danh sach co so thu tu 1, 2, 3 de user lam theo.
- Neu user truyen argument (setup/mcp/indexing/troubleshoot), uu tien mo rong phan do truoc.

Dinh dang tra loi:
- Dong dau: "DocumentGraph Help".
- 3 muc chinh: "Chuan bi", "Van hanh", "Kiem tra".
- Dong cuoi: 2 goi y hanh dong tiep theo de user copy chay ngay.
