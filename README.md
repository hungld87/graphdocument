# DocumentGraph - Quick Overview

DocumentGraph is a local-first toolkit that parses documents, indexes content into a Knowledge Graph and vector database, and enables evidence-based Q&A in Copilot Chat via MCP.

## Core Purpose

- Convert internal documents into structured, searchable knowledge.
- Support a practical workflow: parse -> ingest -> semantic search.
- Provide responses grounded in indexed document evidence.

## High-Level Architecture

- `docs/raw/`: primary input files from the user.
- `docs/text/`: additional text-based sources.
- `graph_rag/`: runtime, parsing, ingestion, and MCP tooling.
- Neo4j: stores graph entities and relationships.
- Qdrant: stores embeddings for semantic retrieval.

## Supported Parser Formats

- `.pdf`
- `.pptx`
- `.docx`
- `.doc`
- `.xlsx`
- `.xls`
- `.csv`
- `.json`
- `.xml`
- `.html`
- `.htm`
- `.epub`
- `.zip`
- `.md`
- `.markdown`
- `.txt`

## Current Limitation

- Image content is not processed yet because OCR is not integrated at this time.

## Privacy Note

- Document indexing and storage are performed entirely on the user's machine.
- With the default local setup, document data does not need to be uploaded to cloud services.
