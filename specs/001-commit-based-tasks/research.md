# Research: Diverge-Converge Workflow

**Feature**: 001-commit-based-tasks
**Date**: 2025-12-11

## Decision 1: Task Grouping Algorithm

### Decision

Use **semantic grouping** based on task relationships and file paths to group tasks into commits. Tasks that operate on the same entity, module, or feature component are grouped together.

### Rationale

- Tasks in `tasks.md` already have file path hints (e.g., `src/models/user.py`)
- Tasks referencing the same file or directory naturally belong together
- User stories in specs provide natural grouping boundaries
- This approach is deterministic and explainable to users

### Alternatives Considered

1. **Sequential grouping (N tasks per commit)**: Rejected - arbitrary boundaries ignore logical relationships
2. **Single-task commits**: Rejected - too granular, creates noise in git history
3. **AI-based semantic analysis**: Rejected - non-deterministic, harder to test and explain

### Implementation Approach

```text
Grouping Rules (in order of priority):
1. Tasks with same [Story] tag → same commit
2. Tasks referencing same file → same commit
3. Tasks in same phase/category → suggest same commit
4. Override: Tasks marked [ATOMIC] → single commit
```

## Decision 2: Constitution Parsing for Repetitive Tasks

### Decision

Parse constitution for **keyword-triggered repetitive tasks** using section headers and requirement keywords.

### Rationale

- Constitution v1.3.0 has clear section headers (e.g., "VII. Test-Driven Development")
- Keywords like "TDD", "lint", "test", "verify" indicate quality requirements
- Each principle has explicit requirements that can be mapped to tasks

### Detected Repetitive Tasks from Constitution

| Constitution Section | Trigger | Repetitive Tasks |
|---------------------|---------|------------------|
| VII. TDD | All code changes | 1. Write failing test (RED), 2. Implement (GREEN), 3. Refactor |
| I. Code Quality | Bash scripts | Run `shellcheck` |
| I. Code Quality | Python code | Run `ruff check` and `ruff format --check` |
| I. Code Quality | Markdown | Run `markdownlint-cli2` |
| III. CI/CD | Before commit | Run `make check` |

### Implementation Approach

```text
parse-constitution.sh:
  Input: .specify/memory/constitution.md
  Output: JSON array of repetitive task templates

  {
    "tdd": {
      "trigger": "code_change",
      "tasks": [
        {"order": 1, "name": "Write failing test", "phase": "RED"},
        {"order": 2, "name": "Implement feature", "phase": "GREEN"},
        {"order": 3, "name": "Refactor if needed", "phase": "REFACTOR"},
        {"order": 4, "name": "Verify tests pass", "phase": "VERIFY"}
      ]
    },
    "lint_bash": {
      "trigger": "*.sh",
      "tasks": [{"order": 99, "name": "Run shellcheck"}]
    }
  }
```

## Decision 3: Milestone Boundary Detection

### Decision

Place milestones at **user story boundaries** from the specification, with each milestone representing a complete, verifiable feature increment.

### Rationale

- User stories in specs have acceptance criteria - natural verification points
- Each story represents user-facing value that can be demonstrated
- Aligns with agile milestone concepts
- Clear mapping: 1 user story = 1 milestone (minimum)

### Alternatives Considered

1. **Time-based milestones**: Rejected - not meaningful for quality verification
2. **Commit-count milestones (every N commits)**: Rejected - arbitrary, ignores semantic boundaries
3. **File-change milestones**: Rejected - doesn't reflect user value

### Implementation Approach

```text
Milestone Generation Rules:
1. Each P1 user story → separate milestone (critical path)
2. P2/P3 stories → can be grouped into shared milestones
3. Milestones include verification criteria from story's acceptance scenarios
4. Each milestone lists its constituent commits
```

## Decision 4: Commit Message Generation

### Decision

Generate commit messages following **Conventional Commits** format with story references.

### Rationale

- Constitution already requires conventional format (`type: description`)
- Consistent with existing project standards
- Enables automated changelog generation
- Story references provide traceability

### Format Specification

```text
type(scope): description

- Task 1 completed
- Task 2 completed

Story: [Story ID from spec]
```

**Types** (from constitution):

- `feat`: New feature
- `fix`: Bug fix
- `test`: Adding tests (TDD RED phase)
- `refactor`: Code restructuring (TDD REFACTOR phase)
- `docs`: Documentation updates
- `chore`: Maintenance tasks

### Example

```text
feat(commits): add task grouping algorithm

- Implement semantic grouping based on file paths
- Add story-based task clustering
- Create commit boundary detection

Story: US1 - Group Tasks into Commits
```

## Decision 5: File Format for commits.md

### Decision

Use **hierarchical Markdown** with YAML-like metadata blocks for machine parseability.

### Rationale

- Consistent with existing Spec Kit artifacts (all Markdown)
- Human-readable and editable
- Can be parsed by both bash (grep/sed) and Claude Code
- Supports both automated generation and manual override

### Format

```markdown
# Commits: [Feature Name]

## Commit 1: [Conventional message]

**Status**: pending | in_progress | completed
**Story**: [Story reference]

### Non-Repetitive Tasks

- [ ] [T001] Task description
- [ ] [T002] Task description

### Repetitive Tasks (from Constitution)

- [ ] [TDD-RED] Write failing test for [component]
- [ ] [TDD-GREEN] Implement [component]
- [ ] [TDD-REFACTOR] Refactor [component]
- [ ] [LINT] Run make check

---

## Commit 2: [Conventional message]
...
```

## Decision 6: File Format for milestones.md

### Decision

Use **Markdown with verification checklists** derived from acceptance scenarios.

### Format

```markdown
# Milestones: [Feature Name]

## Milestone 1: [User Story Title]

**Status**: pending | verification_required | verified | rejected
**Story**: [Story reference]
**Priority**: P1 | P2 | P3

### Commits Included

1. Commit 1: [message]
2. Commit 2: [message]

### Verification Criteria

From acceptance scenarios in spec:

- [ ] Given X, When Y, Then Z (Scenario 1)
- [ ] Given A, When B, Then C (Scenario 2)

### Manual Verification Notes

[Space for reviewer comments]

---

## Milestone 2: [User Story Title]
...
```

## Summary of Decisions

| Decision | Choice | Key Rationale |
|----------|--------|---------------|
| Task grouping | Semantic (story + file-based) | Deterministic, meaningful boundaries |
| Constitution parsing | Keyword-triggered templates | Maps directly to constitution sections |
| Milestone boundaries | User story boundaries | Natural verification points |
| Commit messages | Conventional Commits + story ref | Consistent with project standards |
| commits.md format | Hierarchical Markdown | Human and machine readable |
| milestones.md format | Markdown with checklists | Verification criteria from specs |
