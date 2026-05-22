---
name: cogentry-substrate
description: >
  Analyze code dependencies, blast radius, and business domains before editing any symbol.
  Use this skill when modifying functions, classes, or methods in an indexed
  codebase — run cs context and cs impact BEFORE making changes to understand
  who calls the code and what will break. Also use for exploring unfamiliar
  codebases, tracing bugs through call chains, planning refactors, finding
  API endpoints, and understanding business domain structure. Activate this skill
  whenever you see a .cs/ directory or when the user mentions "blast radius,"
  "impact analysis," "who calls this," "code graph," "domain analysis," or
  "business flows."
license: MIT
compatibility: Requires cs CLI installed via npm link after cloning cogn3/substrate
metadata:
  author: cogn3
  version: "1.1"
---

# Cogentry Substrate Skill

Use the `cs` CLI to understand code dependencies before making changes.

## The Golden Rule

**NEVER edit a symbol without first running `cs context` and `cs impact` on it.**

```bash
# Before editing ANY function, class, or method:
cs context <symbol>                    # Who uses it? What does it call?
cs impact <symbol> --direction upstream # What breaks if I change it?
```

## What I Do

- Analyze code dependencies before you make changes
- Show blast radius (what breaks if you modify a symbol)
- Find callers, callees, imports, and inheritance relationships
- **Advanced semantic search** with LLM query expansion, HyDE, and intent-aware disambiguation
- **Business domain analysis** mapping code to Domain -> Flow -> Step hierarchy
- Detect API endpoints, execution flows, and code communities
- Identify architectural layer violations
- Trace how data flows through storage and external services

## When to Use Me

Use this skill when you need to:
- Edit any function, class, or method (run context + impact first)
- Explore an unfamiliar codebase (find god nodes and communities)
- Trace a bug through call chains (use path and dataflow)
- Plan a refactor (check impact in both directions)
- Find API endpoints (use routes command)
- Validate changes before committing (use detect-changes)
- **Understand business domains** (use domain analyze/list/show)
- **Search with intent** (use search --intent for disambiguation)

## Pre-Edit Workflow

Every time you modify a symbol, follow this sequence:

```bash
# 1. Understand the symbol
cs context validateUser

# 2. Check blast radius (REQUIRED before any edit)
cs impact validateUser --direction upstream

# 3. Read rationale comments if any
cs explain validateUser

# 4. Make your changes

# 5. Validate your changes match expectations
cs detect-changes
```

## Command Quick Reference

### Before Editing (Required)

| Command | Purpose |
|---------|---------|
| `cs context <symbol>` | See callers, callees, imports, inheritance |
| `cs impact <symbol> -d upstream` | See what breaks if you change it |
| `cs explain <symbol>` | Read WHY/NOTE/HACK comments |

### After Editing (Required)

| Command | Purpose |
|---------|---------|
| `cs detect-changes` | Validate affected nodes match expectations |
| `cs detect-changes --staged` | Check only staged changes |

### Exploring a Codebase

| Command | Purpose |
|---------|---------|
| `cs god-nodes` | Find high-centrality entry points |
| `cs communities` | See how code is organized into clusters |
| `cs routes` | List API endpoints (web apps) |
| `cs query <term>` | Search for symbols by name |
| `cs search <query>` | Semantic search across code and docs |
| `cs search <query> --intent "..."` | Search with disambiguation |
| `cs architecture` | Check layer violations |
| `cs domain list` | List discovered business domains |
| `cs domain show <name>` | Show domain details and flows |

### Tracing and Debugging

| Command | Purpose |
|---------|---------|
| `cs path <from> <to>` | Find how two symbols connect |
| `cs dataflow --symbol <name>` | Trace data through storage/services |
| `cs processes` | See execution flows from entry points |
| `cs search "error handling" --intent "exception catching"` | Intent-aware search |
| `cs domain flow <name>` | Show all steps in a business flow |

### Maintenance

| Command | Purpose |
|---------|---------|
| `cs status` | Check if index exists and is current |
| `cs analyze .` | Create or update the index |
| `cs analyze . --force` | Force full re-index |
| `cs analyze . --skip-embeddings` | Index without generating embeddings |
| `cs analyze . --skip-gitignore` | Ignore .gitignore (use only .csignore) |
| `cs domain analyze` | Run/refresh domain analysis |

## Semantic Search

CS supports advanced semantic search with LLM-powered query expansion and intent disambiguation:

```bash
# Basic semantic search (hybrid mode with query expansion)
cs search "authentication flow"

# Search with intent for disambiguation
cs search "performance" --intent "database query optimization"

# Vector-only search (similarity-based)
cs search "error handling" --mode vector

# Full-text search only (fastest, no LLM)
cs search "validateUser" --mode keyword

# Disable query expansion for faster results
cs search "database connection" --no-expand

# Show debug info including query expansions
cs search "auth" --debug
```

**Search modes:**
- `hybrid` (default): Combines vector similarity + FTS5 keyword matching with LLM query expansion
- `vector`: Pure embedding-based similarity search
- `keyword`: Traditional full-text search with BM25 ranking (fastest)

**Query Expansion (QMD-inspired):**
- `lex:` expansions - synonyms and related terms for BM25
- `vec:` expansions - semantically similar concepts for vector search  
- `hyde:` expansions - hypothetical document embeddings

**Intent Support:**
When you provide `--intent`, the search:
- Includes intent in query expansion prompts for better context
- Prepends intent to reranking queries
- Disables strong-signal bypass (forces deep semantic analysis)

Example: `cs search "performance" --intent "database query optimization"` disambiguates from sports or web performance.

**Strong-Signal Bypass:**
When BM25 finds an exact or near-exact match with high confidence, expensive LLM expansion is skipped. This is disabled when intent is provided to force thorough semantic analysis.

**Parent Context:** Search results include contextual information:
- Import block from the file header
- Enclosing class signature (for methods)

This helps you understand the context without reading the entire file.

## Business Domain Analysis

CS can extract business domains from your codebase using LLM analysis:

```bash
# Analyze and extract domains
cs domain analyze

# List discovered domains
cs domain list

# Show details of a specific domain
cs domain show "Order Management"

# Show steps in a business flow
cs domain flow "Create Order"

# Export domain graph
cs domain export --format mermaid -o domains.md
cs domain export --format json -o domains-export.json
```

**Domain Hierarchy:**
- **Domain**: High-level business area (e.g., "Order Management", "User Authentication")
- **Flow**: Specific process within a domain (e.g., "Create Order", "Process Refund")
- **Step**: Individual action within a flow (e.g., "Validate Cart", "Check Inventory")

**Outputs:**
- Domain, Flow, and Step nodes stored in `graph.lbug` alongside code nodes
- Queryable via Cypher: `MATCH (d:Domain)-[:CONTAINS_FLOW]->(f:Flow) RETURN d.name, f.name`
- Mermaid diagrams for documentation
- Cross-domain relationship mapping
- Implementation links connecting steps to actual code symbols

## Understanding Impact Output

The `cs impact` command shows affected code at different depths:

| Depth | Label | What It Means |
|-------|-------|---------------|
| d=1 | WILL BREAK | Direct callers — MUST update if you change signature |
| d=2 | LIKELY AFFECTED | Indirect callers — should test these |
| d=3 | MAY NEED TESTING | Transitive — run tests to catch issues |

**Do not ignore depth 2-3.** They often contain subtle breakages.

## Gotchas

- **Always check for an index first.** Run `cs status` before using other commands. If no index exists, run `cs analyze .` first.
- **The `--direction` flag is required for impact.** Use `upstream` to see callers (what breaks), `downstream` to see dependencies (what you rely on).
- **Community names are heuristic labels.** They're generated from file paths and member names, not authoritative.
- **Cypher queries use graph labels.** Valid labels: `Function`, `Class`, `Method`, `File`, `Community`. Use `cs cypher "MATCH (n:Function) RETURN COUNT(n)"` to explore.
- **God nodes are navigation anchors.** Start exploration from these high-centrality symbols.
- **detect-changes requires uncommitted changes.** It compares your working tree against the index.

## Validation Checklist

Before completing any code modification task, verify:

- [ ] Ran `cs context` on every symbol you edited
- [ ] Ran `cs impact --direction upstream` and reviewed all d=1 callers
- [ ] Ran `cs detect-changes` and confirmed risk level is acceptable
- [ ] Updated any d=1 callers if you changed a function signature

## Common Workflows

### Exploring New Codebase

```bash
cs status              # Check for existing index
cs analyze .           # Create index if missing
cs god-nodes           # Find important entry points
cs communities         # See code organization
cs routes              # Find API endpoints (if web app)
cs search "main concepts"  # Semantic search for key areas
```

### Safe Function Edit

```bash
cs context myFunction
# Review: 8 callers in 4 files

cs impact myFunction -d upstream
# Review: 23 affected nodes at depth 3

cs explain myFunction
# Check for NOTE/WHY/HACK comments

# Make your edit

cs detect-changes
# Verify: risk level is "medium", affected nodes match expectations
```

### Tracing a Bug

```bash
cs query "error message or symptom"
cs search "error handling" --intent "exception catching"  # Intent-aware search
cs context suspectedFunction
cs path entryPoint problematicFunction
cs dataflow --symbol suspectedFunction
```

### Planning a Refactor

```bash
cs impact targetSymbol -d upstream    # What breaks?
cs impact targetSymbol -d downstream  # What do I depend on?
cs communities                         # Am I crossing boundaries?
cs architecture                        # Any layer violations?
cs domain list                         # Which business domains are affected?
```

### Understanding Business Context

```bash
cs domain analyze                      # Extract domains from codebase
cs domain list                         # See all business domains
cs domain show "Payment Processing"    # Show domain details
cs domain flow "Process Refund"        # See steps in a flow
cs domain export --format mermaid      # Generate documentation
```

## When to Skip This Skill

- Typo fixes in comments or strings (no code graph impact)
- Documentation-only changes
- Adding new files with no imports from existing code
- No `.cs/` directory exists and user doesn't want to create one
