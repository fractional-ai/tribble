# Pasta Maker Examples

Examples of using Pasta Maker to parallelize tasks across terminal tabs.

## Table of Contents

- [Development Workflows](#development-workflows)
- [Testing & CI/CD](#testing--cicd)
- [Data Processing](#data-processing)
- [Multi-Service Applications](#multi-service-applications)
- [Code Maintenance](#code-maintenance)
- [Documentation & Content](#documentation--content)

## Development Workflows

### Parallel Development Servers

**Scenario:** Start frontend, backend, and database simultaneously

```
You: /pasta-maker:run

Claude: What tasks would you like to accomplish?

You: Start my development environment with frontend, backend, and database

Claude: What commands should I run for each?

You: npm run dev
     npm run api:dev
     docker-compose up postgres

Claude: What directory?

You: /Users/me/projects/myapp

Claude: EXECUTION PLAN
        Group 1 (Parallel - 3 tabs):
          - Frontend Dev Server (npm run dev)
          - Backend API Server (npm run api:dev)
          - PostgreSQL Database (docker-compose up postgres)

        All services will start simultaneously.
        Proceed? (yes/no)

You: yes

Claude: ✓ Tab 'Frontend Dev Server' created
        ✓ Tab 'Backend API Server' created
        ✓ Tab 'PostgreSQL Database' created
```

**Result:** Three tabs open, all servers running in parallel.

---

### Full-Stack Dev Environment

**Scenario:** Complete development setup with monitoring

```
Tasks:
- Frontend (port 3000): npm run dev
- Backend API (port 4000): npm run api:dev
- Database: docker-compose up postgres
- Redis cache: docker-compose up redis
- Log viewer: tail -f logs/app.log

From: ~/projects/fullstack-app
```

**Result:** Five parallel tabs, complete dev environment ready in seconds.

---

## Testing & CI/CD

### Parallel Test Suites

**Scenario:** Run multiple test suites simultaneously

```
You: /pasta-maker:run

You: Run frontend tests, backend tests, and end-to-end tests in parallel

Commands:
- npm run test:frontend
- npm run test:backend
- npm run test:e2e

From: /Users/me/projects/myapp
```

**Result:** All test suites run in parallel, saving ~15 minutes compared to sequential execution.

---

### CI Pipeline Locally

**Scenario:** Replicate CI pipeline with parallel stages

```
Tasks:
- Lint JavaScript: npm run lint:js
- Lint CSS: npm run lint:css
- Type check: npm run type-check
- Run unit tests: npm test
Then: Build production: npm run build
Then: Run smoke tests: npm run test:smoke

From: ~/projects/webapp
```

**Execution Plan:**
```
Group 1 (Parallel): Linting, type checking, unit tests
Group 2 (Sequential): Production build
Group 3 (Sequential): Smoke tests on build
```

**Time Savings:** ~20 minutes (parallel checks) vs ~35 minutes (sequential)

---

### Test Multiple Node Versions

**Scenario:** Test package against multiple Node versions

```
Tasks:
- Test Node 18: nvm use 18 && npm test
- Test Node 20: nvm use 20 && npm test
- Test Node 22: nvm use 22 && npm test

From: ~/projects/my-package
```

**Result:** All versions tested in parallel, compatibility verified quickly.

---

## Data Processing

### Parallel Dataset Processing

**Scenario:** Process multiple datasets independently

```
You: I need to process three datasets in parallel, then merge the results

Tasks:
- Process dataset A: python scripts/process.py data/dataset_a.csv output/a.json
- Process dataset B: python scripts/process.py data/dataset_b.csv output/b.json
- Process dataset C: python scripts/process.py data/dataset_c.csv output/c.json
Then: Merge results: python scripts/merge.py output/*.json final_report.json

From: ~/projects/data-pipeline
```

**Result:** Three datasets process simultaneously, merge runs when all complete.

---

### ETL Pipeline

**Scenario:** Extract, transform, and load data

```
Tasks:
- Extract from API 1: python extract_api1.py
- Extract from API 2: python extract_api2.py
- Extract from database: python extract_db.py
Then: Transform data: python transform.py
Then: Load to warehouse: python load.py

From: ~/etl-pipeline
```

**Execution:** Parallel extraction → Sequential transformation → Sequential loading

---

### Image Processing

**Scenario:** Batch process images in parallel batches

```
Tasks:
- Process batch 1: python process.py images/batch1/*.jpg --output processed/batch1
- Process batch 2: python process.py images/batch2/*.jpg --output processed/batch2
- Process batch 3: python process.py images/batch3/*.jpg --output processed/batch3
- Process batch 4: python process.py images/batch4/*.jpg --output processed/batch4

From: ~/projects/image-processor
```

**Result:** Four parallel processors, utilizing all CPU cores efficiently.

---

## Multi-Service Applications

### Microservices Development

**Scenario:** Run entire microservices architecture locally

```
Tasks:
- User service: cd services/users && npm run dev
- Auth service: cd services/auth && npm run dev
- Payment service: cd services/payments && npm run dev
- Notification service: cd services/notifications && npm run dev
- API Gateway: cd gateway && npm run dev
- Frontend: cd frontend && npm run dev

From: ~/projects/microservices-app
```

**Result:** All services running in parallel, full architecture available locally.

---

### Docker Compose Multi-Environment

**Scenario:** Run multiple isolated environments

```
Tasks:
- Dev environment: docker-compose -f docker-compose.dev.yml up
- Staging environment: docker-compose -f docker-compose.staging.yml up
- Testing environment: docker-compose -f docker-compose.test.yml up

From: ~/projects/multi-env-app
```

**Result:** Three complete environments running simultaneously for testing.

---

## Code Maintenance

### Refactoring with Tests

**Scenario:** Make changes and continuously run tests

```
You: I want to refactor component A while watching tests

Tasks:
- Edit component A: claude
  Prompt: "Refactor src/components/UserProfile.tsx to use hooks"
- Watch tests: npm run test:watch -- UserProfile

From: ~/projects/react-app
```

**Result:** Claude helps refactor in one tab, tests auto-run in another.

---

### Multi-File Updates

**Scenario:** Update multiple files in parallel

```
Tasks:
- Update README: claude
  Prompt: "Update README.md with new API endpoints"
- Update API docs: claude
  Prompt: "Update docs/API.md with authentication examples"
- Update changelog: claude
  Prompt: "Add changelog entries for v2.0.0"

From: ~/projects/api-server
```

**Result:** Three documentation updates happening simultaneously with Claude's help.

---

### Code Quality Checks

**Scenario:** Run all quality checks in parallel

```
Tasks:
- Run ESLint: npm run lint
- Run Prettier check: npm run format:check
- Run TypeScript check: npm run type-check
- Check bundle size: npm run analyze
- Security audit: npm audit
- Check dependencies: npm run deps:check

From: ~/projects/webapp
```

**Result:** Complete quality audit in parallel, identify all issues at once.

---

## Documentation & Content

### Multi-Language Documentation

**Scenario:** Generate documentation in multiple languages

```
Tasks:
- English docs: npm run docs:build:en
- Spanish docs: npm run docs:build:es
- French docs: npm run docs:build:fr
- German docs: npm run docs:build:de

From: ~/projects/international-docs
```

**Result:** All language versions build in parallel.

---

### Content Generation

**Scenario:** Generate multiple content pieces with Claude

```
Tasks:
- Write blog post: claude
  Prompt: "Write blog post about new feature X"
- Create tutorial: claude
  Prompt: "Create step-by-step tutorial for feature Y"
- Update FAQ: claude
  Prompt: "Add 5 new FAQ entries based on recent support tickets"

From: ~/projects/website-content
```

**Result:** Multiple content pieces being drafted simultaneously.

---

## Advanced Patterns

### Staged Deployment

**Scenario:** Deploy to multiple environments sequentially

```
Tasks:
- Deploy to dev: ./deploy.sh dev
Then: Run smoke tests on dev: npm run test:smoke:dev
Then: Deploy to staging: ./deploy.sh staging
Then: Run smoke tests on staging: npm run test:smoke:staging
Then: Deploy to production: ./deploy.sh production

From: ~/projects/webapp
```

**Execution:** Sequential deployment with validation at each stage.

---

### Parallel Builds with Tests

**Scenario:** Build multiple targets and test each

```
Tasks:
- Build Linux binary: GOOS=linux go build -o dist/app-linux
- Build macOS binary: GOOS=darwin go build -o dist/app-darwin
- Build Windows binary: GOOS=windows go build -o dist/app-windows.exe
Then (for each): Run integration tests

From: ~/projects/go-app
```

**Result:** All platform builds happen in parallel, then each is tested.

---

### Database Operations

**Scenario:** Parallel database migrations and seeding

```
Tasks:
- Run migrations: npm run migrate
Then: Seed users: npm run seed:users
Then: Seed products: npm run seed:products
Then: Seed orders: npm run seed:orders

From: ~/projects/e-commerce-db
```

**Execution:** Sequential operations respecting database constraints.

---

## Tips for Effective Use

### Describing Dependencies

Use clear language to indicate task relationships:
- **Parallel:** "Run X, Y, and Z"
- **Sequential:** "Run X, then Y, then Z"
- **Mixed:** "Run X and Y in parallel, then Z after both complete"

### Resource Management

Consider system resources when parallelizing:
- **Light tasks** (linting, testing): 10+ parallel is fine
- **Medium tasks** (compilation): 4-6 parallel recommended
- **Heavy tasks** (large builds, video processing): 2-3 parallel max

### Task Monitoring

Best practices for monitoring parallel tasks:
1. Use descriptive tab names
2. Check critical tasks first (tests before builds)
3. Keep original coordination tab open
4. Report back to Claude when groups complete

### Error Handling

When tasks fail in parallel:
1. Note which tasks failed
2. Check error messages
3. Decide if remaining tasks should continue
4. Ask Claude for help diagnosing issues

## Getting Started

Try these starter examples to learn Pasta Maker:

1. **Simple parallel:** Two independent scripts
2. **Sequential:** Build then deploy
3. **Mixed:** Parallel tests, then build
4. **Interactive:** Claude tasks with monitoring

Run `/pasta-maker:run` and experiment with your own workflows!
