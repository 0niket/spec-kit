#!/usr/bin/env bats

# Tests for milestone generation logic
# These tests validate the /speckit.milestones command infrastructure

setup() {
    TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    REPO_ROOT="$(cd "$TEST_DIR/../.." && pwd)"
    TEST_FEATURE_DIR="$REPO_ROOT/specs/001-commit-based-tasks"
}

teardown() {
    # Cleanup any test artifacts
    rm -f "$TEST_FEATURE_DIR/milestones.md" 2>/dev/null || true
}

@test "milestones-template.md exists" {
    [ -f "$REPO_ROOT/.specify/templates/milestones-template.md" ]
}

@test "milestones-template.md contains required sections" {
    template="$REPO_ROOT/.specify/templates/milestones-template.md"
    grep -q "# Milestones:" "$template"
    grep -q "## Summary" "$template"
    grep -q "Verification Criteria" "$template"
    grep -q "Commits Included" "$template"
}

@test "speckit.milestones.md slash command exists" {
    [ -f "$REPO_ROOT/.claude/commands/speckit.milestones.md" ]
}

@test "speckit.milestones.md has required frontmatter" {
    command_file="$REPO_ROOT/.claude/commands/speckit.milestones.md"
    head -1 "$command_file" | grep -q "^---"
    grep -q "description:" "$command_file"
}

@test "speckit.milestones.md references check-prerequisites.sh" {
    command_file="$REPO_ROOT/.claude/commands/speckit.milestones.md"
    grep -q "check-prerequisites.sh" "$command_file"
}

@test "speckit.milestones.md has outline section" {
    command_file="$REPO_ROOT/.claude/commands/speckit.milestones.md"
    grep -q "## Outline" "$command_file"
}

@test "speckit.milestones.md documents verification criteria extraction" {
    command_file="$REPO_ROOT/.claude/commands/speckit.milestones.md"
    grep -q -i "verification" "$command_file"
    grep -q -i "spec.md" "$command_file"
}

@test "milestones format contract exists" {
    [ -f "$TEST_FEATURE_DIR/contracts/milestones-format.md" ]
}

@test "milestones format contract defines verification status values" {
    contract="$TEST_FEATURE_DIR/contracts/milestones-format.md"
    grep -q "pending" "$contract"
    grep -q "verification_required" "$contract"
    grep -q "verified" "$contract"
    grep -q "rejected" "$contract"
}
