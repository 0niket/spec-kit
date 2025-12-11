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

7. **Add repetitive tasks** to each commit based on constitution:
   - If TDD enabled: Add TDD-RED, TDD-GREEN, TDD-REFACTOR tasks
   - If linting enabled: Add appropriate LINT tasks based on file types in commit
   - Always add VERIFY task (make check) at end

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

For each commit, add repetitive tasks based on constitution requirements:

**If constitution has TDD requirements**:

```markdown
### Repetitive Tasks

- [ ] [TDD-RED] Write failing test for [primary component in commit]
- [ ] [TDD-GREEN] Implement [primary component] to pass test
- [ ] [TDD-REFACTOR] Refactor [primary component] while tests pass
- [ ] [VERIFY] Run make check
```

**If commit contains .sh files and shellcheck required**:

```markdown
- [ ] [LINT-BASH] Run shellcheck on modified bash scripts
```

**If commit contains .py files and ruff required**:

```markdown
- [ ] [LINT-PYTHON] Run ruff check on modified Python files
```

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
