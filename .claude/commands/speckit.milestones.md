---
description: Group commits into milestones with verification criteria from spec.md acceptance scenarios.
handoffs:
  - label: Implement
    agent: speckit.implement
    prompt: Execute the implementation following commit and milestone boundaries
    send: true
  - label: Review Commits
    agent: speckit.commits
    prompt: Review or regenerate commit groupings
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. **Setup**: Run `.specify/scripts/bash/check-prerequisites.sh --json --require-commits --include-commits` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. For single quotes in args, use escape syntax.

2. **Load context**: Read from FEATURE_DIR:
   - **Required**: commits.md (commit groupings with task assignments)
   - **Required**: spec.md (user stories and acceptance scenarios for verification criteria)
   - **Optional**: tasks.md (for cross-reference validation)
   - **Optional**: plan.md (for context on project structure)

3. **Parse commits.md**: Extract all commits with their:
   - Commit ID (C###)
   - Commit message
   - Story reference [US#] if present
   - Status (pending, in_progress, completed)
   - Non-repetitive and repetitive tasks

4. **Parse spec.md**: Extract user stories and their acceptance scenarios:
   - User story ID (US#)
   - Story title
   - Priority (P1, P2, P3)
   - Acceptance scenarios in Given/When/Then format

5. **Group commits into milestones** using story-based boundaries:

   **Grouping Algorithm**:
   1. Each user story maps to one milestone
   2. All commits with the same [Story] reference → same milestone
   3. Setup/Foundational commits (no story ref) → Milestone 0 (Infrastructure)
   4. Polish commits → Final milestone

   **Rules**:
   - Each milestone represents a complete user story deliverable
   - Milestones are ordered by priority (P1 → P2 → P3)
   - Infrastructure milestone (if any) comes first
   - Polish milestone comes last

6. **Extract verification criteria** from spec.md:

   For each milestone:
   1. Find the corresponding user story in spec.md
   2. Extract all acceptance scenarios from that story
   3. Convert to verification checklist format:
      - `Given/When/Then` → `- [ ] [V###] Given..., When..., Then...`
   4. Assign sequential verification IDs (V001, V002, etc.)

7. **Generate milestones.md** following the format in `contracts/milestones-format.md`:
   - Header with metadata (Generated timestamp, Source paths)
   - Summary with counts
   - Each milestone section with:
     - User story title as heading
     - ID, Status (pending), Story reference, Priority
     - Commits Included (list of commit IDs and messages)
     - Verification Criteria (from acceptance scenarios)
     - Manual Verification Notes section

8. **Write output**: Save milestones.md to FEATURE_DIR

9. **Report**: Output path to generated milestones.md and summary:
   - Total milestones generated
   - Commits per milestone breakdown
   - Verification criteria per milestone
   - Stories covered

## Grouping Examples

### Example 1: Story-based milestone

```text
Input commits:
- [C001] feat(commits): add speckit.commits slash command [US1]
- [C002] feat(commits): add task grouping algorithm [US1]
- [C003] test(commits): add integration tests [US1]

Output: Single milestone for US1
## Milestone 1: Group Tasks into Commits

**Story**: US1
**Priority**: P1

### Commits Included
1. [C001] feat(commits): add speckit.commits slash command
2. [C002] feat(commits): add task grouping algorithm
3. [C003] test(commits): add integration tests

### Verification Criteria
- [ ] [V001] Given a completed tasks.md, When I run /speckit.commits, Then commits.md contains commits with grouped tasks
- [ ] [V002] Given tasks that logically belong together, When commits are generated, Then they are grouped into a single commit
```

### Example 2: Infrastructure milestone

```text
Input commits (no story tag):
- [C001] chore(templates): add commits and milestones templates
- [C002] feat(constitution): add constitution parser with tests

Output: Milestone 0 (Infrastructure)
## Milestone 0: Infrastructure

**Story**: N/A (Setup/Foundational)
**Priority**: P0

### Verification Criteria
- [ ] [V001] All template files exist and have required sections
- [ ] [V002] All infrastructure scripts pass their unit tests
```

## Verification Criteria Extraction

Extract from spec.md acceptance scenarios:

**Input (spec.md)**:

```markdown
### User Story 1 - Group Tasks into Commits

**Acceptance Scenarios**:

1. **Given** a completed `tasks.md`, **When** I run `/speckit.commits`, **Then** the output `commits.md` contains commits with grouped tasks
2. **Given** tasks that logically belong together (e.g., model + service + endpoint for one feature), **When** commits are generated, **Then** they are grouped into a single commit
```

**Output (milestones.md)**:

```markdown
### Verification Criteria

> From US1 Acceptance Scenarios

- [ ] [V001] Given a completed tasks.md, When I run /speckit.commits, Then the output commits.md contains commits with grouped tasks
- [ ] [V002] Given tasks that logically belong together, When commits are generated, Then they are grouped into a single commit
```

## Output Format

Follow the exact format specified in `contracts/milestones-format.md`.

## Key Rules

- Use absolute paths in metadata
- Every commit ID from commits.md must appear in exactly one milestone
- Milestones must be ordered by priority (P0 Infrastructure → P1 → P2 → P3 → Polish)
- Validate that all [Story] references exist in spec.md
- Report orphaned commits (commits not assigned to any milestone) as warnings
- Each acceptance scenario becomes one verification criterion
- Verification IDs are globally unique within milestones.md (V001, V002, ... across all milestones)

## Milestone Status Flow

```text
pending → verification_required → verified OR rejected
   │                                    │
   └──────────── (during /speckit.implement) ───────────────┘
```

- `pending`: Commits not yet completed
- `verification_required`: All commits in milestone done, awaiting manual review
- `verified`: User confirmed all verification criteria pass
- `rejected`: User found issues, needs fixes before proceeding

## Usage Examples

**Basic usage** (creates milestones from commits.md):

```text
/speckit.milestones
```

**With specific instructions**:

```text
/speckit.milestones Add additional verification criteria for security requirements
```

**After updating commits**:

```text
/speckit.milestones Regenerate milestones to reflect the new commit structure
```

**Workflow**:

```text
1. /speckit.tasks         → Creates tasks.md
2. /speckit.commits       → Creates commits.md
3. /speckit.milestones    → Creates milestones.md (this command)
4. /speckit.implement     → Executes with milestone pause points
```

**What happens during implementation**:

```text
/speckit.implement runs...
  → Completes commits in Milestone 1
  → PAUSES: "Milestone reached! Please verify criteria..."
  → User types 'verify' to continue
  → Completes commits in Milestone 2
  → PAUSES again for verification
  → ...continues until all milestones verified
```
