#!/usr/bin/env bats

# Tests for enhanced /speckit.implement command infrastructure
# These tests validate the commit/milestone boundary support in implement command

setup() {
    TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    REPO_ROOT="$(cd "$TEST_DIR/../.." && pwd)"
    TEST_FEATURE_DIR="$REPO_ROOT/specs/001-commit-based-tasks"
}

teardown() {
    # Cleanup any test artifacts
    :
}

# T031: Document existence validation tests
@test "speckit.implement.md slash command exists" {
    [ -f "$REPO_ROOT/.claude/commands/speckit.implement.md" ]
}

@test "speckit.implement.md has required frontmatter" {
    command_file="$REPO_ROOT/.claude/commands/speckit.implement.md"
    head -1 "$command_file" | grep -q "^---"
    grep -q "description:" "$command_file"
}

@test "speckit.implement.md documents commits.md requirement" {
    command_file="$REPO_ROOT/.claude/commands/speckit.implement.md"
    grep -q -i "commits.md" "$command_file"
}

@test "speckit.implement.md documents milestones.md requirement" {
    command_file="$REPO_ROOT/.claude/commands/speckit.implement.md"
    grep -q -i "milestones.md" "$command_file"
}

@test "speckit.implement.md references check-prerequisites.sh with commit flags" {
    command_file="$REPO_ROOT/.claude/commands/speckit.implement.md"
    # Should use --require-commits or --include-commits
    grep -q "require-commits\|include-commits" "$command_file"
}

@test "speckit.implement.md references check-prerequisites.sh with milestone flags" {
    command_file="$REPO_ROOT/.claude/commands/speckit.implement.md"
    # Should use --require-milestones or --include-milestones
    grep -q "require-milestones\|include-milestones" "$command_file"
}

# T032: Commit boundary detection tests
@test "speckit.implement.md documents commit boundary execution" {
    command_file="$REPO_ROOT/.claude/commands/speckit.implement.md"
    grep -q -i "commit.*boundary\|boundary.*commit\|commit-by-commit" "$command_file"
}

@test "speckit.implement.md documents milestone pause behavior" {
    command_file="$REPO_ROOT/.claude/commands/speckit.implement.md"
    grep -q -i "pause.*milestone\|milestone.*pause\|verification" "$command_file"
}

@test "speckit.implement.md documents git commit creation" {
    command_file="$REPO_ROOT/.claude/commands/speckit.implement.md"
    grep -q -i "git commit\|create commit\|commit.*created" "$command_file"
}

@test "speckit.implement.md documents verification status tracking" {
    command_file="$REPO_ROOT/.claude/commands/speckit.implement.md"
    grep -q -i "status.*track\|verification.*status\|milestone.*status" "$command_file"
}

@test "speckit.implement.md has outline section" {
    command_file="$REPO_ROOT/.claude/commands/speckit.implement.md"
    grep -q "## Outline" "$command_file"
}

@test "check-prerequisites.sh supports --require-commits flag" {
    script="$REPO_ROOT/.specify/scripts/bash/check-prerequisites.sh"
    grep -q "\-\-require-commits" "$script"
}

@test "check-prerequisites.sh supports --include-commits flag" {
    script="$REPO_ROOT/.specify/scripts/bash/check-prerequisites.sh"
    grep -q "\-\-include-commits" "$script"
}

@test "check-prerequisites.sh supports --require-milestones flag" {
    script="$REPO_ROOT/.specify/scripts/bash/check-prerequisites.sh"
    grep -q "\-\-require-milestones" "$script"
}

@test "check-prerequisites.sh supports --include-milestones flag" {
    script="$REPO_ROOT/.specify/scripts/bash/check-prerequisites.sh"
    grep -q "\-\-include-milestones" "$script"
}
