# Tribble Examples

Quick examples showing how fast you can spawn tabs with Tribble.

Like tribbles, your sessions multiply rapidly.

## Table of Contents

- [Single Sessions](#single-sessions)
- [Multiple Tasks](#multiple-tasks)
- [Development Workflows](#development-workflows)
- [Testing & CI/CD](#testing--cicd)

## Single Sessions

All single-session examples spawn in ~5 seconds with 0 questions.

### Open Claude for Feature Work

```
You: /tribble:run open claude to add dark mode

Claude: ✓ Created tab 'Add Dark Mode'
        Your session is ready!
```

### Run Tests

```
You: /tribble:run run tests

Claude: ✓ Created tab 'Run Tests'
        Running npm test in /current/dir
```

### Start Dev Server

```
You: /tribble:run start dev server

Claude: ✓ Created tab 'Dev Server'
        Running npm run dev in /current/dir
```

### Run Build

```
You: /tribble:run build the project

Claude: ✓ Created tab 'Build Project'
        Running npm run build in /current/dir
```

### Start Docker Container

```
You: /tribble:run start postgres

Claude: ✓ Created tab 'Start Postgres'
        Running docker-compose up postgres in /current/dir
```

## Multiple Tasks

All tasks spawn immediately in parallel after 1 question max (~10 seconds total).

### Development Servers

```
You: /tribble:run start frontend, backend, and database

Claude: What commands should I run?

You: npm run dev, npm run api:dev, docker-compose up postgres

Claude: ✓ Created tab 'Frontend'
        ✓ Created tab 'Backend'
        ✓ Created tab 'Database'

        Your sessions are ready!
```

**Result:** Three servers running in parallel, ready in ~10 seconds.

### Multiple Claude Sessions

```
You: /tribble:run open claude for auth work and another for updating docs

Claude: ✓ Created tab 'Auth Work'
        ✓ Created tab 'Update Docs'

        Your sessions are ready!
```

**Result:** Two Claude sessions open, both ready immediately.

### Test Suite

```
You: /tribble:run run frontend tests, backend tests, and integration tests

Claude: What commands?

You: npm run test:frontend, npm run test:backend, npm run test:integration

Claude: ✓ Created tab 'Frontend Tests'
        ✓ Created tab 'Backend Tests'
        ✓ Created tab 'Integration Tests'

        Your sessions are ready!
```

**Result:** All tests running in parallel.

## Development Workflows

### Full Stack Development

**Scenario:** Complete dev environment with multiple services

```
You: /tribble:run start frontend on 3000, backend on 4000, postgres, redis, and tail logs

Claude: What commands?

You: npm run dev, npm run api:dev, docker-compose up postgres, docker-compose up redis, tail -f logs/app.log

Claude: ✓ Created tab 'Frontend'
        ✓ Created tab 'Backend'
        ✓ Created tab 'Postgres'
        ✓ Created tab 'Redis'
        ✓ Created tab 'Logs'

        Your sessions are ready!
```

**Result:** Complete dev environment in ~10 seconds. All services running in parallel.

### Microservices Development

**Scenario:** Start 5 microservices

```
You: /tribble:run start auth service, user service, order service, payment service, and notification service

Claude: What commands?

You: npm run start:auth, npm run start:user, npm run start:order, npm run start:payment, npm run start:notify

Claude: ✓ Created tab 'Auth Service'
        ✓ Created tab 'User Service'
        ✓ Created tab 'Order Service'
        ✓ Created tab 'Payment Service'
        ✓ Created tab 'Notification Service'

        Your sessions are ready!
```

**Result:** All 5 services running in parallel.

### Multiple Projects

**Scenario:** Work on different projects simultaneously

```
You: /tribble:run open claude in ~/project-a to fix API and another in ~/project-b to update tests

Claude: ✓ Created tab 'Fix API' (project-a)
        ✓ Created tab 'Update Tests' (project-b)

        Your sessions are ready!
```

**Result:** Two Claude sessions in different directories.

## Testing & CI/CD

### Parallel Test Suites

```
You: /tribble:run run all test suites in parallel

Claude: What commands?

You: npm run test:unit, npm run test:integration, npm run test:e2e

Claude: ✓ Created tab 'Unit Tests'
        ✓ Created tab 'Integration Tests'
        ✓ Created tab 'E2E Tests'

        Your sessions are ready!
```

**Result:** All tests running in parallel. Saves 10-15 minutes compared to sequential.

### Lint and Type Check

```
You: /tribble:run run eslint and typescript checks

Claude: What commands?

You: npm run lint, npm run type-check

Claude: ✓ Created tab 'ESLint'
        ✓ Created tab 'Type Check'

        Your sessions are ready!
```

**Result:** Both running in parallel.

### Build Variants

```
You: /tribble:run build for dev, staging, and production

Claude: What commands?

You: npm run build:dev, npm run build:staging, npm run build:prod

Claude: ✓ Created tab 'Build Dev'
        ✓ Created tab 'Build Staging'
        ✓ Created tab 'Build Prod'

        Your sessions are ready!
```

**Result:** All builds running in parallel.

## Note on Dependencies

If tasks depend on each other (e.g., "run tests then build"), spawn them all and run them manually in order:

```
You: /tribble:run spawn tabs for tests and build

Claude: What commands?

You: npm test, npm run build

Claude: ✓ Created tab 'Tests'
        ✓ Created tab 'Build'

        Your sessions are ready!
```

Then switch to the Tests tab, run tests, and when they pass, switch to the Build tab and run the build. Like tribbles multiplying, Tribble spawns tabs quickly - you control when to start each one.

## Tips for Fast Spawning

**Be specific:**
- "open claude to work on auth" → instant spawn
- "start dev server" → instant spawn
- "run tests" → instant spawn

**For multiple tasks, provide commands if you can:**
- "start frontend with npm run dev and backend with npm run api:dev" → instant spawn (no questions)

**Use standard command names:**
- "run tests" → automatically uses "npm test"
- "build" → automatically uses "npm run build"
- "start dev" → automatically uses "npm run dev"
