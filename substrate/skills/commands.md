# Full Command Reference

All `cs` commands and their options.

## Indexing & Status

| Command | Options | Description |
|---------|---------|-------------|
| `cs analyze [path]` | `-f, --force`, `-m, --multimodal`, `--skip-embeddings`, `--skip-communities`, `--skip-gitignore`, `--git-enrich`, `-v, --verbose`, `--worker-timeout <ms>` | Index a repository |
| `cs status` | (none) | Show index status |
| `cs clean` | `-a, --all`, `-f, --force` | Delete index |
| `cs list-repos` | (none) | List all indexed repositories |

## Query & Search

| Command | Options | Description |
|---------|---------|-------------|
| `cs query <query>` | `-r, --repo`, `-l, --limit`, `--min-confidence` | Basic FTS search |
| `cs search <query>` | `-r, --repo`, `-l, --limit`, `-m, --mode`, `--intent`, `--no-rerank`, `--no-expand`, `--debug` | Semantic search |
| `cs cypher <query>` | `-r, --repo`, `--format <table\|json>` | Execute Cypher queries |

## Code Analysis

| Command | Options | Description |
|---------|---------|-------------|
| `cs context <symbol>` | `-r, --repo` | 360° view: callers, callees, imports, inheritance |
| `cs impact <target>` | `-r, --repo`, `-d, --direction`, `--depth`, `--min-confidence`, `--include-tests` | Blast radius analysis |
| `cs path <from> <to>` | `-r, --repo` | Shortest path between nodes |
| `cs explain <symbol>` | `-r, --repo` | Symbol with rationale comments |
| `cs god-nodes` | `-r, --repo`, `-l, --limit` | High-centrality symbols |
| `cs detect-changes` | `--staged`, `--base`, `-v, --verbose` | Map git changes to graph |

## Architecture & Structure

| Command | Options | Description |
|---------|---------|-------------|
| `cs architecture` | `-r, --repo` | Layer analysis and violations |
| `cs communities` | `-r, --repo`, `-l, --limit` | Code clusters (Leiden) |
| `cs dataflow` | `-r, --repo`, `-s, --symbol` | Storage and service calls |
| `cs routes` | `-r, --repo` | API endpoints |
| `cs processes` | `-r, --repo`, `-l, --limit` | Execution flows |

## Domain Analysis

| Command | Options | Description |
|---------|---------|-------------|
| `cs domain analyze` | `-r, --repo`, `--refresh` | Extract business domains |
| `cs domain list` | `-r, --repo` | List discovered domains |
| `cs domain show <name>` | `-r, --repo` | Show domain details |
| `cs domain flow <name>` | `-r, --repo` | Show flow steps |
| `cs domain export` | `-r, --repo`, `-o, --output`, `-f, --format` | Export domain graph |

## Export & Reports

| Command | Options | Description |
|---------|---------|-------------|
| `cs specs` | `-o, --output`, `-f, --format`, `--pretty`, `-l, --language`, `--framework` | Export LASF spec |
| `cs report [type]` | `-o, --output`, `--json` | Generate reports |
| `cs export [path]` | `--neo4j`, `--obsidian`, `--json`, `-o, --output` | Export graph |
| `cs business` | `-g, --generate`, `-i, --import`, `-l, --live`, `-p, --port`, `-o, --output` | Collect business context |

## Integration

| Command | Options | Description |
|---------|---------|-------------|
| `cs mcp` | (none) | Start MCP server (stdio) |
| `cs serve` | `-p, --port`, `-h, --host` | Start HTTP API server |
| `cs hook <action>` | (action: install, uninstall, status) | Manage git hooks |
| `cs benchmark [path]` | `-n, --iterations`, `--skip-communities`, `-v, --verbose` | Performance testing |
