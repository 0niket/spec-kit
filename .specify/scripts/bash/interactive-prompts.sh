#!/usr/bin/env bash
# interactive-prompts.sh - Interactive prompt handling functions
#
# Functions for handling user prompts during /speckit.specify workflow
# Supports ticket ID input, short name prompts, cancellation detection

set -euo pipefail

# prompt_ticket_id - Prompt user for ticket ID with skip option
#
# Returns:
#   - Valid ticket ID string (sanitized)
#   - "SKIP" if user wants to skip
#   - Exits with 130 if user cancels
#
# Usage: ticket_id=$(prompt_ticket_id)
prompt_ticket_id() {
    local input

    while true; do
        read -r -p "Enter ticket ID (or type 'skip'/'none'/'n' to auto-generate number): " input

        # Check for cancellation
        detect_cancellation "$input" || true

        # Convert to lowercase for keyword matching
        local input_lower
        input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')

        # Check for skip keywords
        if [[ "$input_lower" =~ ^(skip|none|n)$ ]]; then
            echo "SKIP"
            return 0
        fi

        # Validate and sanitize ticket ID
        if [[ -z "$input" ]]; then
            echo "Error: Ticket ID cannot be empty. Use 'skip' to auto-generate." >&2
            continue
        fi

        # Check format (alphanumeric + hyphens only)
        if [[ ! "$input" =~ ^[a-zA-Z0-9-]+$ ]]; then
            echo "Error: Ticket ID can only contain letters, numbers, and hyphens" >&2
            echo "Invalid characters will be removed" >&2
            input=$(sanitize_input "$input")
            if [[ -z "$input" ]]; then
                echo "Error: No valid characters remain after sanitization" >&2
                continue
            fi
        fi

        # Check max length (50 chars)
        if [[ ${#input} -gt 50 ]]; then
            echo "Error: Ticket ID too long (max 50 characters)" >&2
            continue
        fi

        echo "$input"
        return 0
    done
}

# prompt_short_name - Prompt user for short feature name
#
# Args:
#   $1 - Suggested short name
#
# Returns:
#   - Suggested name if user presses Enter
#   - Custom name if user provides one
#   - Exits with 130 if user cancels
#
# Usage: short_name=$(prompt_short_name "suggested-name")
prompt_short_name() {
    local suggestion="$1"
    local input

    # Check if running in interactive mode (TTY)
    if [[ -t 0 ]]; then
        echo "Suggested short name: $suggestion" >&2
        read -r -p "Press Enter to accept, or type your own: " input
    else
        # Non-interactive mode (for testing) - read from stdin
        read -r input
    fi

    # Check for cancellation
    detect_cancellation "$input" || true

    # If empty, use suggestion
    if [[ -z "$input" ]]; then
        echo "$suggestion"
        return 0
    fi

    # Validate custom name
    if [[ ! "$input" =~ ^[a-zA-Z0-9-]+$ ]]; then
        echo "Error: Short name can only contain letters, numbers, and hyphens" >&2
        return 1
    fi

    echo "$input"
    return 0
}

# detect_cancellation - Check if input is a cancellation keyword
#
# Args:
#   $1 - User input to check
#
# Returns:
#   - Exits with 130 if cancellation detected
#   - Returns 0 otherwise
#
# Usage: detect_cancellation "$user_input"
detect_cancellation() {
    local input="$1"
    local input_lower
    input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')

    if [[ "$input_lower" =~ ^(cancel|quit|exit|abort)$ ]]; then
        echo "Operation cancelled by user" >&2
        exit 130
    fi

    return 0
}

# sanitize_input - Remove invalid characters from input
#
# Args:
#   $1 - Input string to sanitize
#
# Returns:
#   - Sanitized string (only alphanumeric + hyphens)
#
# Usage: clean=$(sanitize_input "abc@123")
sanitize_input() {
    local input="$1"

    # Remove all characters except alphanumeric and hyphens
    echo "${input//[^a-zA-Z0-9-]/}"
}
