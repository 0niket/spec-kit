#!/usr/bin/env bats

# Tests for repetitive task injection from constitution
# Following TDD: These tests validate the constitution parsing outputs
# that are used by /speckit.commits to inject quality tasks

setup() {
    TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    REPO_ROOT="$(cd "$TEST_DIR/../.." && pwd)"
    PARSE_SCRIPT="$REPO_ROOT/.specify/scripts/bash/parse-constitution.sh"
    CONSTITUTION="$REPO_ROOT/.specify/memory/constitution.md"
}

@test "parse-constitution.sh outputs TDD tasks when TDD section present" {
    run "$PARSE_SCRIPT" "$CONSTITUTION"
    [ "$status" -eq 0 ]
    # Should output TDD-related task templates
    [[ "$output" =~ "TDD-RED" ]] || [[ "$output" =~ "Write failing test" ]]
}

@test "parse-constitution.sh outputs TDD enabled flag" {
    run "$PARSE_SCRIPT" "$CONSTITUTION"
    [ "$status" -eq 0 ]
    # Should indicate TDD is enabled
    [[ "$output" =~ '"enabled": true' ]] || [[ "$output" =~ '"enabled":true' ]]
}

@test "parse-constitution.sh detects shellcheck requirement for bash" {
    run "$PARSE_SCRIPT" "$CONSTITUTION"
    [ "$status" -eq 0 ]
    # Should detect bash linting with shellcheck
    [[ "$output" =~ "shellcheck" ]]
}

@test "parse-constitution.sh detects ruff requirement for python" {
    run "$PARSE_SCRIPT" "$CONSTITUTION"
    [ "$status" -eq 0 ]
    # Should detect python linting with ruff
    [[ "$output" =~ "ruff" ]]
}

@test "parse-constitution.sh detects make check verification requirement" {
    run "$PARSE_SCRIPT" "$CONSTITUTION"
    [ "$status" -eq 0 ]
    # Should detect make check requirement
    [[ "$output" =~ "make check" ]]
}

@test "parse-constitution.sh outputs valid JSON structure" {
    run "$PARSE_SCRIPT" "$CONSTITUTION"
    [ "$status" -eq 0 ]
    # Should have tdd, linting, and verify sections
    [[ "$output" =~ '"tdd"' ]]
    [[ "$output" =~ '"linting"' ]]
    [[ "$output" =~ '"verify"' ]]
}

@test "speckit.commits.md documents repetitive task injection" {
    command_file="$REPO_ROOT/.claude/commands/speckit.commits.md"
    # Should document repetitive task injection
    grep -q "Repetitive Task" "$command_file"
    grep -q "TDD" "$command_file"
    grep -q "constitution" "$command_file"
}

@test "speckit.commits.md references parse-constitution.sh" {
    command_file="$REPO_ROOT/.claude/commands/speckit.commits.md"
    grep -q "parse-constitution.sh" "$command_file"
}

@test "commits-template.md has Repetitive Tasks section" {
    template="$REPO_ROOT/.specify/templates/commits-template.md"
    grep -q "Repetitive Tasks" "$template"
    grep -q "TDD-RED" "$template"
    grep -q "TDD-GREEN" "$template"
    grep -q "VERIFY" "$template"
}
