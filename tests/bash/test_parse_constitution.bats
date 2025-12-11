#!/usr/bin/env bats

# Tests for parse-constitution.sh script
# Following TDD: These tests are written FIRST, before implementation

setup() {
    # Get the repository root
    REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"
    SCRIPT_PATH="$REPO_ROOT/.specify/scripts/bash/parse-constitution.sh"
    TEST_CONSTITUTION="$BATS_TEST_TMPDIR/test_constitution.md"

    # Create a test constitution file with known content
    cat > "$TEST_CONSTITUTION" << 'EOF'
# Test Constitution

## Core Principles

### VII. Test-Driven Development (TDD)

All new code MUST follow the **Red-Green-Refactor** workflow.

**Requirements**:

- **RED**: Write a failing test BEFORE writing implementation code
- **GREEN**: Write the minimum code necessary to make the test pass
- **REFACTOR**: Clean up the code while keeping all tests green
- `make check` MUST pass before any commit is created

### I. Code Quality Through Linting

**Requirements**:

- Python code MUST be linted with `ruff`
- Shell scripts (bash) MUST be linted with `shellcheck`
- Markdown MUST pass `markdownlint-cli2`

### III. CI/CD Enforcement

- **`make check` MUST pass locally before any commit is created**
EOF
}

teardown() {
    rm -f "$TEST_CONSTITUTION"
}

@test "parse-constitution.sh exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "parse-constitution.sh outputs JSON format" {
    run "$SCRIPT_PATH" "$TEST_CONSTITUTION"
    [ "$status" -eq 0 ]
    # Output should be valid JSON (starts with { or [)
    [[ "$output" =~ ^\{ ]] || [[ "$output" =~ ^\[ ]]
}

@test "parse-constitution.sh detects TDD requirements" {
    run "$SCRIPT_PATH" "$TEST_CONSTITUTION"
    [ "$status" -eq 0 ]
    # Should contain TDD-related keys
    [[ "$output" =~ "tdd" ]] || [[ "$output" =~ "TDD" ]]
}

@test "parse-constitution.sh detects linting requirements for bash" {
    run "$SCRIPT_PATH" "$TEST_CONSTITUTION"
    [ "$status" -eq 0 ]
    # Should detect shellcheck requirement
    [[ "$output" =~ "shellcheck" ]] || [[ "$output" =~ "bash" ]] || [[ "$output" =~ "LINT" ]]
}

@test "parse-constitution.sh detects linting requirements for python" {
    run "$SCRIPT_PATH" "$TEST_CONSTITUTION"
    [ "$status" -eq 0 ]
    # Should detect ruff requirement
    [[ "$output" =~ "ruff" ]] || [[ "$output" =~ "python" ]] || [[ "$output" =~ "LINT" ]]
}

@test "parse-constitution.sh detects make check requirement" {
    run "$SCRIPT_PATH" "$TEST_CONSTITUTION"
    [ "$status" -eq 0 ]
    # Should detect make check/verify requirement
    [[ "$output" =~ "make check" ]] || [[ "$output" =~ "verify" ]] || [[ "$output" =~ "VERIFY" ]]
}

@test "parse-constitution.sh handles missing file gracefully" {
    run "$SCRIPT_PATH" "/nonexistent/path/constitution.md"
    [ "$status" -ne 0 ]
}

@test "parse-constitution.sh with no arguments shows usage" {
    run "$SCRIPT_PATH"
    [ "$status" -ne 0 ]
    [[ "$output" =~ "Usage" ]] || [[ "$output" =~ "usage" ]]
}
