#!/usr/bin/env bats

# Tests for commit grouping logic
# These tests validate the conceptual grouping algorithm used by /speckit.commits
# Note: Slash commands are executed by Claude Code, so these tests focus on
# the supporting infrastructure and file format validation

setup() {
    TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    REPO_ROOT="$(cd "$TEST_DIR/../.." && pwd)"
    TEST_FEATURE_DIR="$REPO_ROOT/specs/001-commit-based-tasks"
}

teardown() {
    # Cleanup any test artifacts
    rm -f "$TEST_FEATURE_DIR/commits.md" 2>/dev/null || true
}

@test "commits-template.md exists" {
    [ -f "$REPO_ROOT/.specify/templates/commits-template.md" ]
}

@test "commits-template.md contains required sections" {
    template="$REPO_ROOT/.specify/templates/commits-template.md"
    grep -q "# Commits:" "$template"
    grep -q "## Summary" "$template"
    grep -q "Non-Repetitive Tasks" "$template"
    grep -q "Repetitive Tasks" "$template"
}

@test "speckit.commits.md slash command exists" {
    [ -f "$REPO_ROOT/.claude/commands/speckit.commits.md" ]
}

@test "speckit.commits.md has required frontmatter" {
    command_file="$REPO_ROOT/.claude/commands/speckit.commits.md"
    # Check for YAML frontmatter
    head -1 "$command_file" | grep -q "^---"
    grep -q "description:" "$command_file"
}

@test "speckit.commits.md references check-prerequisites.sh" {
    command_file="$REPO_ROOT/.claude/commands/speckit.commits.md"
    grep -q "check-prerequisites.sh" "$command_file"
}

@test "speckit.commits.md has outline section" {
    command_file="$REPO_ROOT/.claude/commands/speckit.commits.md"
    grep -q "## Outline" "$command_file"
}

@test "commits format contract exists" {
    [ -f "$TEST_FEATURE_DIR/contracts/commits-format.md" ]
}
