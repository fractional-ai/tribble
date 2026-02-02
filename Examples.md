# Tribble Examples

Quick examples showing how fast you can spawn tabs with Tribble.

Like tribbles, your sessions multiply rapidly.

## Table of Contents

- [Single Sessions](#single-sessions)
- [Multiple Tasks](#multiple-tasks)
- [Development Workflows](#development-workflows)

## Single Sessions

All single-session examples spawn with 0 questions.

### Open Claude for Feature Work

```
You: /tribble:spawn open claude to add dark mode

Claude: ✓ Created tab 'Add Dark Mode'
        Your session is ready!
```

### Run Tests

```
You: /tribble:spawn run tests

Claude: ✓ Created tab 'Run Tests'
        Running npm test in /current/dir
```

### Start Dev Server

```
You: /tribble:spawn start dev server

Claude: ✓ Created tab 'Dev Server'
        Running npm run dev in /current/dir
```

### Run Build

```
You: /tribble:spawn build the project

Claude: ✓ Created tab 'Build Project'
        Running npm run build in /current/dir
```

### Start Docker Container

```
You: /tribble:spawn start postgres

Claude: ✓ Created tab 'Start Postgres'
        Running docker-compose up postgres in /current/dir
```

## Multiple Tasks

All tasks spawn immediately in parallel after 1 question max.

### Development Servers

```
You: /tribble:spawn start frontend, backend, and database

Claude: What commands should I run?

You: npm run dev, npm run api:dev, docker-compose up postgres

Claude: ✓ Created tab 'Frontend'
        ✓ Created tab 'Backend'
        ✓ Created tab 'Database'

        Your sessions are ready!
```

**Result:** Three servers running in parallel.

### Multiple Claude Sessions

```
You: /tribble:spawn open claude for auth work and another for updating docs

Claude: ✓ Created tab 'Auth Work'
        ✓ Created tab 'Update Docs'

        Your sessions are ready!
```

**Result:** Two Claude sessions open, both ready immediately.

### Test Suite

```
You: /tribble:spawn run frontend tests, backend tests, and integration tests

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
You: /tribble:spawn start frontend on 3000, backend on 4000, postgres, redis, and tail logs

Claude: What commands?

You: npm run dev, npm run api:dev, docker-compose up postgres, docker-compose up redis, tail -f logs/app.log

Claude: ✓ Created tab 'Frontend'
        ✓ Created tab 'Backend'
        ✓ Created tab 'Postgres'
        ✓ Created tab 'Redis'
        ✓ Created tab 'Logs'

        Your sessions are ready!
```

**Result:** Complete dev environment. All services running in parallel.

### Microservices Development

**Scenario:** Start 5 microservices

```
You: /tribble:spawn start auth service, user service, order service, payment service, and notification service

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
You: /tribble:spawn open claude in ~/project-a to fix API and another in ~/project-b to update tests

Claude: ✓ Created tab 'Fix API' (project-a)
        ✓ Created tab 'Update Tests' (project-b)

        Your sessions are ready!
```

**Result:** Two Claude sessions in different directories.

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
