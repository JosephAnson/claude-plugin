---
description: Design OpenAPI 3.0 specifications from legacy code or requirements
argument-hint: [feature-name]
---

# OpenAPI Design

Create production-ready OpenAPI 3.0 specifications with entity models, shared schemas, and best practices.

## Usage

```bash
/ja:openapi-design inventory    # Design API for inventory feature
/ja:openapi-design              # Prompts for feature details
```

## Core Responsibilities

1. **Requirements Analysis**: Examine existing code, documentation, or requirements. Extract entities, relationships, and operations. When migrating, ensure new API endpoints replicate existing functionality exactly.

2. **OpenAPI Specification Design**: Create comprehensive OpenAPI 3.0 specifications. Every endpoint must include:
   - Clear operation IDs and descriptions
   - Comprehensive request/response schemas
   - Proper HTTP methods and status codes
   - Authentication/authorisation requirements
   - Validation rules and constraints
   - Example requests and responses

3. **Entity Architecture**: Design robust entity models following ER diagram principles. Create reusable schema components. Define clear relationships, cardinality, and constraints.

4. **File Organisation**: Store specifications in a structured format:
   - `{feature-name}/openapi.yml` - The OpenAPI specification
   - `{feature-name}/entities.md` - Entity relationship documentation with Mermaid ER diagrams
   - `{feature-name}/implementation-notes.md` - Technical considerations and business rules
   - `shared/schemas.yml` - Common entity definitions referenced across features

## Design Guidelines

**RESTful conventions:**
- Resources as nouns, proper HTTP methods, hierarchical URLs
- Design for idempotency where appropriate (PUT, DELETE)
- Include pagination, filtering, and sorting for collection endpoints
- Define comprehensive error responses with actionable messages
- Consistent naming: kebab-case for URLs, camelCase for JSON properties
- Leverage `$ref` extensively to share schemas and reduce duplication

**Frontend-focused:**
- Optimise for frontend consumption - minimise round trips, include computed fields
- Use discriminated unions for arrays with mixed types - include `type` discriminator field

**Entity modelling:**
- Identify core entities, attributes, primary keys, and relationships
- Balance normalisation with practical API design
- Define clear cardinality (one-to-one, one-to-many, many-to-many)
- Document business rules and constraints explicitly
- Consider soft deletes, audit trails, and versioning

## Workflow

### 1. Analyse Requirements
- Identify data models, business operations, validation rules, user permissions, API contracts
- Document ambiguities or assumptions
- Note domain-specific business logic that must be preserved

### 2. Design Specification
- Create OpenAPI 3.0 spec following best practices from https://learn.openapis.org/best-practices.html
- Create entity documentation with Mermaid ER diagrams
- Create implementation notes for complex business logic

### 3. Validate
- Schema correctness and completeness
- Best practice compliance
- Entity consistency across endpoints
- Proper use of shared components
- Valid examples and response structures

## Output

1. Announce which code/requirements you're analysing
2. Present the OpenAPI specification file path and contents
3. Present entity documentation with ER diagrams
4. Present implementation notes
5. Highlight assumptions or areas requiring clarification

## Edge Cases

- Unclear business logic: document assumptions and flag for review
- Ambiguous entity relationships: propose multiple options with trade-offs
- Design conflicts with best practices: document deviation with justification
- Complex shared schemas: consider feature-specific variations
