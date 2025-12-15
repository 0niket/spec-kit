#!/usr/bin/env bats

# Tests for interactive prompt functions
# Following TDD: These tests are written BEFORE implementation

setup() {
    TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    REPO_ROOT="$(cd "$TEST_DIR/../.." && pwd)"
    PROMPTS_SCRIPT="$REPO_ROOT/.specify/scripts/bash/interactive-prompts.sh"

    # Source the script if it exists (will fail initially - RED state)
    if [[ -f "$PROMPTS_SCRIPT" ]]; then
        source "$PROMPTS_SCRIPT"
    fi
}

# T004: Test prompt_ticket_id function
@test "prompt_ticket_id returns valid ticket ID" {
    # Implementation complete - testing GREEN state
    # This test will fail until T013 implements the function

    # Simulate user input "abc123xy"
    result=$(echo "abc123xy" | prompt_ticket_id)
    [ "$result" = "abc123xy" ]
}

@test "prompt_ticket_id recognizes skip keyword" {
    # Implementation complete - testing GREEN state

    # Test "skip" keyword
    result=$(echo "skip" | prompt_ticket_id)
    [ "$result" = "SKIP" ]

    # Test "none" keyword
    result=$(echo "none" | prompt_ticket_id)
    [ "$result" = "SKIP" ]

    # Test "n" keyword
    result=$(echo "n" | prompt_ticket_id)
    [ "$result" = "SKIP" ]
}

@test "prompt_ticket_id validates ticket ID format" {
    # Implementation complete - testing GREEN state

    # Valid format
    result=$(echo "PROJECT-123" | prompt_ticket_id)
    [ "$?" -eq 0 ]

    # Invalid format with special chars should be sanitized
    result=$(echo "abc@123" | prompt_ticket_id)
    [ "$?" -ne 0 ] || [[ "$result" =~ ^[a-zA-Z0-9-]+$ ]]
}

# T005: Test prompt_short_name function
@test "prompt_short_name accepts suggestion on empty input" {
    # Implementation complete - testing GREEN state

    # Empty input should return the suggestion
    result=$(echo "" | prompt_short_name "oauth2-user-auth")
    [ "$result" = "oauth2-user-auth" ]
}

@test "prompt_short_name accepts custom name" {
    # Implementation complete - testing GREEN state

    # Custom input should override suggestion
    result=$(echo "my-custom-name" | prompt_short_name "oauth2-user-auth")
    [ "$result" = "my-custom-name" ]
}

@test "prompt_short_name validates format" {
    # Implementation complete - testing GREEN state

    # Valid format (alphanumeric + hyphens)
    result=$(echo "valid-name-123" | prompt_short_name "suggestion")
    [ "$?" -eq 0 ]
    [ "$result" = "valid-name-123" ]

    # Invalid format should be rejected
    run bash -c "source '$PROMPTS_SCRIPT'; echo 'invalid name!' | prompt_short_name 'suggestion'"
    [ "$status" -ne 0 ]
}

# T006: Test detect_cancellation function
@test "detect_cancellation recognizes cancel keywords" {
    # Implementation complete - testing GREEN state

    # detect_cancellation exits with 130, so we need to run in subshell
    run bash -c "source '$PROMPTS_SCRIPT'; detect_cancellation 'cancel'"
    [ "$status" -eq 130 ]

    run bash -c "source '$PROMPTS_SCRIPT'; detect_cancellation 'quit'"
    [ "$status" -eq 130 ]

    run bash -c "source '$PROMPTS_SCRIPT'; detect_cancellation 'exit'"
    [ "$status" -eq 130 ]

    run bash -c "source '$PROMPTS_SCRIPT'; detect_cancellation 'abort'"
    [ "$status" -eq 130 ]
}

@test "detect_cancellation is case-insensitive" {
    # Implementation complete - testing GREEN state

    run bash -c "source '$PROMPTS_SCRIPT'; detect_cancellation 'CANCEL'"
    [ "$status" -eq 130 ]

    run bash -c "source '$PROMPTS_SCRIPT'; detect_cancellation 'Quit'"
    [ "$status" -eq 130 ]
}

@test "detect_cancellation returns false for normal input" {
    # Implementation complete - testing GREEN state

    detect_cancellation "abc123" && exit_code=$? || exit_code=$?
    [ "$exit_code" -eq 0 ]

    detect_cancellation "my-feature" && exit_code=$? || exit_code=$?
    [ "$exit_code" -eq 0 ]
}

# T007: Test sanitize_input function
@test "sanitize_input removes special characters" {
    # Implementation complete - testing GREEN state

    result=$(sanitize_input "abc@123#xyz")
    [ "$result" = "abc123xyz" ]
}

@test "sanitize_input preserves hyphens" {
    # Implementation complete - testing GREEN state

    result=$(sanitize_input "abc-123-xyz")
    [ "$result" = "abc-123-xyz" ]
}

@test "sanitize_input preserves alphanumeric" {
    # Implementation complete - testing GREEN state

    result=$(sanitize_input "Project123")
    [ "$result" = "Project123" ]
}

@test "sanitize_input handles empty input" {
    # Implementation complete - testing GREEN state

    result=$(sanitize_input "")
    [ "$result" = "" ]
}
