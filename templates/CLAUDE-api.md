# Claude AI Development Guide - API Development

This file tracks AI-assisted development for REST/GraphQL APIs and backend services.

## 🚀 Quick Reference Commands

```bash
# Development
npm run dev             # Start dev server with nodemon
npm run build           # Build TypeScript
npm run test            # Run tests
npm run test:watch      # Watch mode testing

# Database
npm run migrate         # Run migrations
npm run seed            # Seed database
npm run db:reset        # Reset database

# API Testing
curl -X GET http://localhost:3000/api/health
curl -X POST http://localhost:3000/api/users -H "Content-Type: application/json" -d '{}'
```

## 📋 Current Session

- **Date**: [YYYY-MM-DD]
- **API Type**: [ ] REST [ ] GraphQL [ ] gRPC
- **Database**: [ ] PostgreSQL [ ] MongoDB [ ] MySQL [ ] Other: ___
- **Primary Focus**: 

### Session Checklist
- [ ] Update API documentation
- [ ] Run integration tests
- [ ] Check query performance
- [ ] Validate input schemas
- [ ] Review error handling

## 🏗️ API Architecture

```
├── src/
│   ├── controllers/    # Request handlers
│   ├── models/         # Data models
│   ├── services/       # Business logic
│   ├── middleware/     # Express/Koa middleware
│   ├── validators/     # Input validation
│   ├── utils/          # Utilities
│   └── types/          # TypeScript types
├── tests/
│   ├── unit/          # Unit tests
│   ├── integration/   # Integration tests
│   └── fixtures/      # Test data
└── docs/
    └── api/           # API documentation
```

## 🔐 Security Checklist

- [ ] Input validation on all endpoints
- [ ] SQL injection prevention
- [ ] Rate limiting implemented
- [ ] Authentication/Authorization
- [ ] CORS properly configured
- [ ] Secrets in environment variables
- [ ] HTTPS only in production
- [ ] Security headers (Helmet.js)

## 📊 API Best Practices

### RESTful Endpoints
```typescript
GET    /api/users          # List
GET    /api/users/:id      # Get one
POST   /api/users          # Create
PUT    /api/users/:id      # Update (full)
PATCH  /api/users/:id      # Update (partial)
DELETE /api/users/:id      # Delete
```

### Error Handling
```typescript
// Consistent error format
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

### Response Format
```typescript
// Success response
{
  "data": { /* actual data */ },
  "meta": {
    "page": 1,
    "total": 100
  }
}

// Error response
{
  "error": { /* error details */ }
}
```

## 🧪 Testing Strategy

### Unit Tests
- Test individual functions
- Mock external dependencies
- Focus on business logic

### Integration Tests
- Test API endpoints
- Use test database
- Test authentication flow

### Load Testing
```bash
# Using Apache Bench
ab -n 1000 -c 10 http://localhost:3000/api/endpoint

# Using k6
k6 run load-test.js
```

## 📈 Performance Monitoring

- [ ] Query optimization (explain analyze)
- [ ] Caching strategy (Redis)
- [ ] Connection pooling
- [ ] Response time tracking
- [ ] Error rate monitoring

## 🔧 Database Patterns

### Migrations
```sql
-- Up migration
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Down migration
DROP TABLE users;
```

### Query Optimization
- Use indexes on frequently queried columns
- Avoid N+1 queries
- Use pagination for large datasets
- Consider materialized views

## 🐛 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Slow queries | Add indexes, optimize joins |
| Memory leaks | Close DB connections, clear caches |
| Rate limit hits | Implement caching, optimize queries |
| Auth failures | Check token expiry, permissions |

## 📝 Session Notes

[Add session-specific notes here]

---

Remember: Security first, performance second, features third!