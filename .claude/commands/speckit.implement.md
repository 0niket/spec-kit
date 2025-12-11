---
description: Execute the implementation plan by processing and executing all tasks defined in tasks.md
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks --include-commits --include-milestones` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

   **Document Loading Behavior**:
   - **Required**: tasks.md (always required)
   - **Optional but Recommended**: commits.md (for commit-by-commit execution)
   - **Optional but Recommended**: milestones.md (for milestone pause and verification)

   **If commits.md exists**:
   - Execute tasks grouped by commit boundaries (not flat list)
   - Create git commits at each commit boundary with planned messages

   **If milestones.md exists**:
   - Pause at milestone boundaries for manual verification
   - Track verification status (pending → verification_required → verified/rejected)

   **If neither exists**:
   - Fall back to legacy flat task execution (phase-by-phase)
   - Show warning: "For better execution control, run /speckit.commits and /speckit.milestones first"

2. **Check checklists status** (if FEATURE_DIR/checklists/ exists):
   - Scan all checklist files in the checklists/ directory
   - For each checklist, count:
     - Total items: All lines matching `- [ ]` or `- [X]` or `- [x]`
     - Completed items: Lines matching `- [X]` or `- [x]`
     - Incomplete items: Lines matching `- [ ]`
   - Create a status table:

     ```text
     | Checklist | Total | Completed | Incomplete | Status |
     |-----------|-------|-----------|------------|--------|
     | ux.md     | 12    | 12        | 0          | ✓ PASS |
     | test.md   | 8     | 5         | 3          | ✗ FAIL |
     | security.md | 6   | 6         | 0          | ✓ PASS |
     ```

   - Calculate overall status:
     - **PASS**: All checklists have 0 incomplete items
     - **FAIL**: One or more checklists have incomplete items

   - **If any checklist is incomplete**:
     - Display the table with incomplete item counts
     - **STOP** and ask: "Some checklists are incomplete. Do you want to proceed with implementation anyway? (yes/no)"
     - Wait for user response before continuing
     - If user says "no" or "wait" or "stop", halt execution
     - If user says "yes" or "proceed" or "continue", proceed to step 3

   - **If all checklists are complete**:
     - Display the table showing all checklists passed
     - Automatically proceed to step 3

3. Load and analyze the implementation context:
   - **REQUIRED**: Read tasks.md for the complete task list and execution plan
   - **REQUIRED**: Read plan.md for tech stack, architecture, and file structure
   - **IF EXISTS**: Read data-model.md for entities and relationships
   - **IF EXISTS**: Read contracts/ for API specifications and test requirements
   - **IF EXISTS**: Read research.md for technical decisions and constraints
   - **IF EXISTS**: Read quickstart.md for integration scenarios

4. **Project Setup Verification**:
   - **REQUIRED**: Create/verify ignore files based on actual project setup:

   **Detection & Creation Logic**:
   - Check if the following command succeeds to determine if the repository is a git repo (create/verify .gitignore if so):

     ```sh
     git rev-parse --git-dir 2>/dev/null
     ```

   - Check if Dockerfile* exists or Docker in plan.md → create/verify .dockerignore
   - Check if .eslintrc* exists → create/verify .eslintignore
   - Check if eslint.config.* exists → ensure the config's `ignores` entries cover required patterns
   - Check if .prettierrc* exists → create/verify .prettierignore
   - Check if .npmrc or package.json exists → create/verify .npmignore (if publishing)
   - Check if terraform files (*.tf) exist → create/verify .terraformignore
   - Check if .helmignore needed (helm charts present) → create/verify .helmignore

   **If ignore file already exists**: Verify it contains essential patterns, append missing critical patterns only
   **If ignore file missing**: Create with full pattern set for detected technology

   **Common Patterns by Technology** (from plan.md tech stack):
   - **Node.js/JavaScript/TypeScript**: `node_modules/`, `dist/`, `build/`, `*.log`, `.env*`
   - **Python**: `__pycache__/`, `*.pyc`, `.venv/`, `venv/`, `dist/`, `*.egg-info/`
   - **Java**: `target/`, `*.class`, `*.jar`, `.gradle/`, `build/`
   - **C#/.NET**: `bin/`, `obj/`, `*.user`, `*.suo`, `packages/`
   - **Go**: `*.exe`, `*.test`, `vendor/`, `*.out`
   - **Ruby**: `.bundle/`, `log/`, `tmp/`, `*.gem`, `vendor/bundle/`
   - **PHP**: `vendor/`, `*.log`, `*.cache`, `*.env`
   - **Rust**: `target/`, `debug/`, `release/`, `*.rs.bk`, `*.rlib`, `*.prof*`, `.idea/`, `*.log`, `.env*`
   - **Kotlin**: `build/`, `out/`, `.gradle/`, `.idea/`, `*.class`, `*.jar`, `*.iml`, `*.log`, `.env*`
   - **C++**: `build/`, `bin/`, `obj/`, `out/`, `*.o`, `*.so`, `*.a`, `*.exe`, `*.dll`, `.idea/`, `*.log`, `.env*`
   - **C**: `build/`, `bin/`, `obj/`, `out/`, `*.o`, `*.a`, `*.so`, `*.exe`, `Makefile`, `config.log`, `.idea/`, `*.log`, `.env*`
   - **Swift**: `.build/`, `DerivedData/`, `*.swiftpm/`, `Packages/`
   - **R**: `.Rproj.user/`, `.Rhistory`, `.RData`, `.Ruserdata`, `*.Rproj`, `packrat/`, `renv/`
   - **Universal**: `.DS_Store`, `Thumbs.db`, `*.tmp`, `*.swp`, `.vscode/`, `.idea/`

   **Tool-Specific Patterns**:
   - **Docker**: `node_modules/`, `.git/`, `Dockerfile*`, `.dockerignore`, `*.log*`, `.env*`, `coverage/`
   - **ESLint**: `node_modules/`, `dist/`, `build/`, `coverage/`, `*.min.js`
   - **Prettier**: `node_modules/`, `dist/`, `build/`, `coverage/`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
   - **Terraform**: `.terraform/`, `*.tfstate*`, `*.tfvars`, `.terraform.lock.hcl`
   - **Kubernetes/k8s**: `*.secret.yaml`, `secrets/`, `.kube/`, `kubeconfig*`, `*.key`, `*.crt`

5. Parse tasks.md structure and extract:
   - **Task phases**: Setup, Tests, Core, Integration, Polish
   - **Task dependencies**: Sequential vs parallel execution rules
   - **Task details**: ID, description, file paths, parallel markers [P]
   - **Execution flow**: Order and dependency requirements

6. **Commit-by-Commit Execution** (if commits.md exists):

   **Execution Flow**:

   ```text
   For each commit in commits.md (in order):
     1. Display commit info: ID, message, tasks count
     2. Execute all Non-Repetitive Tasks in commit
     3. Execute all Repetitive Tasks in commit (TDD-RED, TDD-GREEN, LINT, VERIFY)
     4. If all tasks pass:
        - Create git commit with planned message from commits.md
        - Update commit status to 'completed' in commits.md
        - Check if this commit completes a milestone
     5. If any task fails:
        - STOP execution
        - Report failure with context
        - Do NOT create partial commits
   ```

   **Git Commit Creation**:

   - Use the exact conventional commit message from commits.md
   - Stage only files modified during this commit's tasks
   - Include commit ID in commit body for traceability
   - Example: `git commit -m "feat(commits): add task grouping algorithm" -m "Commit: C002"`

   **Milestone Pause and Verification** (if milestones.md exists):

   ```text
   When all commits in a milestone are completed:
     1. Update milestone status from 'pending' to 'verification_required'
     2. Display milestone verification criteria
     3. PAUSE execution and prompt user:
        "Milestone [M###] reached: [Title]
         Please verify the following criteria:
         - [ ] [V001] Given... When... Then...
         - [ ] [V002] Given... When... Then...

         Enter 'verify' to continue or 'reject' to rollback"
     4. Wait for user input:
        - If 'verify': Update status to 'verified', continue to next milestone
        - If 'reject': Update status to 'rejected', halt execution
   ```

   **Verification Status Tracking**:

   - Update milestones.md with status changes in real-time
   - Record verification timestamp in 'Verified At' field
   - Record verifier in 'Verified By' field (e.g., "user" or "automated")

   **Progress Visualization**:

   Display progress after each commit and at milestone boundaries:

   ```text
   ══════════════════════════════════════════════════════════════════
   WORKFLOW PROGRESS
   ══════════════════════════════════════════════════════════════════

   Milestone 1: Group Tasks into Commits [US1] ✓ VERIFIED
   ├── [C001] feat(templates): add commits and milestones templates ✓
   ├── [C002] feat(constitution): add constitution parser ✓
   └── [C003] feat(commits): add speckit.commits command ✓

   Milestone 2: Add Repetitive Tasks [US2] → IN PROGRESS
   ├── [C004] feat(commits): add repetitive task injection ✓
   └── [C005] test(commits): add integration tests ◯ (current)

   Milestone 3: Define Milestones [US3] ○ PENDING
   ├── [C006] feat(milestones): add speckit.milestones command
   └── [C007] test(milestones): add verification tests

   ══════════════════════════════════════════════════════════════════
   Progress: 4/7 commits (57%) | 1/3 milestones verified
   Current: [C005] test(commits): add integration tests
   Next milestone: "Add Repetitive Tasks" - 1 commit remaining
   ══════════════════════════════════════════════════════════════════
   ```

   **Status Symbols**:

   - ✓ = completed/verified
   - ○ = pending (not started)
   - ◯ = current (in progress)
   - ✗ = failed/rejected

   **Milestone Verification Status Display**:

   ```text
   ══════════════════════════════════════════════════════════════════
   MILESTONE VERIFICATION: Add Repetitive Tasks [US2]
   ══════════════════════════════════════════════════════════════════

   Status: VERIFICATION REQUIRED

   Please verify the following criteria:
   [ ] [V005] Given a constitution requiring TDD, When commits are
       generated, Then each includes RED-GREEN-REFACTOR tasks
   [ ] [V006] Given a constitution requiring linting, When commits
       are generated, Then each includes "run linter" task

   ══════════════════════════════════════════════════════════════════
   Commands: 'verify' to continue | 'reject' to halt | 'notes' to add
   ══════════════════════════════════════════════════════════════════
   ```

7. Execute implementation following the task plan (legacy mode if no commits.md):

   - **Phase-by-phase execution**: Complete each phase before moving to the next
   - **Respect dependencies**: Run sequential tasks in order, parallel tasks [P] can run together
   - **Follow TDD approach**: Execute test tasks before their corresponding implementation tasks
   - **File-based coordination**: Tasks affecting the same files must run sequentially
   - **Validation checkpoints**: Verify each phase completion before proceeding

8. Implementation execution rules:

   - **Setup first**: Initialize project structure, dependencies, configuration
   - **Tests before code**: If you need to write tests for contracts, entities, and integration scenarios
   - **Core development**: Implement models, services, CLI commands, endpoints
   - **Integration work**: Database connections, middleware, logging, external services
   - **Polish and validation**: Unit tests, performance optimization, documentation

9. Progress tracking and error handling:

   - Report progress after each completed task
   - Halt execution if any non-parallel task fails
   - For parallel tasks [P], continue with successful tasks, report failed ones
   - Provide clear error messages with context for debugging
   - Suggest next steps if implementation cannot proceed
   - **IMPORTANT** For completed tasks, make sure to mark the task off as [X] in the tasks file.

10. Completion validation:

    - Verify all required tasks are completed
    - Check that implemented features match the original specification
    - Validate that tests pass and coverage meets requirements
    - Confirm the implementation follows the technical plan
    - Report final status with summary of completed work

## Error Handling

**Missing Required Files**:

- If tasks.md is missing: STOP with error "tasks.md not found. Run /speckit.tasks first."

**Missing Optional Files** (with clear guidance):

- If commits.md is missing but milestones.md exists: WARN "commits.md not found. Run /speckit.commits first for commit boundaries."
- If milestones.md is missing but commits.md exists: WARN "milestones.md not found. Run /speckit.milestones for verification checkpoints."
- If both are missing: WARN "For structured execution with commit boundaries and verification checkpoints, run /speckit.commits then /speckit.milestones."

**Verification Rejection**:

- If user rejects a milestone verification:
  1. Record rejection in milestones.md (status: rejected)
  2. Display which verification criteria failed
  3. Suggest: "Fix the issues and re-run /speckit.implement to resume from this milestone"
  4. Do NOT rollback commits already created (they represent completed work)

Note: This command supports both legacy flat execution (tasks.md only) and structured commit-by-commit execution (with commits.md and milestones.md). For best results, run the full workflow: `/speckit.tasks` → `/speckit.commits` → `/speckit.milestones` → `/speckit.implement`.
