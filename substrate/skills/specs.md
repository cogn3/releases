# LASF Specification Extraction

CS can extract a universal Language-Agnostic Specification Format (LASF) from any codebase.

## Basic Usage

```bash
# Extract specs (requires cs analyze first)
cs specs

# Save to file with pretty printing
cs specs -o spec.json --pretty

# Show summary instead of full JSON
cs specs -f summary

# Filter by language or framework
cs specs --language typescript
cs specs --framework fastapi
```

## Options

| Option | Description |
|--------|-------------|
| `-o, --output <file>` | Output file path |
| `-f, --format` | `json` (default) or `summary` |
| `--pretty` | Pretty print JSON output |
| `-l, --language <lang>` | Filter by source language |
| `--framework <fw>` | Filter by framework |

Use `--language help` or `--framework help` to list supported values.

## What LASF Extracts

| Category | Source | Extracted |
|----------|--------|-----------|
| **Types** | TS/JS/Python/Java/Go/Rust/PHP | Classes, interfaces, structs, enums, type aliases |
| **ORM Schemas** | SQLAlchemy, TypeORM, JPA/Hibernate | Tables, columns, constraints, relationships |
| **Data Models** | Pydantic, Python dataclasses | Fields, types, validators, defaults |
| **API Specs** | OpenAPI/Swagger, Protobuf, GraphQL | Routes, parameters, request/response schemas |
| **Semantic** | All languages | Error patterns, concurrency patterns, config |

## Output Structure

```json
{
  "version": "1.0",
  "metadata": {
    "extractedAt": "2024-01-15T10:30:00Z",
    "sourceLanguages": ["typescript", "python"]
  },
  "types": [...],
  "routes": [...],
  "dataStores": [...],
  "services": [...],
  "config": {...}
}
```

## Use Cases

- Cross-language refactoring (extract Python specs, generate TypeScript types)
- API documentation generation from actual code
- Migration planning (understand schema before changing DBs)
- Code intelligence for LLMs (feed LASF for better understanding)
- Consistency validation across microservices
