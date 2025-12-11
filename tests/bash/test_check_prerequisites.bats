#!/usr/bin/env bats

# Tests for check-prerequisites.sh enhanced flags
# Following TDD: These tests are written FIRST, before implementation

setup() {
    # Get the repository root
    TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    REPO_ROOT="$(cd "$TEST_DIR/../.." && pwd)"
    SCRIPT_PATH="$REPO_ROOT/.specify/scripts/bash/check-prerequisites.sh"

    # Use the actual repo's feature directory for testing
    # This ensures tests run in the real environment
    export TEST_FEATURE_DIR="$REPO_ROOT/specs/001-commit-based-tasks"

    # Set SPECIFY_FEATURE to ensure consistent behavior in CI
    # This bypasses git branch detection which may vary in CI environments
    export SPECIFY_FEATURE="001-commit-based-tasks"
}

teardown() {
    # Nothing to clean up when using real repo
    :
}

@test "check-prerequisites.sh exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "check-prerequisites.sh --require-commits fails when commits.md missing" {
    # This test checks the error path - commits.md doesn't exist in our test feature yet
    # The script should fail when --require-commits is set and commits.md is missing
    run "$SCRIPT_PATH" --require-commits 2>&1
    # Either exits with non-zero or outputs error about missing commits.md
    [[ "$status" -ne 0 ]] || [[ "$output" =~ "commits.md" ]]
}

@test "check-prerequisites.sh --include-commits includes commits.md when file exists" {
    # First create commits.md in our test feature
    echo "# Test Commits" > "$TEST_FEATURE_DIR/commits.md"

    run "$SCRIPT_PATH" --json --include-commits 2>&1

    [ "$status" -eq 0 ]
    # JSON output should include commits.md reference
    [[ "$output" =~ "commits.md" ]]

    # Cleanup
    rm -f "$TEST_FEATURE_DIR/commits.md"
}

@test "check-prerequisites.sh --include-milestones includes milestones.md when file exists" {
    # First create milestones.md in our test feature
    echo "# Test Milestones" > "$TEST_FEATURE_DIR/milestones.md"

    run "$SCRIPT_PATH" --json --include-milestones 2>&1

    [ "$status" -eq 0 ]
    # JSON output should include milestones.md reference
    [[ "$output" =~ "milestones.md" ]]

    # Cleanup
    rm -f "$TEST_FEATURE_DIR/milestones.md"
}

@test "check-prerequisites.sh --require-milestones fails when milestones.md missing" {
    # This test checks the error path - milestones.md doesn't exist in our test feature yet
    run "$SCRIPT_PATH" --require-milestones 2>&1
    # Either exits with non-zero or outputs error about missing milestones.md
    [[ "$status" -ne 0 ]] || [[ "$output" =~ "milestones.md" ]]
}

@test "check-prerequisites.sh combined flags work when files exist" {
    # Create both files
    echo "# Test Commits" > "$TEST_FEATURE_DIR/commits.md"
    echo "# Test Milestones" > "$TEST_FEATURE_DIR/milestones.md"

    run "$SCRIPT_PATH" --json --include-commits --include-milestones 2>&1

    [ "$status" -eq 0 ]
    # Should include both commits and milestones references
    [[ "$output" =~ "commits.md" ]]
    [[ "$output" =~ "milestones.md" ]]

    # Cleanup
    rm -f "$TEST_FEATURE_DIR/commits.md"
    rm -f "$TEST_FEATURE_DIR/milestones.md"
}
