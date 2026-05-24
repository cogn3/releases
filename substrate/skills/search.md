# Semantic Search

CS supports advanced semantic search with LLM-powered query expansion.

## Basic Usage

```bash
# Hybrid mode (default) - combines vector + FTS
cs search "authentication flow"

# With intent for disambiguation
cs search "performance" --intent "database query optimization"

# Vector-only (similarity-based)
cs search "error handling" --mode vector

# Keyword-only (fastest, no LLM)
cs search "validateUser" --mode keyword
```

## Options

| Option | Description |
|--------|-------------|
| `-m, --mode` | `hybrid` (default), `vector`, or `keyword` |
| `--intent <text>` | Query intent for disambiguation |
| `--no-rerank` | Disable Cohere reranking |
| `--no-expand` | Disable LLM query expansion |
| `--debug` | Show debug info including query expansions |

## Search Modes

- **hybrid** (default): Combines vector similarity + FTS5 keyword matching with LLM query expansion
- **vector**: Pure embedding-based similarity search
- **keyword**: Traditional full-text search with BM25 ranking (fastest)

## Intent Support

When you provide `--intent`, the search:
- Includes intent in query expansion prompts for better context
- Prepends intent to reranking queries
- Forces deep semantic analysis (disables strong-signal bypass)

Example: `cs search "performance" --intent "database query optimization"` disambiguates from sports or web performance.

## Query Expansion

The search uses QMD-inspired expansion:
- `lex:` expansions - synonyms and related terms for BM25
- `vec:` expansions - semantically similar concepts for vector search
- `hyde:` expansions - hypothetical document embeddings

## Parent Context

Search results include contextual information:
- Import block from the file header
- Enclosing class signature (for methods)

This helps understand context without reading the entire file.
