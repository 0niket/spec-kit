# Implementation Plan: Diverge-Converge Workflow

**Branch**: `001-commit-based-tasks` | **Date**: 2025-12-11 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-commit-based-tasks/spec.md`

## Summary

Implement the **Diverge-Converge** workflow model that extends Spec Kit's existing divergent phases (specify → plan → tasks) with convergent phases (tasks → commits → milestones). This introduces two new slash commands (`/speckit.commits` and `/speckit.milestones`) and enhances `/speckit.implement` to respect commit boundaries and pause at milestones for manual verification. Constitution-driven repetitive tasks (TDD, linting) are automatically added to each commit.

## Technical Context

**Language/Version**: Markdown (slash commands), Bash 5.x (scripts), Python 3.11+ (CLI utilities if needed)
**Primary Dependencies**: Existing Spec Kit infrastructure (check-prerequisites.sh, common.sh), Claude Code slash command system
**Storage**: Markdown files (commits.md, milestones.md) in feature specs directory
**Testing**: bats-core (Bash script tests), pytest (Python utility tests), manual slash command validation
**Target Platform**: Cross-platform (macOS, Linux, Windows via WSL/PowerShell)
**Project Type**: CLI tool extension (single project structure)
**Performance Goals**: N/A (command-line tool, not latency-sensitive)
**Constraints**: Must follow TDD workflow, `make check` must pass before commits
**Scale/Scope**: 2 new slash commands, 1 enhanced command, ~3 new scripts, ~5 new markdown artifacts

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|-----------|------|--------|
| I. Code Quality Through Linting | Bash scripts must pass `shellcheck`, Markdown must pass `markdownlint-cli2` | ✅ PASS |
| II. Test Coverage for Scripts | New bash scripts must have `bats-core` tests | ✅ PASS (will implement) |
| III. CI/CD Enforcement | `make check` must pass before any commit | ✅ PASS |
| V. Cross-Platform Parity | Bash scripts must have PowerShell equivalents | ⚠️ DEFERRED (PowerShell scripts pending) |
| VI. Documentation Maintenance | README updated with new commands | ✅ PASS (will update) |
| VII. TDD | Tests written before implementation (Red-Green-Refactor) | ✅ PASS (will follow) |
| Commit Authorship | No AI co-authors on commits | ✅ PASS |

**Gate Evaluation**: All critical gates pass. Cross-platform parity (Principle V) is deferred as PowerShell test infrastructure is marked "pending" in the constitution. New scripts will have bash implementations first, with PowerShell equivalents tracked as follow-up.

## Project Structure

### Documentation (this feature)

```text
specs/001-commit-based-tasks/
├── spec.md              # Feature specification (completed)
├── plan.md              # This file
├── research.md          # Phase 0 output - design decisions
├── data-model.md        # Phase 1 output - entity definitions
├── quickstart.md        # Phase 1 output - integration test scenarios
├── contracts/           # Phase 1 output - file format specifications
│   ├── commits-format.md    # commits.md file format contract
│   └── milestones-format.md # milestones.md file format contract
├── checklists/          # Quality checklists (exists)
│   └── requirements.md  # Specification quality checklist (completed)
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
.claude/commands/
├── speckit.commits.md       # NEW: Group tasks into commits
├── speckit.milestones.md    # NEW: Group commits into milestones
└── speckit.implement.md     # ENHANCED: Respect commits/milestones

.specify/
├── scripts/bash/
│   ├── common.sh            # ENHANCED: Add commit/milestone path helpers
│   ├── check-prerequisites.sh # ENHANCED: Add --require-commits flag
│   └── parse-constitution.sh  # NEW: Extract repetitive tasks from constitution
├── templates/
│   ├── commits-template.md  # NEW: Template for commits.md output
│   └── milestones-template.md # NEW: Template for milestones.md output
└── memory/
    └── constitution.md      # Reference only (already has TDD requirements)

tests/bash/
├── test_parse_constitution.bats  # NEW: Tests for constitution parsing
└── test_check_prerequisites.bats # NEW: Tests for enhanced prerequisites
```

**Structure Decision**: Single project structure (Option 1). This feature extends the existing Spec Kit CLI tool by adding new slash commands and enhancing existing scripts. No new Python code is required - the implementation is primarily Markdown (slash commands) and Bash (helper scripts).

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| PowerShell parity deferred | Pester test infrastructure not yet implemented | Cannot block feature on missing test framework; tracked as follow-up |

## Implementation Phases

### Phase 0: Research & Design Decisions

Key decisions to document in `research.md`:

1. **Task Grouping Algorithm**: How to automatically group tasks into commits
2. **Constitution Parsing**: How to extract repetitive tasks from constitution keywords
3. **Milestone Boundary Detection**: How to determine where milestones should be placed
4. **Commit Message Generation**: Format and content of auto-generated commit messages

### Phase 1: Design Artifacts

1. **data-model.md**: Define entities (Task, Commit, Milestone, RepetitiveTask)
2. **contracts/commits-format.md**: File format specification for commits.md
3. **contracts/milestones-format.md**: File format specification for milestones.md
4. **quickstart.md**: Integration test scenarios for the new commands

### Phase 2: Implementation (via /speckit.tasks)

Tasks will be generated by the `/speckit.tasks` command based on this plan.
