---
title: CLAUDE.md Templates
description: Documentation for CLAUDE.md templates that enable effective AI-assisted development
sidebar:
  order: 10
---

# CLAUDE.md Templates

Agent Init provides several CLAUDE.md templates to help you set up effective AI-assisted development workflows. These templates serve as the foundation for maintaining context and continuity across Claude sessions.

## Template Variants

### Base Template (`CLAUDE.md`)

The standard CLAUDE.md template suitable for most projects.

**Key Features:**
- Session tracking with goals and progress
- Issue-driven development workflow
- Available CLI tools documentation
- Project structure overview
- Development environment setup

**Best for:** General projects, libraries, CLI tools

### API Development Template (`CLAUDE-api.md`)

Specialized template for API development projects.

**Additional Features:**
- API endpoint documentation structure
- Request/response examples
- Authentication and authorization patterns
- OpenAPI/Swagger integration
- Database schema tracking

**Best for:** REST APIs, GraphQL APIs, microservices

### Web Application Template (`CLAUDE-web-app.md`)

Template optimized for web application development.

**Additional Features:**
- Frontend/backend architecture overview
- Component structure documentation
- State management patterns
- Build and deployment configuration
- User authentication flows

**Best for:** Single-page applications, full-stack web apps

## Template Structure

All CLAUDE.md templates follow a consistent structure:

### 1. Session Information
Track current development session with:
- Date and session ID
- Primary goals and objectives
- Progress checkboxes

### 2. Important Commands
Quick reference for essential commands:
- Linting and formatting
- Git workflow (issues, PRs)
- Development (test, build)
- Release management

### 3. Workflow Procedure
Step-by-step development process:
- Planning phase requirements
- Issue creation guidelines
- Development process
- Pull request guidelines
- Release management

### 4. Active Issues Tracking
Tables for managing:
- Active issues with status
- Completed issues with PRs
- Issue priorities

### 5. Project Structure
Clear overview of:
- Directory organization
- Key files and their purposes
- Configuration locations

### 6. Development Environment
Documentation of:
- Available CLI tools
- Key configurations
- Version information
- Release channels

### 7. Session Notes
Space for:
- Notes for next session
- Session history
- Key accomplishments

## Customization Guidelines

### Adding Project-Specific Sections

You can extend templates with:

```markdown
## Project-Specific Information

### Architecture Decisions
- [Decision 1]: Rationale and alternatives considered
- [Decision 2]: Implementation details

### External Dependencies
- Service A: Purpose and integration details
- Library B: Version and usage patterns

### Environment Variables
| Variable | Purpose | Example |
|----------|---------|---------|
| API_KEY  | Authentication | `sk-...` |
```

### Integration with Tools

Templates can be enhanced with tool-specific sections:

```markdown
## Tool Integration

### Docker
- Container configuration in `docker-compose.yml`
- Development: `docker-compose up -d`
- Production: See deployment guide

### Database
- Migrations: `npm run migrate`
- Seed data: `npm run seed`
- Schema: See `docs/schema.md`
```

## Best Practices

### 1. Keep Templates Updated
- Review and update templates regularly
- Add new commands as you discover them
- Update project structure as it evolves

### 2. Use Consistent Formatting
- Follow the established markdown structure
- Use tables for structured data
- Include code blocks with syntax highlighting

### 3. Maintain Context
- Update session information at start/end of sessions
- Log key decisions and their rationales
- Track issue progress consistently

### 4. Customize for Team
- Add team-specific workflows
- Include deployment procedures
- Document code review processes

## Template Selection Guide

Choose the right template based on your project type:

| Project Type | Template | Key Benefits |
|--------------|----------|--------------|
| Library/Package | `CLAUDE.md` | Simple, focused on code quality |
| REST API | `CLAUDE-api.md` | API-specific documentation structure |
| Web App | `CLAUDE-web-app.md` | Frontend/backend organization |
| CLI Tool | `CLAUDE.md` | Standard structure with tool focus |
| Documentation Site | `CLAUDE.md` | Content and publishing workflow |

## Integration with Agent Init

CLAUDE.md templates integrate seamlessly with other agent-init components:

- **Makefile**: Commands referenced in templates
- **GitHub Actions**: Release workflows documented
- **Session Scripts**: Automated session management
- **Issue Templates**: Consistent issue creation

## Advanced Usage

### Multiple CLAUDE Files

For complex projects, you can use multiple CLAUDE files:

```
CLAUDE.md              # Main project context
CLAUDE-frontend.md     # Frontend-specific context
CLAUDE-backend.md      # Backend-specific context
CLAUDE-infra.md        # Infrastructure context
```

### Template Inheritance

Create project-specific templates that extend base templates:

```markdown
<!-- Include base template content -->
<!-- Add project-specific sections -->

## Project: MyApp Specific

### Custom Workflows
- Deployment to staging: `make deploy-staging`
- Database migration: `make db-migrate`
```

Remember: The goal is to provide Claude with comprehensive context about your project, enabling more effective assistance throughout your development workflow.
