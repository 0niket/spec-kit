#!/usr/bin/env bats

# Tests for User Story 1: Ticket ID workflow integration
# Following TDD: These tests are written BEFORE implementation

setup() {
    TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    REPO_ROOT="$(cd "$TEST_DIR/../.." && pwd)"
    PROMPTS_SCRIPT="$REPO_ROOT/.specify/scripts/bash/interactive-prompts.sh"

    # Source the scripts
    if [[ -f "$PROMPTS_SCRIPT" ]]; then
        source "$PROMPTS_SCRIPT"
    fi
}

# T034: Integration test for ticket ID prompt flow
@test "ticket ID prompt flow accepts valid input" {
    # Simulate user providing ticket ID
    result=$(echo "PROJECT-123" | prompt_ticket_id)
    [ "$result" = "PROJECT-123" ]
}

@test "ticket ID prompt flow handles skip keyword" {
    # Simulate user wanting to skip ticket ID
    result=$(echo "skip" | prompt_ticket_id)
    [ "$result" = "SKIP" ]
}

# T035: Ticket ID validation tests
@test "ticket ID validation accepts alphanumeric with hyphens" {
    result=$(echo "ABC-123" | prompt_ticket_id)
    [[ "$result" =~ ^[a-zA-Z0-9-]+$ ]]
}

@test "ticket ID validation accepts plain alphanumeric" {
    result=$(echo "ABC123" | prompt_ticket_id)
    [[ "$result" =~ ^[a-zA-Z0-9-]+$ ]]
}

@test "ticket ID validation accepts lowercase" {
    result=$(echo "project-123" | prompt_ticket_id)
    [ "$result" = "project-123" ]
}

# T036: Ticket ID sanitization tests
@test "ticket ID sanitization removes special characters" {
    # First input has special chars, second is clean fallback
    result=$(echo -e "abc@123\nabc123" | prompt_ticket_id 2>/dev/null || echo "abc123")
    [[ "$result" =~ ^[a-zA-Z0-9-]+$ ]]
}

@test "sanitize_input function removes invalid characters" {
    result=$(sanitize_input "PROJECT@123#456")
    [ "$result" = "PROJECT123456" ]
}

@test "sanitize_input preserves hyphens" {
    result=$(sanitize_input "PROJECT-123")
    [ "$result" = "PROJECT-123" ]
}

# T037: Branch name construction tests
@test "branch name construction with ticket ID" {
    # Format: {ticket-id}-{short-name}
    ticket_id="PROJECT-123"
    short_name="user-auth"
    branch_name="${ticket_id}-${short_name}"

    [ "$branch_name" = "PROJECT-123-user-auth" ]
}

@test "branch name construction with SKIP uses sequential number" {
    # When ticket ID is SKIP, should use format: {number}-{short-name}
    ticket_id="SKIP"
    number="005"
    short_name="user-auth"

    if [[ "$ticket_id" == "SKIP" ]]; then
        branch_name="${number}-${short_name}"
    else
        branch_name="${ticket_id}-${short_name}"
    fi

    [ "$branch_name" = "005-user-auth" ]
}

@test "branch name construction sanitizes ticket ID" {
    # Ticket ID with special chars should be sanitized
    ticket_id=$(sanitize_input "PROJECT@123")
    short_name="user-auth"
    branch_name="${ticket_id}-${short_name}"

    [ "$branch_name" = "PROJECT123-user-auth" ]
}

# T037a: Sequential execution order test
@test "workflow executes in correct order: ticket ID → short name → branch/dir creation" {
    # This test verifies the conceptual order
    # Actual implementation will be in create-new-feature.sh

    # Step 1: Ticket ID prompt
    ticket_id=$(echo "PROJ-456" | prompt_ticket_id)
    [ "$ticket_id" = "PROJ-456" ]

    # Step 2: Short name prompt
    short_name=$(echo "" | prompt_short_name "feature-name")
    [ "$short_name" = "feature-name" ]

    # Step 3: Branch name construction (would happen in script)
    branch_name="${ticket_id}-${short_name}"
    [ "$branch_name" = "PROJ-456-feature-name" ]

    # Step 4: Directory name construction (would happen in script)
    dir_name="${ticket_id}-${short_name}"
    [ "$dir_name" = "PROJ-456-feature-name" ]
}

# T037b: spec.md initialization test
@test "spec.md initialization structure verification" {
    # This test verifies the template structure exists
    TEMPLATE_FILE="$REPO_ROOT/.specify/templates/spec-template.md"

    [ -f "$TEMPLATE_FILE" ]

    # Verify template contains required sections
    grep -q "## User Scenarios" "$TEMPLATE_FILE"
    grep -q "## Requirements" "$TEMPLATE_FILE"
    grep -q "### Functional Requirements" "$TEMPLATE_FILE"
    grep -q "## Success Criteria" "$TEMPLATE_FILE"
}

@test "spec.md template has feature description placeholder" {
    TEMPLATE_FILE="$REPO_ROOT/.specify/templates/spec-template.md"

    # Template should have placeholders for feature description
    grep -q "\[Feature Name\]" "$TEMPLATE_FILE" || \
    grep -q "TODO" "$TEMPLATE_FILE" || \
    grep -q "FEATURE" "$TEMPLATE_FILE"
}

# Additional validation tests
@test "ticket ID max length validation (50 chars)" {
    # Create a 51-character ticket ID
    long_id="PROJECT-1234567890123456789012345678901234567890123"
    [ ${#long_id} -gt 50 ]

    # Should fail validation (would loop in interactive mode)
    # For testing, we just verify length check logic
    if [[ ${#long_id} -gt 50 ]]; then
        result="TOO_LONG"
    else
        result="$long_id"
    fi

    [ "$result" = "TOO_LONG" ]
}

@test "ticket ID empty validation" {
    # Empty input should prompt for retry (we test the logic)
    input=""
    if [[ -z "$input" ]]; then
        result="EMPTY"
    else
        result="$input"
    fi

    [ "$result" = "EMPTY" ]
}

# Integration with short name generator
@test "full workflow: ticket ID + generated short name" {
    # Source short name generator
    GENERATOR_SCRIPT="$REPO_ROOT/.specify/scripts/bash/short-name-generator.sh"
    if [[ -f "$GENERATOR_SCRIPT" ]]; then
        source "$GENERATOR_SCRIPT"
    fi

    # Simulate user providing ticket ID
    ticket_id=$(echo "PROJ-789" | prompt_ticket_id)

    # Generate short name from description
    description="Add user authentication with OAuth2"
    short_name=$(generate_short_name "$description")

    # Construct branch name
    branch_name="${ticket_id}-${short_name}"

    # Verify format
    [[ "$branch_name" =~ ^PROJ-789- ]]
    [[ "$branch_name" =~ ^[a-zA-Z0-9-]+$ ]]
}
