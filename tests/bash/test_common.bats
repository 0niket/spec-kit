#!/usr/bin/env bats
# Tests for common.sh functions

# Setup - load the script under test
setup() {
    # Get the directory containing this test file
    TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$TEST_DIR/../.." && pwd)"

    # Source the common.sh script
    source "$PROJECT_ROOT/scripts/bash/common.sh"

    # Create a temporary directory for test fixtures
    export TEST_TMP="$(mktemp -d)"
}

# Teardown - clean up after each test
teardown() {
    if [[ -d "$TEST_TMP" ]]; then
        rm -rf "$TEST_TMP"
    fi
}

# =============================================================================
# Tests for get_repo_root
# =============================================================================

@test "get_repo_root returns git root when in git repo" {
    # This test runs from within the spec-kit repo, so it should find the root
    result="$(get_repo_root)"
    [[ -d "$result" ]]
    [[ -f "$result/pyproject.toml" ]]
}

@test "get_repo_root falls back to script location for non-git repos" {
    # Create a non-git directory structure mimicking the expected layout
    mkdir -p "$TEST_TMP/project/.specify/scripts/bash"

    # Create a minimal common.sh in the temp location
    cat > "$TEST_TMP/project/.specify/scripts/bash/common.sh" << 'SCRIPT'
#!/usr/bin/env bash
get_repo_root() {
    if git rev-parse --show-toplevel >/dev/null 2>&1; then
        git rev-parse --show-toplevel
    else
        local script_dir="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        (cd "$script_dir/../../.." && pwd)
    fi
}
SCRIPT

    # Source and test from non-git location
    (
        cd "$TEST_TMP/project/.specify/scripts/bash"
        source ./common.sh
        result="$(get_repo_root)"
        [[ "$result" == "$TEST_TMP/project" ]]
    )
}

# =============================================================================
# Tests for get_current_branch
# =============================================================================

@test "get_current_branch uses SPECIFY_FEATURE env var when set" {
    export SPECIFY_FEATURE="001-test-feature"
    result="$(get_current_branch)"
    [[ "$result" == "001-test-feature" ]]
    unset SPECIFY_FEATURE
}

@test "get_current_branch returns branch name in git repo" {
    # We're in a git repo, should return actual branch
    result="$(get_current_branch)"
    [[ -n "$result" ]]
}

@test "get_current_branch finds latest feature dir in non-git repo" {
    # Create mock specs directory
    mkdir -p "$TEST_TMP/specs/001-first-feature"
    mkdir -p "$TEST_TMP/specs/002-second-feature"
    mkdir -p "$TEST_TMP/specs/003-third-feature"
    mkdir -p "$TEST_TMP/.specify/scripts/bash"

    # Create minimal common.sh
    cat > "$TEST_TMP/.specify/scripts/bash/common.sh" << 'SCRIPT'
#!/usr/bin/env bash
get_repo_root() {
    local script_dir="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    (cd "$script_dir/../../.." && pwd)
}
get_current_branch() {
    if [[ -n "${SPECIFY_FEATURE:-}" ]]; then
        echo "$SPECIFY_FEATURE"
        return
    fi
    if git rev-parse --abbrev-ref HEAD >/dev/null 2>&1; then
        git rev-parse --abbrev-ref HEAD
        return
    fi
    local repo_root=$(get_repo_root)
    local specs_dir="$repo_root/specs"
    if [[ -d "$specs_dir" ]]; then
        local latest_feature=""
        local highest=0
        for dir in "$specs_dir"/*; do
            if [[ -d "$dir" ]]; then
                local dirname=$(basename "$dir")
                if [[ "$dirname" =~ ^([0-9]{3})- ]]; then
                    local number=${BASH_REMATCH[1]}
                    number=$((10#$number))
                    if [[ "$number" -gt "$highest" ]]; then
                        highest=$number
                        latest_feature=$dirname
                    fi
                fi
            fi
        done
        if [[ -n "$latest_feature" ]]; then
            echo "$latest_feature"
            return
        fi
    fi
    echo "main"
}
SCRIPT

    (
        cd "$TEST_TMP/.specify/scripts/bash"
        source ./common.sh
        result="$(get_current_branch)"
        [[ "$result" == "003-third-feature" ]]
    )
}

# =============================================================================
# Tests for has_git
# =============================================================================

@test "has_git returns true in git repository" {
    # We're running from spec-kit which is a git repo
    has_git
}

@test "has_git returns false outside git repository" {
    (
        cd "$TEST_TMP"
        ! has_git
    )
}

# =============================================================================
# Tests for check_feature_branch
# =============================================================================

@test "check_feature_branch accepts valid feature branch" {
    check_feature_branch "001-my-feature" "true"
}

@test "check_feature_branch accepts three-digit prefix" {
    check_feature_branch "123-feature-name" "true"
}

@test "check_feature_branch rejects main branch" {
    run check_feature_branch "main" "true"
    [[ "$status" -eq 1 ]]
}

@test "check_feature_branch rejects branch without numeric prefix" {
    run check_feature_branch "feature-without-number" "true"
    [[ "$status" -eq 1 ]]
}

@test "check_feature_branch skips validation for non-git repos" {
    run check_feature_branch "anything" "false"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Warning"* ]]
}

# =============================================================================
# Tests for get_feature_dir
# =============================================================================

@test "get_feature_dir constructs correct path" {
    result="$(get_feature_dir "/repo" "001-feature")"
    [[ "$result" == "/repo/specs/001-feature" ]]
}

@test "get_feature_dir handles spaces in repo path" {
    result="$(get_feature_dir "/path/to/my repo" "001-feature")"
    [[ "$result" == "/path/to/my repo/specs/001-feature" ]]
}

# =============================================================================
# Tests for find_feature_dir_by_prefix
# =============================================================================

@test "find_feature_dir_by_prefix finds matching directory" {
    mkdir -p "$TEST_TMP/specs/001-original-feature"

    result="$(find_feature_dir_by_prefix "$TEST_TMP" "001-different-branch")"
    [[ "$result" == "$TEST_TMP/specs/001-original-feature" ]]
}

@test "find_feature_dir_by_prefix returns branch path when no match" {
    mkdir -p "$TEST_TMP/specs"

    result="$(find_feature_dir_by_prefix "$TEST_TMP" "001-nonexistent")"
    [[ "$result" == "$TEST_TMP/specs/001-nonexistent" ]]
}

@test "find_feature_dir_by_prefix falls back for non-numeric branch" {
    mkdir -p "$TEST_TMP/specs"

    result="$(find_feature_dir_by_prefix "$TEST_TMP" "main")"
    [[ "$result" == "$TEST_TMP/specs/main" ]]
}

# =============================================================================
# Tests for check_file and check_dir
# =============================================================================

@test "check_file reports existing file with checkmark" {
    touch "$TEST_TMP/testfile"
    result="$(check_file "$TEST_TMP/testfile" "Test File")"
    [[ "$result" == *"✓"* ]]
    [[ "$result" == *"Test File"* ]]
}

@test "check_file reports missing file with X" {
    result="$(check_file "$TEST_TMP/nonexistent" "Missing File")"
    [[ "$result" == *"✗"* ]]
    [[ "$result" == *"Missing File"* ]]
}

@test "check_dir reports non-empty directory with checkmark" {
    mkdir -p "$TEST_TMP/testdir"
    touch "$TEST_TMP/testdir/file"
    result="$(check_dir "$TEST_TMP/testdir" "Test Dir")"
    [[ "$result" == *"✓"* ]]
}

@test "check_dir reports empty directory with X" {
    mkdir -p "$TEST_TMP/emptydir"
    result="$(check_dir "$TEST_TMP/emptydir" "Empty Dir")"
    [[ "$result" == *"✗"* ]]
}

@test "check_dir reports missing directory with X" {
    result="$(check_dir "$TEST_TMP/nonexistent" "Missing Dir")"
    [[ "$result" == *"✗"* ]]
}

# =============================================================================
# Tests for get_feature_paths
# =============================================================================

@test "get_feature_paths outputs all required variables" {
    output="$(get_feature_paths)"

    [[ "$output" == *"REPO_ROOT="* ]]
    [[ "$output" == *"CURRENT_BRANCH="* ]]
    [[ "$output" == *"HAS_GIT="* ]]
    [[ "$output" == *"FEATURE_DIR="* ]]
    [[ "$output" == *"FEATURE_SPEC="* ]]
    [[ "$output" == *"IMPL_PLAN="* ]]
    [[ "$output" == *"TASKS="* ]]
    [[ "$output" == *"RESEARCH="* ]]
    [[ "$output" == *"DATA_MODEL="* ]]
    [[ "$output" == *"QUICKSTART="* ]]
    [[ "$output" == *"CONTRACTS_DIR="* ]]
}

@test "get_feature_paths can be eval'd safely" {
    eval "$(get_feature_paths)"

    [[ -n "$REPO_ROOT" ]]
    [[ -n "$CURRENT_BRANCH" ]]
    [[ "$HAS_GIT" == "true" || "$HAS_GIT" == "false" ]]
}
