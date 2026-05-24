# Business Domain Analysis

CS can extract business domains from your codebase using LLM analysis.

## Basic Usage

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
```

## Commands

| Command | Description |
|---------|-------------|
| `cs domain analyze` | Extract domains from codebase |
| `cs domain list` | List discovered domains |
| `cs domain show <name>` | Show domain details |
| `cs domain flow <name>` | Show flow steps |
| `cs domain export` | Export as JSON or Mermaid |

## Domain Hierarchy

- **Domain**: High-level business area (e.g., "Order Management", "User Authentication")
- **Flow**: Specific process within a domain (e.g., "Create Order", "Process Refund")
- **Step**: Individual action within a flow (e.g., "Validate Cart", "Check Inventory")

## Querying Domains with Cypher

```bash
# List all domains and their flows
cs cypher "MATCH (d:Domain)-[:CONTAINS_FLOW]->(f:Flow) RETURN d.name, f.name"

# Find steps in a specific flow
cs cypher "MATCH (f:Flow {name: 'Create Order'})-[:FLOW_STEP]->(s:Step) RETURN s"
```

## Outputs

- Domain, Flow, and Step nodes stored in graph database
- Mermaid diagrams for documentation
- Cross-domain relationship mapping
- Implementation links connecting steps to actual code symbols
