---
description: Group tasks into logical commits with constitution-driven repetitive tasks.
handoffs:
  - label: Create Milestones
    agent: speckit.milestones
    prompt: Group the commits into milestones with verification criteria
    send: true
  - label: Implement
    agent: speckit.implement
    prompt: Execute the implementation following commit boundaries
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. **Setup**: Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. For single quotes in args, use escape syntax.

2. **Load context**: Read from FEATURE_DIR:
   - **Required**: tasks.md (task list with IDs, stories, and file paths)
   - **Required**: spec.md (user stories for story references)
   - **Required**: `.specify/memory/constitution.md` (for repetitive tasks)
   - **Optional**: plan.md (for context on project structure)

3. **Parse constitution for repetitive tasks**: Run `.specify/scripts/bash/parse-constitution.sh` on the constitution file to get JSON output of required repetitive tasks (TDD, linting, verification).

4. **Parse tasks.md**: Extract all tasks with their:
   - Task ID (T###)
   - Priority marker [P#]
   - Story reference [US#] if present
   - Description and file path
   - Phase assignment

5. **Group tasks into commits** using semantic grouping:

   **Grouping Algorithm** (in priority order):
   1. Tasks with same [Story] tag → same commit
   2. Tasks referencing same file → same commit
   3. Tasks in same phase without story tag → same commit (for Setup/Foundational phases)
   4. Override: Tasks in Setup/Foundational phases without [Story] tag → group by logical unit

   **Rules**:
   - Each commit should represent a logical, atomic unit of work
   - Commits should be independently testable where possible
   - Maximum ~5-7 non-repetitive tasks per commit (split if larger)

6. **Generate commit messages** for each group:
   - Use conventional commit format: `type(scope): description`
   - Types: feat, fix, test, refactor, docs, chore
   - Scope: derived from primary file path or component
   - Description: summarizes what the commit achieves

7. **Add repetitive tasks** to each commit based on constitution requirements:

   **CRITICAL**: The constitution is the source of truth. Use `parse-constitution.sh` output to determine which repetitive tasks to add.

   **Common repetitive task types** (only if constitution requires them):
   - **TDD workflow**: TDD-RED, TDD-GREEN, TDD-REFACTOR (only if constitution mentions TDD/Red-Green-Refactor)
   - **Linting**: LINT-BASH, LINT-PYTHON, LINT-MARKDOWN (only for file types in commit where constitution requires linting)
   - **Verification**: VERIFY task (make check or similar, if constitution requires passing checks before commit)
   - **Ticket updates**: POST-TICKET-COMMENT (if constitution requires periodic ticket updates)
   - **Code review**: REQUEST-REVIEW (if constitution mandates peer review checkpoints)
   - **Documentation**: UPDATE-DOCS (if constitution requires doc updates per commit)
   - **Security scans**: RUN-SECURITY-SCAN (if constitution mandates security checks)
   - **Performance tests**: RUN-PERF-TESTS (if constitution requires performance validation)

   **Important rules**:
   - ONLY add repetitive tasks that are explicitly or implicitly required by the constitution
   - DO NOT assume standard practices - read what the constitution actually says
   - Some tasks repeat multiple times per commit (e.g., TDD cycle for each component)
   - Some tasks happen once per commit (e.g., final VERIFY before commit)
   - Repetitive tasks ensure quality gates defined in constitution are enforced at every commit

8. **Generate commits.md** following the format in `contracts/commits-format.md`:
   - Header with metadata (Generated timestamp, Source paths)
   - Summary with counts
   - Each commit section with:
     - Conventional commit message as heading
     - ID, Status (pending), Story reference
     - Non-Repetitive Tasks (from tasks.md)
     - Repetitive Tasks (from constitution)

9. **Write output**: Save commits.md to FEATURE_DIR

10. **Report**: Output path to generated commits.md and summary:
    - Total commits generated
    - Tasks per commit breakdown
    - Stories covered
    - Repetitive tasks added

## Grouping Examples

### Example 1: Story-based grouping

```text
Input tasks:
- [ ] T010 [US1] Create speckit.commits.md `.claude/commands/speckit.commits.md`
- [ ] T011 [US1] Implement task parsing logic `.claude/commands/speckit.commits.md`
- [ ] T012 [US1] Implement grouping algorithm `.claude/commands/speckit.commits.md`

Output: Single commit for US1
## Commit 1: feat(commits): add speckit.commits slash command

**Story**: US1
### Non-Repetitive Tasks
- [ ] T010 [US1] Create speckit.commits.md
- [ ] T011 [US1] Implement task parsing logic
- [ ] T012 [US1] Implement grouping algorithm
```

### Example 2: File-based grouping (no story tag)

```text
Input tasks:
- [ ] T001 Create commits-template.md `.specify/templates/commits-template.md`
- [ ] T002 Create milestones-template.md `.specify/templates/milestones-template.md`

Output: Single commit (same directory/purpose)
## Commit 1: feat(templates): add commits and milestones templates
```

### Example 3: Phase-based grouping

```text
Input tasks (Foundational phase):
- [ ] T003 Write bats test for parse-constitution.sh
- [ ] T004 Create parse-constitution.sh script

Output: Single commit (related test + implementation)
## Commit 1: feat(constitution): add constitution parser with tests
```

## Repetitive Task Injection

**CONSTITUTION DRIVES EVERYTHING**: First run `parse-constitution.sh` to get JSON output of required repetitive tasks. Only add what the constitution specifies.

### Example 1: Constitution with TDD + Linting Requirements

**Constitution says**: "All code changes MUST follow Red-Green-Refactor TDD cycle. All bash scripts MUST pass shellcheck before commit."

**Resulting repetitive tasks for a commit with bash files**:

```markdown
### Repetitive Tasks

- [ ] [TDD-RED] Write failing test for [primary component in commit]
- [ ] [TDD-GREEN] Implement [primary component] to pass test
- [ ] [TDD-REFACTOR] Refactor [primary component] while tests pass
- [ ] [LINT-BASH] Run shellcheck on modified bash scripts
- [ ] [VERIFY] Run make check
```

### Example 2: Constitution with Ticket Update Requirements

**Constitution says**: "Developers MUST post progress comment on tracking ticket after completing each commit. All commits MUST pass make check before committing."

**Resulting repetitive tasks**:

```markdown
### Repetitive Tasks

- [ ] [POST-TICKET-COMMENT] Post progress update to ticket PROJECT-123
- [ ] [VERIFY] Run make check
```

### Example 3: Constitution with NO TDD Requirement

**Constitution says**: "Code MUST pass linting checks. No testing requirements specified."

**Resulting repetitive tasks for commit with Python files** (NO TDD tasks):

```markdown
### Repetitive Tasks

- [ ] [LINT-PYTHON] Run ruff check on modified Python files
- [ ] [VERIFY] Run make check
```

### Example 4: Minimal Constitution

**Constitution says**: "Ship fast, iterate quickly. No formal process required."

**Resulting repetitive tasks** (NONE - constitution doesn't require any):

```markdown
### Repetitive Tasks

(No repetitive tasks - constitution does not mandate any quality gates)
```

**Key principle**: If the constitution doesn't mention a practice, don't add tasks for it. The constitution is law.

## Output Format

Follow the exact format specified in `contracts/commits-format.md`.

## Key Rules

- Use absolute paths
- Every task ID from tasks.md must appear in exactly one commit
- Commits must be ordered by dependency (Setup → Foundational → User Stories → Polish)
- Validate that all [Story] references exist in spec.md
- Report orphaned tasks (tasks not assigned to any commit) as warnings

## Usage Examples

**Basic usage** (groups all tasks in current feature):

```text
/speckit.commits
```

**With specific instructions**:

```text
/speckit.commits Split the authentication tasks into smaller commits for easier review
```

**After updating tasks**:

```text
/speckit.commits Regenerate commits to include the new validation tasks
```

**Workflow**:

```text
1. /speckit.tasks         → Creates tasks.md
2. /speckit.commits       → Creates commits.md (this command)
3. /speckit.milestones    → Creates milestones.md
4. /speckit.implement     → Executes with commit boundaries
```
