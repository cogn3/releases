# Common Workflows

## Pre-Edit Workflow (Required)

Every time you modify a symbol:

```bash
# 1. Understand the symbol
cs context myFunction

# 2. Check blast radius (REQUIRED before any edit)
cs impact myFunction --direction upstream

# 3. Read rationale comments if any
cs explain myFunction

# 4. Make your changes

# 5. Validate your changes
cs detect-changes
```

## Exploring New Codebase

```bash
cs status              # Check for existing index
cs analyze .           # Create index if missing
cs god-nodes           # Find important entry points
cs communities         # See code organization
cs routes              # Find API endpoints (if web app)
cs search "main concepts"  # Semantic search for key areas
```

## Safe Function Edit

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

## Tracing a Bug

```bash
cs query "error message or symptom"
cs search "error handling" --intent "exception catching"
cs context suspectedFunction
cs path entryPoint problematicFunction
cs dataflow --symbol suspectedFunction
```

## Planning a Refactor

```bash
cs impact targetSymbol -d upstream    # What breaks?
cs impact targetSymbol -d downstream  # What do I depend on?
cs communities                         # Am I crossing boundaries?
cs architecture                        # Any layer violations?
cs domain list                         # Which business domains affected?
```

## Validation Checklist

Before completing any code modification task, verify:

- [ ] Ran `cs context` on every symbol you edited
- [ ] Ran `cs impact --direction upstream` and reviewed all d=1 callers
- [ ] Ran `cs detect-changes` and confirmed risk level is acceptable
- [ ] Updated any d=1 callers if you changed a function signature

## Understanding Impact Output

| Depth | Label | What It Means |
|-------|-------|---------------|
| d=1 | WILL BREAK | Direct callers — MUST update if you change signature |
| d=2 | LIKELY AFFECTED | Indirect callers — should test these |
| d=3 | MAY NEED TESTING | Transitive — run tests to catch issues |

**Do not ignore depth 2-3.** They often contain subtle breakages.

## Gotchas

- **Always check for an index first.** Run `cs status` before using other commands.
- **The `--direction` flag matters for impact.** Use `upstream` to see callers (what breaks), `downstream` to see dependencies.
- **Community names are heuristic.** Generated from file paths, not authoritative.
- **detect-changes requires uncommitted changes.** It compares working tree against the index.
- **God nodes are navigation anchors.** Start exploration from these high-centrality symbols.
