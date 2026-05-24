# Cogentry Substrate

> **A Hybrid Graph Intelligence System unifying GitNexus's Surgical Precision with Graphify's Contextual Intuition**

Cogentry Substrate (`cs`) is a **Living Context Engine** that answers questions like:

> *"Which design document (PDF) justifies this specific function call (Code), and what is the blast radius (Git) if I change it?"*

## Features

- **Multi-Language Support** — TypeScript, JavaScript, Python, Java, Go, Rust, C#, Ruby, PHP, Kotlin, Swift, C/C++
- **Tree-sitter AST Parsing** — Accurate symbol extraction
- **Framework Detection** — FastAPI, Django, Flask, NestJS, Spring Boot, and more
- **Architectural Analysis** — 5-layer classification with boundary violation detection
- **Data Flow Tracing** — Track data through functions, storage, and external services
- **Leiden Community Detection** — Automatic code clustering
- **God Node Detection** — Find high-centrality navigation anchors
- **Execution Flow Tracing** — Understand how code flows through the system
- **Rationale Extraction** — Link NOTE/WHY/HACK comments to symbols
- **Advanced Semantic Search** — LLM query expansion, intent-aware disambiguation, HyDE
- **Business Domain Analysis** — Extract Domain -> Flow -> Step hierarchy from code
- **Cross-Language Specification Extraction** — LASF format for types, schemas, APIs
- **Analysis Reports** — Architecture, complexity, ownership, API, dependencies, debt
- **Business Context Integration** — Domain mapping, critical paths, risk analysis
- **MCP Server** — Integrate with AI agents via Model Context Protocol
- **GRAPH_REPORT.md** — Auto-generated codebase documentation

---

## Documentation

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | Installation, quick start, basic usage |
| [skills/SKILL.md](skills/SKILL.md) | Agent skill definition, command reference, workflows |
| [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) | Architecture, schemas, implementation details |

---

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [CLI Commands](#cli-commands)
- [Configuration](#configuration)
- [MCP Integration](#mcp-integration)
- [Development](#development)

---

## Installation

### Quick Install (Recommended)

One-liner to install the pre-built binary:

```bash
curl -fsSL https://github.com/cogn3/releases/raw/main/substrate/install.sh | sh
```

This will:
- Download the appropriate binary for your platform (`darwin-arm64`, `linux-x64`, etc.)
- Install `cs` to `/usr/local/bin`
- If OpenCode is detected, install the skill to `~/.config/opencode/skills/cogentry-substrate/`

### Requirements (for building from source)

| Requirement | Version | Purpose |
|-------------|---------|---------|
| Node.js | 20+ | Runtime |
| npm | 10+ | Package manager |
| Git | 2.30+ | Change detection |

### Install from source

```bash
git clone git@github.com:cogn3/substrate.git
cd substrate
npm install
npm run build
npm link  # makes 'cs' available globally
```

### Usage after install

```bash
# Run directly
./dist/cli/index.js analyze .

# Or if you ran npm link
cs analyze .
```

---

## Quick Start

```bash
# Index your repository
cs analyze .

# Query the knowledge graph
cs query "authentication"

# Get 360-degree view of a symbol
cs context validateUser

# Analyze blast radius before making changes
cs impact validateUser --direction upstream

# Find shortest path between symbols
cs path loginHandler createSession

# See high-centrality symbols
cs god-nodes

# Detect changes and affected nodes
cs detect-changes --staged

# Extract cross-language specifications
cs specs --pretty
```

---

## CLI Commands

For a **complete command reference** with all options, see [skills/SKILL.md](skills/SKILL.md) and [skills/commands.md](skills/commands.md).

### Essential Commands

```bash
cs analyze .                           # Index the codebase
cs context <symbol>                    # 360-degree view of a symbol
cs impact <symbol> --direction upstream # What breaks if I change this?
cs search "query"                      # Semantic search
cs detect-changes                      # Map git changes to graph
cs report                              # List available reports
cs specs                               # Extract cross-language specifications
```

### Command Categories

| Category | Commands |
|----------|----------|
| **Analysis** | `analyze`, `list-repos`, `benchmark` |
| **Query** | `query`, `search`, `context`, `impact`, `path`, `explain`, `cypher` |
| **Semantic** | `routes`, `architecture`, `dataflow`, `communities`, `processes`, `god-nodes` |
| **Domain** | `domain analyze`, `domain list`, `domain show`, `domain flow`, `domain export` |
| **Specs** | `specs` |
| **Reports** | `report`, `business` |
| **Git** | `detect-changes`, `hook` |
| **Maintenance** | `status`, `clean`, `mcp`, `serve`, `setup` |
| **Export** | `export`, `wiki` |

---

## Configuration

### .csignore

Create a `.csignore` file to exclude paths from indexing:

```gitignore
# Ignore dependencies
node_modules/
vendor/

# Ignore build output
dist/
build/

# Ignore test fixtures
test/fixtures/
```

### Environment Variables

#### Core Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `CS_DATA_DIR` | `~/.cs` | Global config and registry |
| `CS_VERBOSE` | `false` | Enable verbose output |
| `CS_WORKER_TIMEOUT` | `30000` | Worker timeout (ms) |
| `CS_LEIDEN_TIMEOUT` | `60000` | Leiden clustering timeout (ms) |

#### Optional: Semantic Search (AWS Bedrock)

The `--skip-embeddings` flag disables semantic embedding generation. By default, embeddings are generated using AWS Bedrock.

Create a `.env` file in the project root with your AWS credentials:

```bash
# .env
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=ap-northeast-1
```

| Variable | Description |
|----------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key for Bedrock |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key for Bedrock |
| `AWS_REGION` | AWS region (default: `ap-northeast-1`) |

**Embedding Model:** `cohere.embed-v4:0` (1536 dimensions)
**Reranker Model:** `cohere.rerank-v3-5:0`

Semantic search data is stored in `.cs/semantic.sqlite` alongside the main graph.

**Example:**
```bash
# Generate embeddings (default behavior)
cs analyze .

# Skip embeddings for faster indexing
cs analyze . --skip-embeddings

# Search with hybrid mode (vector + FTS)
cs search "authentication flow"

# Search with reranking for better relevance
cs search "error handling" --rerank
```

#### Optional: Multimodal Extraction

The `--multimodal` flag enables extraction from PDFs, images, and videos using LLMs. This is **optional** and requires an API key for one of the supported providers:

| Variable | Description |
|----------|-------------|
| `GEMINI_API_KEY` | Google Gemini API key |
| `ANTHROPIC_API_KEY` | Anthropic Claude API key |
| `OPENAI_API_KEY` | OpenAI API key |
| `OLLAMA_BASE_URL` | Local Ollama server URL |
| `LITELLM_API_BASE` | LiteLLM proxy URL |
| `LITELLM_API_KEY` | LiteLLM API key (if proxy requires auth) |
| `CS_USE_BEDROCK` | Set to `1` to enable AWS Bedrock |
| `AWS_BEDROCK_MODEL` | Bedrock model ID |

**Example with Gemini:**
```bash
GEMINI_API_KEY=xxx cs analyze . --multimodal
```

**Example with LiteLLM proxy:**
```bash
# Start LiteLLM proxy
litellm --model gpt-4o --model claude-sonnet-4-20250514

# Use with cs
LITELLM_API_BASE=http://localhost:4000 cs analyze . --multimodal
```

---

## MCP Integration

Cogentry Substrate provides an MCP server for integration with AI agents.

### Start MCP Server

```bash
cs mcp
```

### Available Tools

| Tool | Description |
|------|-------------|
| `list_repos` | List indexed repositories |
| `query` | Search the knowledge graph |
| `context` | Get 360-degree view of a symbol |
| `impact` | Analyze blast radius |
| `path` | Find shortest path |
| `god_nodes` | List high-centrality symbols |
| `explain` | Explain symbol with rationale |
| `detect_changes` | Analyze git changes |
| `semantic_search` | Advanced semantic search with intent support |
| `domain_analyze` | Extract business domains |
| `domain_list` | List discovered domains |

For the complete tool inventory, see [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md#61-tool-inventory).

### Available Resources

| Resource | Description |
|----------|-------------|
| `cs://repos` | List all indexed repositories |
| `cs://repo/{name}/context` | Repository overview and stats |
| `cs://repo/{name}/clusters` | Code communities |
| `cs://repo/{name}/god_nodes` | High-centrality symbols |
| `cs://repo/{name}/processes` | Execution flows |
| `cs://repo/{name}/report` | GRAPH_REPORT.md content |
| `cs://repo/{name}/schema` | Graph schema definition |

### Editor Configuration

**Claude Code:**
```bash
# After npm link, add to Claude Code
claude mcp add cs -- cs mcp
```

**Cursor:**
```json
// ~/.cursor/mcp.json
{
  "mcpServers": {
    "cs": {
      "command": "cs",
      "args": ["mcp"]
    }
  }
}
```

**OpenCode:**
```json
// ~/.config/opencode/config.json
{
  "mcp": {
    "cs": {
      "type": "local",
      "command": ["cs", "mcp"]
    }
  }
}
```

### OpenCode Skills

To teach OpenCode how to use the `cs` CLI effectively, install the skill:

```bash
# Create the skill directory (name must match frontmatter)
mkdir -p ~/.config/opencode/skills/cogentry-substrate

# Copy the skill files
cp skills/*.md ~/.config/opencode/skills/cogentry-substrate/
```

OpenCode will discover the skill and list it in the `skill` tool. Agents can load it when working with codebases that have a `.cs/` index.

See the [Agent Skills specification](https://agentskills.io/specification) for more details on the skill format.

---

## Development

### Setup

```bash
git clone git@github.com:cogn3/substrate.git
cd substrate
npm install
```

### Build

```bash
npm run build        # Production build
npm run dev          # Watch mode
npm run typecheck    # Type check only
```

### Test

```bash
npm test              # All tests
npm run test:unit     # Unit tests only
npm run test:integration  # Integration tests
npm run test:coverage     # With coverage
```

### Lint

```bash
npm run lint          # ESLint + Prettier
npm run lint:fix      # Auto-fix
```

### Release

Build and publish a release to the `cogn3/releases` repository:

```bash
# Basic release (darwin-arm64)
./scripts/release.sh substrate v0.1.0

# Release for different target
./scripts/release.sh substrate v0.1.0 --target linux-x64

# Dry run (show what would happen)
./scripts/release.sh substrate v0.1.0 --dry-run

# Skip build, use existing binary
./scripts/release.sh substrate v0.1.0 --skip-build
```

| Option | Description |
|--------|-------------|
| `--target <target>` | Build target (e.g., `darwin-arm64`, `linux-x64`). Default: `darwin-arm64` |
| `--dry-run` | Show what would be done without executing |
| `--skip-build` | Skip build step (use existing binary) |
| `--binary <path>` | Use custom binary path instead of default |

**Prerequisites:**
- `bun` installed
- `gh` CLI authenticated with write access to `cogn3/releases`
- SSH key with access to `cogn3/releases`

The release script will:
1. Build a standalone binary using `bun build --compile`
2. Clone the `cogn3/releases` repository
3. Copy the binary and install assets (`install.sh`, `SKILLS.md`)
4. Commit and push to the releases repo
5. Create a GitHub Release with the binary attached

### Project Structure

```
cogentry-substrate/
├── src/
│   ├── cli/                    # CLI commands
│   ├── core/
│   │   ├── ingestion/          # Pipeline phases
│   │   ├── enrichers/          # Semantic enrichment
│   │   │   ├── frameworks/     # Framework detection
│   │   │   ├── dataflow/       # Data flow analysis
│   │   │   ├── architecture/   # Layer classification
│   │   │   └── git/            # Git metadata
│   │   ├── graph/              # Knowledge graph
│   │   ├── storage/            # LadybugDB adapter
│   │   ├── semantic/           # Semantic search (embeddings, parent context)
│   │   └── llm/                # LLM client
│   ├── mcp/                    # MCP server
│   └── shared/                 # Shared types
├── vendor/
│   └── leiden/                 # Vendored Leiden algorithm
├── tests/
│   ├── unit/
│   ├── integration/
│   └── fidelity/
├── SYSTEM_DESIGN.md            # Architecture documentation
└── README.md                   # This file
```

---

## Troubleshooting

### Tree-sitter Build Failures

```bash
# Skip optional native grammars
CS_SKIP_OPTIONAL_GRAMMARS=1 npm install
```

### LadybugDB Lock Errors

```bash
# Remove stale lock
rm .cs/lbug.lock

# Or force re-index
cs analyze --force
```

### AWS Bedrock Credential Errors

If you see "Skipping embeddings (AWS credentials invalid)", check:

1. **Create `.env` file** in the cogentry-substrate root (not the analyzed repo):
   ```bash
   # .env
   AWS_ACCESS_KEY_ID=your_access_key
   AWS_SECRET_ACCESS_KEY=your_secret_key
   AWS_REGION=ap-northeast-1
   ```

2. **Shell environment conflicts**: Shell env vars take precedence. Unset them if needed:
   ```bash
   unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
   ```

3. **Verify credentials**:
   ```bash
   aws bedrock list-foundation-models --region ap-northeast-1 --query 'modelSummaries[?contains(modelId, `cohere`)]'
   ```

### Multimodal Extraction Timeouts

```bash
# Increase API timeout
CS_API_TIMEOUT=900 cs analyze --multimodal
```

### Large Repository Performance

```bash
# Increase worker timeout for slow parses
cs analyze --worker-timeout 60

# Skip embeddings for faster indexing
cs analyze --skip-embeddings
```

---

## Output Files

After running `cs analyze`, files are created in `.cs/`:

| File | Description |
|------|-------------|
| `graph.lbug` | Graph database (LadybugDB with Cypher support) |
| `semantic.sqlite` | Semantic search index (embeddings + FTS5) |
| `fts-index.json` | Full-text search index |
| `meta.json` | Index metadata and statistics |
| `GRAPH_REPORT.md` | Human-readable analysis report |

**Note:** Domain analysis results (Domain, Flow, Step nodes) are stored directly in the graph database alongside code nodes.

For detailed schema information, see [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md#3-unified-node-schema).

---

## Architecture

See [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) for detailed architecture documentation including:
- Node and relationship schemas
- Pipeline phase definitions
- Storage design
- MCP server internals
- Implementation roadmap

---

## Agent Skills

See [skills/SKILL.md](skills/SKILL.md) for the OpenCode skill definition including:
- Pre-edit workflows
- Command quick reference
- Semantic search patterns
- Business domain analysis
- Common workflow examples

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make changes with tests
4. Run `npm test && npm run lint`
5. Commit with conventional commits: `feat: add new feature`
6. Open a Pull Request

---

## License

MIT

---

## Credits

Cogentry Substrate combines ideas from:
- **GitNexus** — Deterministic call-chain tracing, blast radius analysis
- **Graphify** — Multimodal ingestion, semantic clustering, narrative summarization
