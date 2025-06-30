# Database Evolution Patterns

## Overview

This document captures patterns and lessons learned from evolving database architectures in production applications. It covers schema design, migration strategies, and the journey from simple schemas to sophisticated knowledge graphs.

## Database Evolution Stages

### Stage 1: Simple Tables
Most projects start here - basic CRUD operations with straightforward schemas.

```sql
-- Initial simple approach
CREATE TABLE vocabulary (
    id SERIAL PRIMARY KEY,
    word VARCHAR(255),
    translation VARCHAR(255),
    language VARCHAR(10)
);
```

### Stage 2: Normalized Relations
As duplication becomes apparent, normalization emerges.

```sql
-- Normalized approach
CREATE TABLE languages (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) UNIQUE,
    name VARCHAR(100)
);

CREATE TABLE words (
    id SERIAL PRIMARY KEY,
    content VARCHAR(255),
    language_id INTEGER REFERENCES languages(id)
);

CREATE TABLE translations (
    word_id INTEGER REFERENCES words(id),
    translation_id INTEGER REFERENCES words(id),
    PRIMARY KEY (word_id, translation_id)
);
```

### Stage 3: Knowledge Graph
Eventually, the realization that knowledge is compositional leads to graph structures.

```sql
-- Knowledge graph approach
CREATE TABLE knowledge_nodes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content TEXT NOT NULL,
    node_type VARCHAR(50) NOT NULL,
    domain VARCHAR(50) NOT NULL,
    atomic_level INTEGER DEFAULT 0,
    metadata JSONB
);

CREATE TABLE knowledge_edges (
    from_node_id UUID REFERENCES knowledge_nodes(id),
    to_node_id UUID REFERENCES knowledge_nodes(id),
    edge_type VARCHAR(50) NOT NULL,
    strength DECIMAL(3,2) DEFAULT 1.0,
    metadata JSONB,
    PRIMARY KEY (from_node_id, to_node_id, edge_type)
);
```

## Key Patterns

### 1. The Duplication Discovery Pattern

**Problem**: Same data exists in multiple tables with slight variations.

**Recognition Signs**:
- Multiple tables with similar names (`words`, `vocabulary`, `dictionary`)
- CSV imports creating new tables instead of updating existing ones
- "Let's just create a new table for this feature" mentality

**Solution**: Create a unified schema with proper abstraction.

```sql
-- Before: Multiple tables
CREATE TABLE english_words (...);
CREATE TABLE chinese_words (...);
CREATE TABLE spanish_words (...);

-- After: Unified with metadata
CREATE TABLE lexical_items (
    id UUID PRIMARY KEY,
    content TEXT NOT NULL,
    language_code VARCHAR(10) NOT NULL,
    properties JSONB NOT NULL, -- Stores language-specific data
    INDEX idx_language (language_code)
);
```

### 2. The Dependency Realization Pattern

**Problem**: Need to represent that some knowledge depends on other knowledge.

**Examples**:
- Chinese word "森林" (forest) requires knowing "木" (tree)
- Calculus requires understanding derivatives
- React hooks require understanding closures

**Solution**: Explicit dependency modeling.

```sql
-- Dependency types
CREATE TYPE dependency_type AS ENUM (
    'requires',      -- Hard requirement
    'recommends',    -- Helpful but not required
    'relates_to',    -- Conceptually related
    'builds_on'      -- Extended concept
);

-- Dependencies with strength
CREATE TABLE dependencies (
    from_id UUID REFERENCES knowledge_nodes(id),
    to_id UUID REFERENCES knowledge_nodes(id),
    dependency_type dependency_type,
    strength DECIMAL(3,2) DEFAULT 1.0,
    reason TEXT, -- Why this dependency exists
    PRIMARY KEY (from_id, to_id)
);
```

### 3. The User State Tracking Pattern

**Problem**: Need to track what users know without invasive monitoring.

**Anti-pattern**: Tracking every click, scroll, and hover.

**Solution**: Meaningful event tracking only.

```sql
-- User knowledge state
CREATE TABLE user_knowledge_state (
    user_id UUID NOT NULL,
    node_id UUID REFERENCES knowledge_nodes(id),
    state VARCHAR(20) NOT NULL, -- 'unknown', 'seen', 'learned', 'mastered'
    confidence DECIMAL(3,2),
    last_seen TIMESTAMP,
    repetitions INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (user_id, node_id)
);

-- Learning events (not clicks!)
CREATE TABLE learning_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    node_id UUID REFERENCES knowledge_nodes(id),
    event_type VARCHAR(50), -- 'assessment', 'practice', 'review'
    response JSONB,         -- Event-specific data
    duration_ms INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 4. The Algorithm Evolution Pattern

**Problem**: Hard-coding learning algorithms limits adaptation.

**Solution**: Let algorithms compete and evolve.

```sql
-- Algorithm registry
CREATE TABLE learning_algorithms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    version VARCHAR(20) NOT NULL,
    algorithm_type VARCHAR(50), -- 'suggestion', 'review', 'sequencing'
    parameters JSONB,
    parent_algorithm_id UUID REFERENCES learning_algorithms(id),
    fitness_score DECIMAL(10,4),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Algorithm performance tracking
CREATE TABLE algorithm_performance (
    algorithm_id UUID REFERENCES learning_algorithms(id),
    user_segment VARCHAR(100), -- 'beginner', 'visual_learner', etc.
    metric_name VARCHAR(100),  -- 'retention_rate', 'completion_rate'
    metric_value DECIMAL(10,4),
    sample_size INTEGER,
    measured_at TIMESTAMP DEFAULT NOW()
);
```

### 5. The Metadata Evolution Pattern

**Problem**: Requirements change, new fields needed constantly.

**Solution**: Strategic use of JSONB for flexibility.

```sql
-- Rigid schema (requires migration for changes)
CREATE TABLE content_v1 (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    difficulty INTEGER,
    category VARCHAR(100)
    -- Need migration to add 'topic'
);

-- Flexible schema
CREATE TABLE content_v2 (
    id UUID PRIMARY KEY,
    core_content TEXT NOT NULL,      -- What never changes
    content_type VARCHAR(50) NOT NULL,
    metadata JSONB NOT NULL DEFAULT '{}', -- Everything else

    -- Indexes on JSONB fields used in queries
    INDEX idx_metadata_difficulty ((metadata->>'difficulty')),
    INDEX idx_metadata_language ((metadata->>'language'))
);
```

## Migration Strategies

### 1. The Parallel Run Pattern

Run old and new schemas in parallel during transition:

```sql
-- Step 1: Create new structure
CREATE TABLE knowledge_nodes_v2 (...);

-- Step 2: Sync data (trigger or application logic)
CREATE OR REPLACE FUNCTION sync_to_v2() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO knowledge_nodes_v2 (id, content, ...)
    VALUES (NEW.id, NEW.content, ...)
    ON CONFLICT (id) DO UPDATE SET ...;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 3: Gradually migrate reads to v2
-- Step 4: Stop writes to v1
-- Step 5: Drop v1 tables
```

### 2. The View Bridge Pattern

Use views to maintain backwards compatibility:

```sql
-- After restructuring, create views with old names
CREATE VIEW vocabulary AS
SELECT
    kn.id,
    kn.content as word,
    trans.content as translation,
    kn.metadata->>'language' as language
FROM knowledge_nodes kn
JOIN knowledge_edges ke ON ke.from_node_id = kn.id
JOIN knowledge_nodes trans ON trans.id = ke.to_node_id
WHERE kn.node_type = 'word'
  AND ke.edge_type = 'translates_to';
```

### 3. The Feature Flag Migration

Control migration with feature flags:

```typescript
// Application code
const useNewSchema = await featureFlags.isEnabled('use_knowledge_graph');

if (useNewSchema) {
    return queryKnowledgeGraph(params);
} else {
    return queryLegacyTables(params);
}
```

## Performance Patterns

### 1. Materialized Views for Complex Queries

```sql
-- Expensive graph traversal
CREATE MATERIALIZED VIEW user_learning_paths AS
WITH RECURSIVE knowledge_path AS (
    -- Base: what user knows
    SELECT uk.node_id, uk.user_id, 0 as depth
    FROM user_knowledge_state uk
    WHERE uk.state = 'mastered'

    UNION ALL

    -- Recursive: what they can learn next
    SELECT ke.to_node_id, kp.user_id, kp.depth + 1
    FROM knowledge_path kp
    JOIN knowledge_edges ke ON ke.from_node_id = kp.node_id
    WHERE kp.depth < 3
)
SELECT * FROM knowledge_path;

-- Refresh periodically
CREATE INDEX idx_learning_paths_user ON user_learning_paths(user_id);
```

### 2. JSONB Indexing Strategy

```sql
-- Partial indexes for common queries
CREATE INDEX idx_vocabulary_english
ON knowledge_nodes(content)
WHERE node_type = 'word'
  AND metadata->>'language' = 'en';

-- GIN indexes for JSONB containment
CREATE INDEX idx_metadata_gin
ON knowledge_nodes USING gin(metadata);

-- Expression indexes for nested fields
CREATE INDEX idx_difficulty
ON knowledge_nodes((metadata->'properties'->>'difficulty'));
```

## Anti-Patterns to Avoid

### 1. The "God Table" Anti-Pattern
One table trying to store everything with 100+ columns.

### 2. The "Soft Delete Everything" Anti-Pattern
Never actually deleting data, leading to bloat and complexity.

### 3. The "EAV Everywhere" Anti-Pattern
Entity-Attribute-Value for all data, losing all type safety.

### 4. The "Premature Optimization" Anti-Pattern
Adding indexes, partitions, and sharding before measuring.

### 5. The "Migration Paralysis" Anti-Pattern
Schema so complex that team fears making changes.

## Lessons Learned

1. **Start Simple**: Don't build a knowledge graph on day one
2. **Migrate Gradually**: Big bang migrations usually fail
3. **Keep History**: Track schema evolution in documentation
4. **Measure Everything**: Before optimizing, measure
5. **Plan for Change**: Use JSONB for truly variable data
6. **Test Migrations**: Always test on production-like data
7. **Version Your Schema**: Include version in table names during transitions

## Schema Documentation Template

Always document your schemas with:

```sql
-- Purpose: Store all knowledge items in a unified graph structure
-- Relations: Connects to knowledge_edges for dependencies
-- Migration: Replaces vocabulary, words, and content tables
-- Indexes: content (text search), node_type (filtering), metadata (JSONB queries)
-- Performance: ~10ms for single node, ~50ms for 3-level traversal
CREATE TABLE knowledge_nodes (
    -- Unique identifier for the knowledge item
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- The actual content (word, concept, formula, etc.)
    content TEXT NOT NULL,

    -- ... rest of schema
);
```

## Conclusion

Database evolution is inevitable in growing applications. The key is recognizing patterns early and having strategies ready. Start simple, normalize when duplication hurts, and move to graph structures when relationships become primary. Most importantly, always provide migration paths that don't break existing functionality.