---
name: cogentry-substrate
description: >
  Analyze code dependencies and blast radius before editing symbols. Use when
  modifying functions/classes in a codebase. Run cs analyze first to create index,
  then cs context (callers + callees), cs impact (blast radius), cs god-nodes
  (important symbols), cs architecture (layer violations).
license: MIT
metadata:
  author: cogn3
  version: "2.0"
---

# Cogentry Substrate

Use the `cs` CLI to understand code dependencies before making changes.

## The Golden Rule

**NEVER edit a symbol without first running `cs context` and `cs impact` on it.**

```bash
# Before editing ANY function, class, or method:
cs context <symbol>                    # Who calls it? What does it call?
cs impact <symbol> --direction upstream # What breaks if I change it?
```

## Quick Command Reference

| Command | Purpose |
|---------|---------|
| `cs analyze .` | Index the codebase (run first) |
| `cs status` | Check if index exists and is current |
| `cs context <symbol>` | Show callers, callees, imports, inheritance |
| `cs impact <symbol>` | Analyze blast radius (what breaks) |
| `cs explain <symbol>` | Show rationale comments (WHY/NOTE/HACK) |
| `cs god-nodes` | Find high-centrality entry points |
| `cs path <from> <to>` | Find how two symbols connect |
| `cs detect-changes` | Map git changes to affected nodes |

## When to Use

- Editing any function, class, or method → run `cs context` + `cs impact` first
- Exploring unfamiliar codebase → run `cs god-nodes` and `cs communities`
- Tracing a bug → use `cs path` and `cs dataflow`
- Planning a refactor → check `cs impact` in both directions
- Before committing → run `cs detect-changes`

## When to Skip

- Typo fixes in comments/strings
- Documentation-only changes
- Adding new files with no imports from existing code
- No `.cs/` directory exists

## Detailed Documentation

See the linked files for complete details:

- `commands.md` - Full command reference with all options
- `workflows.md` - Common workflows and validation checklist
- `search.md` - Semantic search with LLM expansion
- `specs.md` - LASF specification extraction
- `domains.md` - Business domain analysis
