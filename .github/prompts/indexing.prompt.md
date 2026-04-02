---
description: "Quet file moi trong docs/raw roi parse va ingest vao Knowledge Graph"
name: "indexing"
argument-hint: "Mo ta ngan ve dot index (tu chon)"
agent: "agent"
tools: [documentgraph/*]
---
Muc tieu: quet va index tai lieu moi cap nhat trong workspace.

Yeu cau thuc hien theo dung thu tu:
1. Goi `parse_rawdata()` de quet va parse tat ca file hop le trong thu muc rawdata.
2. Goi `ingest()` de index parser files vao Neo4j va Qdrant.
3. Goi `health()` de kiem tra trang thai va thong ke sau index.

Rang buoc:
- Neu co file bi bo qua, phai noi ro ly do skip.
- Neu ingest bao "No parser file changes detected", thong bao ro la khong co thay doi moi.
- Neu co loi, neu ro buoc nao loi va thong diep loi goc.

Dinh dang tra loi:
- Ket luan 1 dong: "Index thanh cong" hoac "Index that bai".
- Cac muc co danh so 1, 2, 3 cho parse, ingest, health.
- Cuoi cung them "Tong ket" voi so file da parse, so file da index, va trang thai he thong.
