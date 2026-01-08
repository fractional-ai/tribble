# Task Dependency Analysis Methodology

This document provides a structured approach for analyzing task dependencies to determine which tasks can run in parallel and which must run sequentially.

## Core Principles

**Independence = Parallelization Opportunity**
Tasks can run in parallel if they don't interfere with each other.

**Dependencies = Sequential Execution Required**
If Task B depends on Task A, then A must complete before B starts.

## Dependency Detection Rules

### Strong Dependencies (Must Be Sequential)

#### 1. Data Flow Dependencies
Task B reads files, data, or artifacts produced by Task A.

**Examples:**
- Task A: Build application → Task B: Deploy application (needs build artifacts)
- Task A: Generate report data → Task B: Create charts from data
- Task A: Transpile TypeScript → Task B: Bundle JavaScript

**Detection:** Does B need A's output to function?

#### 2. State Dependencies
Task B requires environment state, database state, or system configuration set up by Task A.

**Examples:**
- Task A: Start database → Task B: Run migrations
- Task A: Install dependencies → Task B: Run application
- Task A: Set environment variables → Task B: Run tests

**Detection:** Does B need A to set something up first?

#### 3. Validation Dependencies
Task B verifies or validates Task A's work.

**Examples:**
- Task A: Write code → Task B: Run tests for that code
- Task A: Run unit tests → Task B: Run integration tests (if integration needs unit success first)
- Task A: Make changes → Task B: Run linter/formatter

**Detection:** Is B checking A's work?

#### 4. File Contention
Both tasks modify the same files, causing race conditions or conflicts.

**Examples:**
- Task A: Format all .js files → Task B: Refactor .js files
- Task A: Update package.json → Task B: Update package.json
- Task A: Git commit changes → Task B: Git commit changes

**Detection:** Do both write to the same files?

#### 5. Resource Contention
Tasks compete for the same limited resources.

**Examples:**
- Both bind to port 3000
- Both write to the same database
- Both use 100% CPU (may want to serialize for performance)
- Both lock the same files

**Detection:** Do they use the same exclusive resources?

### Independence Indicators (Can Parallelize)

#### 1. Separate File Sets
Tasks operate on completely different files or directories.

**Examples:**
- Task A: Test frontend (src/frontend/*) ✓ Task B: Test backend (src/backend/*)
- Task A: Update README.md ✓ Task B: Update LICENSE
- Task A: Process dataset-1.csv ✓ Task B: Process dataset-2.csv

**Detection:** No file overlap = likely independent

#### 2. Read-Only Operations
Both tasks only read files, never write.

**Examples:**
- Task A: Analyze code complexity ✓ Task B: Generate documentation
- Task A: Search for patterns ✓ Task B: Count lines of code
- Task A: Run linter in check mode ✓ Task B: Run type checker

**Detection:** If neither writes, no conflicts

#### 3. Different Resource Domains
Tasks use completely different resources.

**Examples:**
- Task A: Local file operations ✓ Task B: API calls to external service
- Task A: CPU-intensive computation ✓ Task B: Network I/O operation
- Task A: Run frontend on port 3000 ✓ Task B: Run backend on port 4000

**Detection:** No shared resources = independent

#### 4. Independent Workflows
Tasks are completely unrelated with no logical connection.

**Examples:**
- Task A: Run tests ✓ Task B: Update documentation
- Task A: Build frontend ✓ Task B: Process logs
- Task A: Backup database ✓ Task B: Send email notifications

**Detection:** No logical dependency between them

## Analysis Process

Follow these steps for each pair of tasks (A, B):

### Step 1: Identify Resources

For each task, list:
- **Files accessed:** Which files does it read? Which does it write?
- **External resources:** Databases, APIs, network ports, etc.
- **Environment state:** Does it need specific env vars, installed packages, etc.?
- **System resources:** CPU, memory, disk I/O patterns

### Step 2: Check Data Flow

Ask:
- Does B need data/files produced by A?
- Does A need data/files produced by B?
- Do they produce data for a third task C?

**If yes to first two:** They have a dependency
**If yes to third only:** They can run in parallel (both feed into C)

### Step 3: Check File Conflicts

Ask:
- Do they both write to the same files?
- Do they write to overlapping directories?
- Do they modify shared configuration?

**If yes:** Must serialize (or resolve conflict)

### Step 4: Check Resource Conflicts

Ask:
- Do they use the same network port?
- Do they access the same database with writes?
- Do they compete for limited resources?

**If yes:** Consider sequential or resource management

### Step 5: Determine Relationship

Based on the above, classify as:
- **Independent:** Can run in parallel
- **A → B:** B depends on A (A must complete first)
- **B → A:** A depends on B (B must complete first)
- **Conflicting:** Must serialize (order may not matter, just prevent overlap)

## Output Format

Produce a structured dependency graph:

```
TASK ANALYSIS
=============

Tasks:
1. [Task Name] - [Description]
   Command: [command]
   Directory: [path]
   Resources:
     - Files: [list of files/patterns]
     - Ports: [list of ports]
     - Other: [databases, etc.]
   Dependencies: [none | depends on Task X, Y]

2. [Task Name] - [Description]
   Command: [command]
   Directory: [path]
   Resources:
     - Files: [list]
     - Ports: [list]
     - Other: [list]
   Dependencies: [none | depends on Task X]

3. [Task Name] - [Description]
   Command: [command]
   Directory: [path]
   Resources:
     - Files: [list]
     - Ports: [list]
     - Other: [list]
   Dependencies: [none | depends on Task X, Y]

DEPENDENCY GRAPH
================

Edges (A → B means "B depends on A"):
- Task 1 → Task 3 (data flow: Task 3 needs Task 1's output)
- Task 2 → Task 3 (validation: Task 3 validates Task 2)

PARALLEL EXECUTION GROUPS
==========================

Group 1 (Parallel - No conflicts, independent):
- Task 1: [name]
- Task 2: [name]

Group 2 (Sequential - After Group 1):
- Task 3: [name]
  Waits for: Task 1, Task 2
```

## Common Patterns

### Test Suites

```
✓ Unit tests + Integration tests (parallel if separate databases/no shared state)
✓ Frontend tests + Backend tests (parallel if independent codebases)
✓ Test suite A + Test suite B (parallel if no shared resources)

✗ Write code → Run tests (sequential: tests validate code)
✗ Unit tests → Integration tests (sequential if integration requires unit success)
```

### Build Pipelines

```
✓ Lint + Test (parallel if both read-only or operate on different outputs)
✓ Build frontend + Build backend (parallel if separate output dirs)
✓ Build + Generate docs (parallel if docs don't need build artifacts)

✗ Install deps → Build (sequential: build needs deps)
✗ Build → Deploy (sequential: deploy needs build artifacts)
✗ Lint → Test → Build → Deploy (sequential chain)

Optimized: (Lint + Test) parallel → Build → Deploy
```

### Development Servers

```
✓ Frontend dev server (port 3000) + Backend dev server (port 4000) (parallel: different ports)
✓ API server + Database (parallel if DB already running, or sequential if DB needs starting first)
✓ App server + Docs server + Test watcher (all parallel if different ports)

✗ Start server + Start server (conflicting if same port)
```

### Code Modifications

```
✓ Fix bug in file A + Refactor file B (parallel if no shared dependencies)
✓ Update README + Update LICENSE (parallel: different files)
✓ Add feature X + Add feature Y (parallel if different files/modules)

✗ Refactor file A + Update tests for file A (sequential: tests need refactor done)
✗ Format code + Refactor code (conflicting: both modify same files)
```

### Data Processing

```
✓ Process dataset-1 + Process dataset-2 + Process dataset-3 (all parallel if independent)
✓ Download file A + Download file B (parallel: different files)

✗ Download file → Process file (sequential: processing needs download done)
✗ Process A + Process B → Merge A & B (parallel then sequential)
✗ Process file → Upload results (sequential: upload needs processing done)
```

### Documentation and Chores

```
✓ Update docs + Run tests (parallel: completely unrelated)
✓ Update README + Update CHANGELOG (parallel: different files)
✓ Generate API docs + Generate user guide (parallel if independent)

✗ Build project → Generate docs (sequential if docs need built artifacts)
```

## Decision Tree

Use this tree to quickly determine relationships:

```
START
  ↓
Does Task B need Task A's files/output?
  YES → Sequential (A before B)
  NO → Continue
  ↓
Does Task A need Task B's files/output?
  YES → Sequential (B before A)
  NO → Continue
  ↓
Do they both write to the same files?
  YES → Conflicting (must serialize)
  NO → Continue
  ↓
Do they share exclusive resources (same port, same DB writes, same locks)?
  YES → Conflicting or Sequential (manage resources)
  NO → Continue
  ↓
Are they CPU/memory intensive enough to cause problems running together?
  YES → Consider sequential for performance (optional)
  NO → Continue
  ↓
✓ PARALLEL SAFE - They can run simultaneously
```

## Special Considerations

### Claude Code Instances
When tasks involve Claude helping with work (not just running commands), they can typically run in parallel with command-based tasks since the human is the bottleneck, not the system resources.

Example:
```
✓ Task A: npm test (command) + Task B: "Help me write docs" (Claude)
✓ Task A: "Refactor component A" (Claude) + Task B: "Refactor component B" (Claude)
```

### Long-Running Servers
Development servers that run indefinitely can all be parallel since they don't "complete" - they just run.

Example:
```
✓ Frontend dev server + Backend API + Database + Docs server (all parallel, all long-running)
```

### Interactive Tasks
Tasks requiring human input can run in parallel since the human will switch between tabs as needed.

Example:
```
✓ Task A: Configure settings (interactive) + Task B: Run tests (automated)
```

## Example Analysis

**User's tasks:**
1. Run frontend tests: `npm run test:frontend`
2. Run backend tests: `npm run test:backend`
3. Build the project: `npm run build`
4. Update documentation: Claude helps update README

**Analysis:**

```
TASK ANALYSIS
=============

Tasks:
1. Frontend Tests - Run Jest tests for React components
   Command: npm run test:frontend
   Directory: /Users/me/project
   Resources:
     - Files: src/frontend/** (read), test-results/frontend.xml (write)
     - Ports: none
     - Other: none
   Dependencies: none

2. Backend Tests - Run Jest tests for API endpoints
   Command: npm run test:backend
   Directory: /Users/me/project
   Resources:
     - Files: src/backend/** (read), test-results/backend.xml (write)
     - Ports: none (uses test DB on different port)
     - Other: test database
   Dependencies: none

3. Build Project - Webpack production build
   Command: npm run build
   Directory: /Users/me/project
   Resources:
     - Files: src/** (read), dist/** (write)
     - Ports: none
     - Other: none
   Dependencies: Frontend Tests (should pass first), Backend Tests (should pass first)

4. Update Documentation - Claude helps update README.md
   Command: claude
   Directory: /Users/me/project
   Resources:
     - Files: README.md (write)
     - Ports: none
     - Other: Human interaction required
   Dependencies: none (can work on docs anytime)

DEPENDENCY GRAPH
================

Edges:
- Task 1 → Task 3 (validation: build should wait for tests to pass)
- Task 2 → Task 3 (validation: build should wait for tests to pass)

PARALLEL EXECUTION GROUPS
==========================

Group 1 (Parallel - 3 tasks):
- Task 1: Frontend Tests
- Task 2: Backend Tests
- Task 4: Update Documentation
  (All independent, different files/resources)

Group 2 (Sequential - After Group 1):
- Task 3: Build Project
  Waits for: Frontend Tests, Backend Tests
  (Should verify tests passed before building)

Time Savings:
- Sequential: ~22 min (5 + 5 + 10 + 2)
- Parallel: ~12 min (max(5,5,2) + 10) = 5 + 10 = 15 min, but docs can continue during build
- Savings: ~7-10 minutes
```

## Tips for Accurate Analysis

1. **Ask clarifying questions** - If you're unsure about resources or dependencies, ask the user
2. **Be conservative** - When in doubt, err on the side of safety (sequential)
3. **Consider failure impact** - If Task A fails, should B still run?
4. **Think about human workflow** - Sometimes users want sequential for workflow reasons even if technically parallel is possible
5. **Check project-specific patterns** - Some projects have conventions (e.g., always lint before test)

## When to Ask the User

Ask for clarification when:
- Resource usage is unclear (e.g., "Does this use a database?")
- Logical dependencies are ambiguous (e.g., "Should tests pass before building?")
- File overlap is uncertain (e.g., "Do these both modify config files?")
- Performance impact is unknown (e.g., "Are these both CPU-intensive?")
