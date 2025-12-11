# Tasks: Diverge-Converge Workflow

**Input**: Design documents from `/specs/001-commit-based-tasks/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Tests are included as this feature requires TDD per constitution (Principle VII).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Slash commands**: `.claude/commands/`
- **Bash scripts**: `.specify/scripts/bash/`
- **Templates**: `.specify/templates/`
- **Tests**: `tests/bash/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and template creation

- [ ] T001 Create commits-template.md for commits.md output `.specify/templates/commits-template.md`
- [ ] T002 [P] Create milestones-template.md for milestones.md output `.specify/templates/milestones-template.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**CRITICAL**: No user story work can begin until this phase is complete

- [ ] T003 Write bats test for parse-constitution.sh `tests/bash/test_parse_constitution.bats`
- [ ] T004 Create parse-constitution.sh script to extract repetitive tasks from constitution `.specify/scripts/bash/parse-constitution.sh`
- [ ] T005 Write bats test for enhanced check-prerequisites.sh flags `tests/bash/test_check_prerequisites.bats`
- [ ] T006 Enhance check-prerequisites.sh with --require-commits and --include-commits flags `.specify/scripts/bash/check-prerequisites.sh`
- [ ] T007 [P] Add COMMITS and MILESTONES path helpers to common.sh `.specify/scripts/bash/common.sh`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Group Tasks into Commits (Priority: P1)

**Goal**: Create `/speckit.commits` command that groups tasks into logical commits

**Independent Test**: Run `/speckit.commits` on a tasks.md and verify commits.md contains commit groupings with task assignments

### Tests for User Story 1

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation (TDD RED phase)**

- [ ] T008 [US1] Write bats test for task grouping by story tag `tests/bash/test_commits_grouping.bats`
- [ ] T009 [US1] Write bats test for commit message generation `tests/bash/test_commits_grouping.bats`

### Implementation for User Story 1

- [ ] T010 [US1] Create speckit.commits.md slash command with outline structure `.claude/commands/speckit.commits.md`
- [ ] T011 [US1] Implement task parsing logic in speckit.commits.md (read tasks.md, extract task IDs and story refs) `.claude/commands/speckit.commits.md`
- [ ] T012 [US1] Implement semantic grouping algorithm (group by [Story] tag, then by file path) `.claude/commands/speckit.commits.md`
- [ ] T013 [US1] Implement conventional commit message generation for each group `.claude/commands/speckit.commits.md`
- [ ] T014 [US1] Implement commits.md output following contracts/commits-format.md specification `.claude/commands/speckit.commits.md`
- [ ] T015 [US1] Add handoffs to speckit.milestones in command frontmatter `.claude/commands/speckit.commits.md`

**Checkpoint**: User Story 1 complete - `/speckit.commits` generates commits.md with grouped tasks

---

## Phase 4: User Story 2 - Add Repetitive Tasks from Constitution (Priority: P1)

**Goal**: `/speckit.commits` automatically adds constitution-driven repetitive tasks to each commit

**Independent Test**: Run `/speckit.commits` with a constitution requiring TDD and verify each commit includes RED-GREEN-REFACTOR tasks

### Tests for User Story 2

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation (TDD RED phase)**

- [ ] T016 [US2] Write bats test for TDD task injection `tests/bash/test_repetitive_tasks.bats`
- [ ] T017 [US2] Write bats test for conditional linting task injection `tests/bash/test_repetitive_tasks.bats`

### Implementation for User Story 2

- [ ] T018 [US2] Integrate parse-constitution.sh output into speckit.commits.md workflow `.claude/commands/speckit.commits.md`
- [ ] T019 [US2] Implement TDD repetitive task injection (RED, GREEN, REFACTOR per commit) `.claude/commands/speckit.commits.md`
- [ ] T020 [US2] Implement conditional linting task injection (shellcheck for .sh, ruff for .py) `.claude/commands/speckit.commits.md`
- [ ] T021 [US2] Implement VERIFY task injection (make check) at end of each commit `.claude/commands/speckit.commits.md`
- [ ] T022 [US2] Update commits.md output to include Repetitive Tasks section per commit `.claude/commands/speckit.commits.md`

**Checkpoint**: User Story 2 complete - `/speckit.commits` adds constitution-driven repetitive tasks

---

## Phase 5: User Story 3 - Define Milestones for Verification (Priority: P2)

**Goal**: Create `/speckit.milestones` command that groups commits into milestones with verification criteria

**Independent Test**: Run `/speckit.milestones` on commits.md and verify milestones.md contains milestone boundaries with verification criteria from spec

### Tests for User Story 3

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation (TDD RED phase)**

- [ ] T023 [US3] Write bats test for milestone boundary detection `tests/bash/test_milestones.bats`
- [ ] T024 [US3] Write bats test for verification criteria extraction from spec `tests/bash/test_milestones.bats`

### Implementation for User Story 3

- [ ] T025 [US3] Create speckit.milestones.md slash command with outline structure `.claude/commands/speckit.milestones.md`
- [ ] T026 [US3] Implement commits.md parsing to extract commit IDs and story refs `.claude/commands/speckit.milestones.md`
- [ ] T027 [US3] Implement milestone boundary detection (group commits by user story) `.claude/commands/speckit.milestones.md`
- [ ] T028 [US3] Implement verification criteria extraction from spec.md acceptance scenarios `.claude/commands/speckit.milestones.md`
- [ ] T029 [US3] Implement milestones.md output following contracts/milestones-format.md specification `.claude/commands/speckit.milestones.md`
- [ ] T030 [US3] Add handoffs to speckit.implement in command frontmatter `.claude/commands/speckit.milestones.md`

**Checkpoint**: User Story 3 complete - `/speckit.milestones` generates milestones.md with verification criteria

---

## Phase 6: User Story 4 - Execute with Commit and Milestone Boundaries (Priority: P2)

**Goal**: Enhance `/speckit.implement` to load commits.md and milestones.md, execute tasks commit-by-commit, pause at milestones

**Independent Test**: Run `/speckit.implement` and verify it loads all three documents, creates git commits at boundaries, and pauses at milestones

### Tests for User Story 4

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation (TDD RED phase)**

- [ ] T031 [US4] Write bats test for document existence validation `tests/bash/test_implement_enhanced.bats`
- [ ] T032 [US4] Write bats test for commit boundary detection `tests/bash/test_implement_enhanced.bats`

### Implementation for User Story 4

- [ ] T033 [US4] Add document validation to speckit.implement.md (require commits.md, milestones.md) `.claude/commands/speckit.implement.md`
- [ ] T034 [US4] Update check-prerequisites.sh call to use --require-commits --include-commits flags `.claude/commands/speckit.implement.md`
- [ ] T035 [US4] Implement commit-by-commit execution flow (execute tasks grouped by commit) `.claude/commands/speckit.implement.md`
- [ ] T036 [US4] Implement git commit creation at commit boundaries with planned message `.claude/commands/speckit.implement.md`
- [ ] T037 [US4] Implement milestone pause logic (pause and prompt for verification when milestone reached) `.claude/commands/speckit.implement.md`
- [ ] T038 [US4] Implement verification status tracking (update milestones.md status field) `.claude/commands/speckit.implement.md`
- [ ] T039 [US4] Add clear error messages when commits.md or milestones.md missing `.claude/commands/speckit.implement.md`

**Checkpoint**: User Story 4 complete - `/speckit.implement` respects commit and milestone boundaries

---

## Phase 7: User Story 5 - View Workflow Progress (Priority: P3)

**Goal**: Visual representation of diverge-converge workflow progress

**Independent Test**: Run status check mid-implementation and verify it shows current phase, completed items, and next steps

### Implementation for User Story 5

- [ ] T040 [US5] Add progress display section to speckit.implement.md showing commit/milestone status `.claude/commands/speckit.implement.md`
- [ ] T041 [US5] Implement ASCII progress visualization (commits completed, current milestone, remaining) `.claude/commands/speckit.implement.md`
- [ ] T042 [US5] Display verification status for completed milestones (passed/failed/pending) `.claude/commands/speckit.implement.md`

**Checkpoint**: User Story 5 complete - workflow progress is visible during implementation

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Documentation and cleanup

- [ ] T043 [P] Update README.md with new commands documentation `README.md`
- [ ] T044 [P] Add command usage examples to each new slash command `.claude/commands/speckit.commits.md`, `.claude/commands/speckit.milestones.md`
- [ ] T045 Run all bats tests to verify implementation `tests/bash/`
- [ ] T046 Run make check to verify linting passes
- [ ] T047 Run quickstart.md validation scenarios `specs/001-commit-based-tasks/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational phase completion
  - US1 and US2 can proceed in parallel (both modify speckit.commits.md but at different aspects)
  - US3 depends on US1/US2 (needs commits.md to exist)
  - US4 depends on US3 (needs milestones.md to exist)
  - US5 depends on US4 (enhances implement command)
- **Polish (Phase 8)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational - Integrates with US1 (same command)
- **User Story 3 (P2)**: Depends on US1/US2 completion (needs commits.md format finalized)
- **User Story 4 (P2)**: Depends on US3 completion (needs milestones.md)
- **User Story 5 (P3)**: Depends on US4 completion (enhances implement command)

### Within Each User Story

- Tests MUST be written and FAIL before implementation (TDD RED)
- Implement to pass tests (TDD GREEN)
- Refactor while tests pass (TDD REFACTOR)
- Run make check before considering story complete

### Parallel Opportunities

- T001 and T002 (templates) can run in parallel
- T003/T004 and T005/T006 can run in parallel (different scripts)
- T008/T009 (US1 tests) can run in parallel
- T016/T017 (US2 tests) can run in parallel
- T023/T024 (US3 tests) can run in parallel
- T031/T032 (US4 tests) can run in parallel
- T043/T044 (documentation) can run in parallel

---

## Parallel Example: Foundational Phase

```bash
# Launch script development in parallel:
Task: "Write bats test for parse-constitution.sh" + "Create parse-constitution.sh"
Task: "Write bats test for check-prerequisites.sh" + "Enhance check-prerequisites.sh"
Task: "Add path helpers to common.sh"
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 Only)

1. Complete Phase 1: Setup (templates)
2. Complete Phase 2: Foundational (scripts and tests)
3. Complete Phase 3: User Story 1 (basic commit grouping)
4. Complete Phase 4: User Story 2 (repetitive tasks)
5. **STOP and VALIDATE**: Test `/speckit.commits` independently
6. Can use commits.md manually without milestones.md

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 + 2 → `/speckit.commits` works (MVP!)
3. Add User Story 3 → `/speckit.milestones` works
4. Add User Story 4 → `/speckit.implement` enhanced
5. Add User Story 5 → Progress visualization
6. Each story adds value without breaking previous

---

## Summary

| Metric | Value |
|--------|-------|
| Total Tasks | 47 |
| Setup Phase | 2 tasks |
| Foundational Phase | 5 tasks |
| User Story 1 (P1) | 8 tasks |
| User Story 2 (P1) | 7 tasks |
| User Story 3 (P2) | 8 tasks |
| User Story 4 (P2) | 9 tasks |
| User Story 5 (P3) | 3 tasks |
| Polish Phase | 5 tasks |
| Parallel opportunities | 12 task groups |

**MVP Scope**: User Stories 1 + 2 (15 tasks after foundational)

**Independent Test Criteria**:

- US1: `/speckit.commits` outputs commits.md with grouped tasks
- US2: Each commit includes TDD and linting repetitive tasks
- US3: `/speckit.milestones` outputs milestones.md with verification criteria
- US4: `/speckit.implement` pauses at milestones for verification
- US5: Progress display shows commit/milestone status

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing (TDD RED)
- Run make check after each task group
- Stop at any checkpoint to validate story independently
