# Feature Specification: Diverge-Converge Workflow

**Feature Branch**: `001-commit-based-tasks`
**Created**: 2025-12-11
**Status**: Draft
**Input**: User description: "Implement diverge-converge workflow where specification breaks down into plan, plan breaks down into tasks (divergent), then tasks accumulate into commits, commits accumulate into milestones (convergent). Commits include repetitive and non-repetitive tasks based on constitution."

## Problem Statement

The current Spec Kit workflow has three planning layers: **Specification → Planning → Tasks**. However, there are two critical gaps:

1. **No convergence mechanism** - Tasks are generated as flat lists with no way to group them into meaningful deliverables
2. **No verification checkpoints** - There's no defined point where manual verification of the implementation occurs
3. **Constitution principles not enforced during execution** - Quality requirements are checked during planning but not woven into task execution

## Solution Overview

Introduce a **Diverge-Converge** workflow model:

```
DIVERGENT PHASES (Breaking Down)          CONVERGENT PHASES (Building Up)
┌─────────────────────────────────┐      ┌─────────────────────────────────┐
│  Specification                  │      │  Tasks                          │
│       ↓                         │      │       ↓                         │
│  Plan (breakdown of spec)       │      │  Commits (accumulation of tasks)│
│       ↓                         │      │       ↓                         │
│  Tasks (breakdown of plan)      │      │  Milestones (verification point)│
└─────────────────────────────────┘      └─────────────────────────────────┘
```

**Divergent Phases** (existing, enhanced):
1. `/speckit.specify` - Define what to build
2. `/speckit.plan` - Break specification into technical approach
3. `/speckit.tasks` - Break plan into actionable tasks

**Convergent Phases** (new):
1. `/speckit.commits` - Group tasks into commits with constitution-driven repetitive tasks
2. `/speckit.milestones` - Group commits into milestones requiring manual verification

**Key Concepts**:
- **Commits** accumulate tasks (not the other way around)
- Each commit has two types of tasks:
  - **Repetitive tasks**: Derived from constitution (TDD, linting, testing)
  - **Non-repetitive tasks**: The actual implementation work
- **Milestones** are verification checkpoints requiring human review

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Group Tasks into Commits (Priority: P1)

As a developer, I want to run `/speckit.commits` to group my tasks into logical commits, so that I have clear boundaries for what constitutes a complete, committable unit of work.

**Why this priority**: This is the foundation of the convergent phase - without commit grouping, tasks remain a flat list.

**Independent Test**: Can be fully tested by running `/speckit.commits` on a tasks.md and verifying the output contains commit groupings with task assignments.

**Acceptance Scenarios**:

1. **Given** a completed `tasks.md`, **When** I run `/speckit.commits`, **Then** the output `commits.md` contains commits with grouped tasks
2. **Given** tasks that logically belong together (e.g., model + service + endpoint for one feature), **When** commits are generated, **Then** they are grouped into a single commit
3. **Given** a generated commits list, **When** I review it, **Then** each commit has a conventional commit message (type: description)
4. **Given** independent tasks that can be committed separately, **When** commits are generated, **Then** they are organized into separate commits

---

### User Story 2 - Add Repetitive Tasks from Constitution (Priority: P1)

As a developer, I want `/speckit.commits` to automatically add repetitive tasks to each commit based on my constitution, so that quality practices are enforced at the commit level.

**Why this priority**: This ensures constitution compliance is built into every commit, not checked after the fact.

**Independent Test**: Can be tested by having a constitution with TDD requirements and verifying each commit includes RED-GREEN-REFACTOR tasks.

**Acceptance Scenarios**:

1. **Given** a constitution requiring TDD, **When** commits are generated, **Then** each commit includes: write failing test → implement → verify test passes → refactor
2. **Given** a constitution requiring linting, **When** commits are generated, **Then** each commit includes a "run linter" task at the end
3. **Given** a constitution requiring documentation updates, **When** a commit changes public interfaces, **Then** a documentation update task is included
4. **Given** a constitution with Playwright test requirements, **When** a commit involves UI changes, **Then** Playwright test tasks are included

---

### User Story 3 - Define Milestones for Verification (Priority: P2)

As a developer, I want to run `/speckit.milestones` to group commits into milestones that require manual verification, so that I have clear checkpoints for human review.

**Why this priority**: Milestones provide the human-in-the-loop verification that ensures quality before proceeding to the next phase.

**Independent Test**: Can be tested by running `/speckit.milestones` on commits.md and verifying milestone boundaries with verification criteria.

**Acceptance Scenarios**:

1. **Given** a completed `commits.md`, **When** I run `/speckit.milestones`, **Then** the output `milestones.md` groups commits into milestones
2. **Given** a milestone definition, **When** I review it, **Then** it includes specific verification criteria (what to check)
3. **Given** a milestone is reached during implementation, **When** the AI agent reaches it, **Then** it pauses and requests manual verification
4. **Given** multiple user stories in the spec, **When** milestones are generated, **Then** each user story maps to at least one milestone

---

### User Story 4 - Execute with Commit and Milestone Boundaries (Priority: P2)

As a developer, I want `/speckit.implement` to respect commit and milestone boundaries, executing tasks commit-by-commit and pausing at milestones for verification.

**Why this priority**: This ensures the workflow structure is actually followed during execution.

**Independent Test**: Can be tested by running `/speckit.implement` and verifying it creates git commits at defined boundaries and pauses at milestones.

**Acceptance Scenarios**:

1. **Given** a milestones.md with 3 milestones, **When** I run `/speckit.implement`, **Then** implementation pauses after each milestone for verification
2. **Given** a commit with repetitive tasks, **When** the commit is executed, **Then** repetitive tasks run in the correct order (test before implement)
3. **Given** a commit completes successfully, **When** all tasks pass, **Then** a git commit is created with the planned message
4. **Given** a milestone verification fails, **When** the user rejects, **Then** implementation can roll back to the milestone start

---

### User Story 5 - View Workflow Progress (Priority: P3)

As a developer, I want to see a visual representation of my diverge-converge workflow, so that I understand where I am in the process.

**Why this priority**: Visibility into progress helps developers track complex implementations.

**Independent Test**: Can be tested by running a status command and verifying it shows current phase, completed items, and next steps.

**Acceptance Scenarios**:

1. **Given** a project mid-implementation, **When** I check status, **Then** I see which commits are complete and which milestone I'm working toward
2. **Given** a completed milestone, **When** I view progress, **Then** it shows verification status (passed/failed/pending)
3. **Given** multiple milestones, **When** I view the workflow, **Then** I see the full diverge-converge structure

---

### Edge Cases

- What happens when a commit's tasks fail? → The commit is not created; implementation pauses for fixes
- What happens when the constitution is updated mid-implementation? → New commits use updated constitution; in-progress commits continue with original
- How are task dependencies across commits handled? → Commits must be executed in order; cross-commit dependencies are validated during `/speckit.commits`
- What if a milestone verification is rejected? → User can choose to fix issues or roll back; implementation pauses until resolved
- What if tasks don't logically group into commits? → `/speckit.commits` suggests groupings but allows manual override

## Requirements *(mandatory)*

### Functional Requirements

**Divergent Phase (existing, enhanced)**:
- **FR-001**: `/speckit.specify` MUST create a specification document
- **FR-002**: `/speckit.plan` MUST break the specification into a technical plan
- **FR-003**: `/speckit.tasks` MUST break the plan into actionable tasks

**Convergent Phase (new)**:
- **FR-004**: `/speckit.commits` MUST group tasks into logical commits
- **FR-005**: `/speckit.commits` MUST parse the constitution and add repetitive tasks to each commit
- **FR-006**: Each commit MUST have both repetitive tasks (from constitution) and non-repetitive tasks (from plan)
- **FR-007**: `/speckit.milestones` MUST group commits into milestones with verification criteria
- **FR-008**: Each milestone MUST define what needs to be manually verified
- **FR-009**: `/speckit.implement` MUST execute tasks commit-by-commit
- **FR-010**: `/speckit.implement` MUST pause at milestones for manual verification
- **FR-011**: `/speckit.implement` MUST create git commits at defined boundaries
- **FR-012**: The system MUST support conditional repetitive tasks based on commit content

### Key Entities

- **Task**: The smallest unit of work (from `/speckit.tasks`)
- **Commit**: An accumulation of tasks that forms a single git commit
  - Contains repetitive tasks (from constitution)
  - Contains non-repetitive tasks (from plan)
- **Milestone**: An accumulation of commits that requires manual verification
- **Repetitive Task**: A task derived from constitution that applies to every (or conditional) commit
- **Non-Repetitive Task**: A task specific to the implementation work of a single commit
- **Verification Criteria**: What must be checked at a milestone (defined by user or derived from spec)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of commits generated include both repetitive and non-repetitive tasks
- **SC-002**: Users can understand the scope of each commit by reading its message alone
- **SC-003**: Implementation pauses at every milestone for manual verification 100% of the time
- **SC-004**: Quality violations (failed tests, linting) are caught before git commits are created
- **SC-005**: Users report clearer understanding of progress through diverge-converge visualization
- **SC-006**: Time spent on post-implementation fixes reduces due to milestone verification checkpoints

## Assumptions

- The project constitution follows the established format with identifiable principles
- Git is available and configured in the project repository
- AI agents support pausing for human verification
- The existing `/speckit.tasks` output can be parsed for commit grouping
- Repetitive tasks can be detected from constitution keywords (TDD, lint, test, document)
- Users will perform manual verification at milestones (not skip them)

## New Slash Commands Required

| Command | Phase | Purpose |
| ------- | ----- | ------- |
| `/speckit.commits` | Convergent | Group tasks into commits, add constitution-driven repetitive tasks |
| `/speckit.milestones` | Convergent | Group commits into milestones with verification criteria |

The existing `/speckit.implement` command will be enhanced to respect commit and milestone boundaries.
