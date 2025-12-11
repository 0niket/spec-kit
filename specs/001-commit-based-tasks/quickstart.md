# Quickstart: Diverge-Converge Workflow

**Feature**: 001-commit-based-tasks
**Date**: 2025-12-11

## Prerequisites

Before testing the diverge-converge workflow, ensure:

1. Spec Kit is installed and configured
2. A feature specification exists with user stories
3. `tasks.md` has been generated via `/speckit.tasks`
4. Constitution file exists at `.specify/memory/constitution.md`

## Integration Test Scenarios

### Scenario 1: Basic Commit Generation

**Purpose**: Verify `/speckit.commits` groups tasks correctly

**Setup**:

```bash
# Create a test feature with sample tasks
mkdir -p specs/test-feature
cat > specs/test-feature/tasks.md << 'EOF'
# Tasks: Test Feature

## Phase 1: Core Implementation

- [ ] [T001] [P1] [US1] Create user model `src/models/user.py`
- [ ] [T002] [P1] [US1] Create user service `src/services/user.py`
- [ ] [T003] [P1] [US1] Create user API endpoint `src/api/user.py`
- [ ] [T004] [P1] [US2] Create auth middleware `src/middleware/auth.py`
EOF
```

**Execute**:

```text
/speckit.commits
```

**Expected Output**:

- `commits.md` created in `specs/test-feature/`
- T001, T002, T003 grouped into one commit (same story US1, related files)
- T004 in separate commit (different story US2)
- Each commit includes TDD repetitive tasks from constitution

**Verification**:

```bash
# Check commits file exists
test -f specs/test-feature/commits.md && echo "PASS" || echo "FAIL"

# Check task grouping (US1 tasks together)
grep -A 20 "## Commit 1:" specs/test-feature/commits.md | grep -c "\[US1\]"
# Expected: 3

# Check repetitive tasks present
grep -c "TDD-RED" specs/test-feature/commits.md
# Expected: >= 2 (one per commit)
```

### Scenario 2: Constitution-Driven Repetitive Tasks

**Purpose**: Verify repetitive tasks are injected based on constitution

**Setup**:

Ensure constitution has TDD requirements:

```bash
grep "TDD" .specify/memory/constitution.md
# Should find "Test-Driven Development" section
```

**Execute**:

```text
/speckit.commits
```

**Expected Output**:

For each commit in `commits.md`:

- `[TDD-RED] Write failing test for [component]`
- `[TDD-GREEN] Implement [component] to pass test`
- `[TDD-REFACTOR] Refactor [component] if needed`
- `[VERIFY] Run make check`

**Verification**:

```bash
# Count TDD tasks per commit
for commit in $(grep "^## Commit" specs/test-feature/commits.md | wc -l | tr -d ' '); do
  echo "Checking commit $commit"
done

# Each commit should have 4 repetitive tasks
grep -c "\[TDD-" specs/test-feature/commits.md
# Expected: 3 * number_of_commits (RED, GREEN, REFACTOR)
```

### Scenario 3: Milestone Generation

**Purpose**: Verify `/speckit.milestones` creates verification checkpoints

**Setup**:

Ensure `commits.md` exists from Scenario 1

**Execute**:

```text
/speckit.milestones
```

**Expected Output**:

- `milestones.md` created in `specs/test-feature/`
- Milestones aligned with user stories (US1, US2)
- Verification criteria derived from spec acceptance scenarios
- P1 stories get separate milestones

**Verification**:

```bash
# Check milestones file exists
test -f specs/test-feature/milestones.md && echo "PASS" || echo "FAIL"

# Check milestone count matches story count
grep -c "^## Milestone" specs/test-feature/milestones.md
# Expected: >= 2 (one per user story minimum)

# Check verification criteria present
grep -c "\[V0" specs/test-feature/milestones.md
# Expected: >= 4 (multiple criteria per milestone)
```

### Scenario 4: Implementation with Commit Boundaries

**Purpose**: Verify `/speckit.implement` respects commit boundaries

**Setup**:

Ensure `tasks.md`, `commits.md`, and `milestones.md` exist

**Execute**:

```text
/speckit.implement
```

**Expected Behavior**:

1. Loads all three documents
2. Executes tasks in commit order (C001 before C002)
3. Within each commit, executes TDD cycle:
   - RED: Write test (should fail)
   - GREEN: Implement (test passes)
   - REFACTOR: Clean up
   - VERIFY: Run `make check`
4. Creates git commit with planned message after all tasks pass
5. Pauses at milestone boundaries for verification

**Verification**:

```bash
# Check git commits created
git log --oneline -5
# Should see commits matching messages from commits.md

# Check commit messages follow conventional format
git log --oneline -5 | grep -E "^[a-f0-9]+ (feat|fix|test|refactor|docs|chore)"
```

### Scenario 5: Milestone Verification Pause

**Purpose**: Verify implementation pauses at milestones

**Setup**:

Run `/speckit.implement` until first milestone completes

**Expected Behavior**:

1. When all commits in Milestone 1 complete
2. Status in `milestones.md` changes to `verification_required`
3. Implementation pauses
4. User prompted with verification criteria
5. User must manually verify and update status

**Verification**:

```bash
# Check milestone status changed
grep "Status.*verification_required" specs/test-feature/milestones.md
# Should find at least one milestone in this state

# Check verification criteria shown to user
grep "\[V0" specs/test-feature/milestones.md | head -5
# User should see these criteria and check them
```

### Scenario 6: Missing Document Error

**Purpose**: Verify `/speckit.implement` fails gracefully without required documents

**Setup**:

```bash
# Remove commits.md
mv specs/test-feature/commits.md specs/test-feature/commits.md.bak
```

**Execute**:

```text
/speckit.implement
```

**Expected Output**:

- Clear error message
- Instruction to run `/speckit.commits` first
- Implementation does not start

**Verification**:

```bash
# Restore file
mv specs/test-feature/commits.md.bak specs/test-feature/commits.md
```

## Cleanup

```bash
# Remove test feature
rm -rf specs/test-feature
```

## Manual Testing Checklist

- [ ] `/speckit.commits` generates valid `commits.md`
- [ ] Tasks are grouped by story and file proximity
- [ ] Repetitive tasks appear in every commit
- [ ] `/speckit.milestones` generates valid `milestones.md`
- [ ] Milestones align with user stories
- [ ] Verification criteria match spec scenarios
- [ ] `/speckit.implement` loads all three documents
- [ ] Implementation follows commit order
- [ ] TDD cycle enforced within each commit
- [ ] Git commits created at commit boundaries
- [ ] Implementation pauses at milestones
- [ ] Verification status can be updated
- [ ] Missing documents produce clear errors

## Performance Notes

- Commit generation should complete in < 5 seconds for typical task lists
- Milestone generation should complete in < 3 seconds
- Document loading should be instant (file reads only)
