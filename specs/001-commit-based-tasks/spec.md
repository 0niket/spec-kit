# Feature Specification: Commit-Based Task Orchestration

**Feature Branch**: `001-commit-based-tasks`
**Created**: 2025-12-11
**Status**: Draft
**Input**: User description: "Introduce commits as the bridge between planning and tasks, with repetitive and non-repetitive task types driven by the project constitution"

## Problem Statement

The current Spec Kit workflow has three planning layers: **Specification → Planning → Tasks**. However, there is a gap between the planning phase and task execution. Tasks are generated as flat lists without clear boundaries for what constitutes a "done" unit of work. This leads to:

1. **Quality practices as afterthoughts** - TDD, testing, and documentation are separate tasks rather than integral parts of each deliverable
2. **Unclear progress tracking** - Without commit boundaries, it's hard to know when a unit of work is complete
3. **Constitution principles not enforced** - Quality requirements defined in the constitution are not automatically woven into the workflow

## Solution Overview

Introduce **Commits** as the intermediate layer between Planning and Tasks:

**Specification → Planning → Commits → Tasks**

Where:

- **Commits** are planned units of deliverable work (each commit should leave the codebase in a working state)
- **Tasks** are grouped under commits and divided into two types:
  - **Repetitive tasks**: Automatically derived from constitution principles (e.g., TDD cycles, test updates)
  - **Non-repetitive tasks**: The actual implementation work unique to each commit

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Plan Commits from Implementation Plan (Priority: P1)

As a developer using Spec Kit, I want the `/speckit.tasks` command to generate a list of planned commits (not just tasks) so that I have clear boundaries for what constitutes a complete unit of work.

**Why this priority**: This is the foundational change - without commit planning, the rest of the feature cannot work. Commits provide the structure that enables everything else.

**Independent Test**: Can be fully tested by running `/speckit.tasks` on a sample plan and verifying the output contains commit boundaries with descriptions of what each commit achieves.

**Acceptance Scenarios**:

1. **Given** a completed `plan.md`, **When** I run `/speckit.tasks`, **Then** the output `tasks.md` contains a list of planned commits, each with a clear description of the deliverable
2. **Given** a plan with multiple user stories, **When** commits are generated, **Then** each commit maps to a logical, independently testable unit of the implementation
3. **Given** a generated commits list, **When** I review it, **Then** each commit description follows the conventional commit format (type: description)

---

### User Story 2 - Generate Repetitive Tasks from Constitution (Priority: P1)

As a developer, I want repetitive quality tasks (like TDD cycles, test updates) to be automatically generated for each commit based on my project's constitution, so that quality practices are built into every deliverable rather than bolted on.

**Why this priority**: This is the core innovation - ensuring constitution-defined quality practices are automatically enforced at the commit level.

**Independent Test**: Can be tested by creating a constitution with TDD requirements and verifying that each planned commit automatically includes RED-GREEN-REFACTOR tasks.

**Acceptance Scenarios**:

1. **Given** a constitution that requires TDD, **When** commits are generated, **Then** each commit includes repetitive tasks for: write failing test → implement → refactor
2. **Given** a constitution that requires Playwright tests for UI changes, **When** a commit involves UI changes, **Then** repetitive tasks for Playwright test creation/update are included
3. **Given** a constitution with linting requirements, **When** commits are generated, **Then** each commit includes a verification task for linting
4. **Given** a constitution with documentation requirements, **When** a commit adds/changes features, **Then** repetitive tasks for documentation updates are included

---

### User Story 3 - Generate Non-Repetitive Tasks for Implementation (Priority: P2)

As a developer, I want the actual implementation work to be broken down into non-repetitive tasks under each commit, so that I have a clear checklist of what needs to be done for each deliverable.

**Why this priority**: Without the implementation tasks, the commits would only have quality checks but no actual work.

**Independent Test**: Can be tested by verifying that each commit contains specific implementation tasks derived from the plan.

**Acceptance Scenarios**:

1. **Given** a commit for "Add user model", **When** tasks are generated, **Then** non-repetitive tasks include: create model file, define attributes, add validation rules
2. **Given** a plan with technical decisions documented, **When** non-repetitive tasks are generated, **Then** they reference the relevant technical decisions
3. **Given** a commit with dependencies on another commit, **When** tasks are generated, **Then** the dependency is clearly noted

---

### User Story 4 - Execute Commits Sequentially (Priority: P2)

As a developer, I want `/speckit.implement` to execute commits one at a time, completing all tasks (repetitive + non-repetitive) for each commit before moving to the next, so that the codebase remains in a working state after each commit.

**Why this priority**: This ensures the commit-based workflow is actually followed during implementation.

**Independent Test**: Can be tested by running `/speckit.implement` and verifying that actual git commits are created at the defined boundaries.

**Acceptance Scenarios**:

1. **Given** a tasks.md with 5 planned commits, **When** I run `/speckit.implement`, **Then** the AI agent executes all tasks for commit 1 before starting commit 2
2. **Given** a commit with repetitive TDD tasks, **When** the commit is being implemented, **Then** tests are written before implementation code
3. **Given** a commit is complete, **When** all its tasks pass, **Then** a git commit is created with the planned commit message
4. **Given** a commit fails its verification tasks (linting, tests), **When** reviewed, **Then** the implementation pauses for fixes before proceeding

---

### User Story 5 - Constitution-Aware Task Templates (Priority: P3)

As a project maintainer, I want to define custom repetitive task templates in the constitution, so that project-specific quality practices are automatically included in every commit.

**Why this priority**: This enables customization beyond the default repetitive tasks.

**Independent Test**: Can be tested by adding a custom task template to the constitution and verifying it appears in generated commits.

**Acceptance Scenarios**:

1. **Given** a constitution with a custom "security review" repetitive task, **When** commits are generated, **Then** each commit includes the security review task
2. **Given** a constitution with conditional repetitive tasks (e.g., "API documentation for API changes"), **When** a commit involves API changes, **Then** the conditional task is included
3. **Given** a constitution without custom templates, **When** commits are generated, **Then** default repetitive tasks based on detected patterns are used

---

### Edge Cases

- What happens when a commit's non-repetitive tasks fail but repetitive tasks pass? → The commit should not be created; implementation should pause for fixes
- How does the system handle commits that span multiple files with different test requirements? → Repetitive tasks should be aggregated at the commit level, not per-file
- What happens when the constitution is updated mid-implementation? → New commits should use updated constitution; in-progress commits continue with original requirements
- How are circular dependencies between commits handled? → Validation should fail during `/speckit.tasks` with a clear error message

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The `/speckit.tasks` command MUST generate a `tasks.md` that organizes work into planned commits
- **FR-002**: Each commit MUST have a clear, conventional-format description of its deliverable
- **FR-003**: The system MUST parse the constitution to identify repetitive task requirements
- **FR-004**: Repetitive tasks MUST be automatically added to each commit based on constitution principles
- **FR-005**: Non-repetitive tasks MUST be derived from the implementation plan and organized under commits
- **FR-006**: The `/speckit.implement` command MUST execute commits sequentially, completing all tasks before creating a git commit
- **FR-007**: The system MUST validate that all repetitive tasks pass before allowing a commit to be created
- **FR-008**: Task dependencies within a commit MUST be respected during execution order
- **FR-009**: The system MUST support conditional repetitive tasks (tasks that apply only to certain types of changes)
- **FR-010**: The tasks.md format MUST clearly distinguish between repetitive and non-repetitive tasks

### Key Entities

- **Commit**: A planned unit of deliverable work with a description, list of tasks, and completion criteria
- **Repetitive Task**: A task derived from constitution principles that applies to every (or conditional) commit
- **Non-Repetitive Task**: A task specific to the implementation work of a single commit
- **Constitution Principle**: A quality requirement that may generate repetitive tasks (e.g., TDD, linting, documentation)
- **Task Dependency**: A relationship indicating one task must complete before another can begin

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of commits generated by `/speckit.tasks` include repetitive tasks derived from the constitution
- **SC-002**: Users can understand the scope of each commit by reading its description alone (no need to read individual tasks)
- **SC-003**: Implementation via `/speckit.implement` creates git commits at the planned boundaries 90%+ of the time
- **SC-004**: Quality violations (failed tests, linting errors) are caught before git commits are created
- **SC-005**: Time from plan to implementation reduces by enabling AI agents to work autonomously through well-defined commit boundaries
- **SC-006**: Users report that quality practices feel "built-in" rather than "bolted on" in post-implementation surveys

## Assumptions

- The project constitution follows the established format with clearly identifiable principles
- Git is available and configured in the project repository
- AI agents support the concept of executing tasks in sequence and creating commits
- The existing `/speckit.tasks` template structure can be extended to support commit-based organization
- Repetitive tasks for common patterns (TDD, linting, testing) can be detected from constitution keywords
