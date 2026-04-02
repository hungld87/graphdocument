---
description: "Liet ke co so thu tu cac tai lieu da duoc index"
name: "countDoc"
argument-hint: "Loc theo tu khoa ten file (tu chon)"
agent: "agent"
tools: [documentgraph/*]
---
Muc tieu: thong ke va liet ke danh sach tai lieu da duoc index.

Yeu cau thuc hien:
1. Goi `health()` de lay thong ke tong quan cua KB.
2. Goi `semantic_search(query="danh sach tai lieu da index", limit=20)` de lay context tai lieu da co trong index.
3. Neu can de chac chan danh sach file, doc parser manifest trong `.graph_rag/state/parser_manifest.json`.

Quy tac liet ke:
- Liet ke thanh danh sach co so thu tu: 1., 2., 3.
- Moi dong gom: ten file, trang thai (indexed/parsing-only/unknown), ghi chu ngan neu can.
- Neu nguoi dung truyen tu khoa loc, chi hien thi cac file khop.

Dinh dang tra loi:
- Dong dau: "Tong so tai lieu: X".
- Phan danh sach theo so thu tu.
- Dong cuoi: thong ke bo sung tu `health()` gom entity_count, text_unit_count, relation_count, points_count.
