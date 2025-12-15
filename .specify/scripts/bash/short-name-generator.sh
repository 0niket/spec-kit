#!/usr/bin/env bash
# short-name-generator.sh - Generate concise short names from feature descriptions
#
# Implements NLP-lite algorithm to extract 2-4 key terms from descriptions
# and format them as kebab-case short names

set -euo pipefail

# Stop words list - common words to filter out
readonly STOP_WORDS="the a an to for with in on at is are be this that from by of and or but not we i want need"

# Action verbs - prioritized for short names
readonly ACTION_VERBS="add fix create implement update remove delete refactor migrate deploy configure setup install uninstall enable disable"

# generate_short_name - Generate kebab-case short name from description
#
# Args:
#   $1 - Feature description
#
# Returns:
#   - Kebab-case short name (2-4 words typically)
#   - Exits with 1 if input is empty
#
# Usage: short_name=$(generate_short_name "Add user authentication")
generate_short_name() {
    local description="$1"

    # Validate input
    if [[ -z "$description" ]]; then
        echo "Error: Description cannot be empty" >&2
        return 1
    fi

    # Step 1: Tokenize
    local tokens
    tokens=$(tokenize "$description")

    # Step 2: Filter stop words
    local filtered
    # shellcheck disable=SC2119
    filtered=$(echo "$tokens" | while read -r token; do
        echo "$token"
    done | filter_stop_words)

    # If no terms remain, return fallback
    if [[ -z "$filtered" ]]; then
        echo "feature"
        return 0
    fi

    # Step 3 & 4: Prioritize and select top terms
    local prioritized
    # shellcheck disable=SC2119
    prioritized=$(echo "$filtered" | while read -r token; do
        echo "$token"
    done | prioritize_terms)

    # Select top 2-4 terms
    local -a selected=()
    local count=0
    local max_terms=4

    while IFS= read -r term; do
        if [[ $count -ge $max_terms ]]; then
            break
        fi
        selected+=("$term")
        ((count++))
    done <<< "$prioritized"

    # Ensure at least 2 terms if possible
    if [[ ${#selected[@]} -eq 1 ]]; then
        # Try to get one more term
        local second_term
        second_term=$(echo "$prioritized" | sed -n '2p')
        if [[ -n "$second_term" ]]; then
            selected+=("$second_term")
        fi
    fi

    # Step 5: Format as kebab-case
    local result
    result=$(IFS='-'; echo "${selected[*]}")

    # Convert to lowercase
    result=$(echo "$result" | tr '[:upper:]' '[:lower:]')

    echo "$result"
}

# tokenize - Split description into tokens
#
# Args:
#   $1 - Description string
#
# Returns:
#   - Array of tokens (one per line)
#
# Usage: tokens=$(tokenize "Add user auth")
tokenize() {
    local description="$1"

    # Split on whitespace and punctuation (except hyphens within words)
    # Replace punctuation with newlines, then split on whitespace
    echo "$description" | sed 's/[.,!?;:()\/ ]/ /g' | tr -s ' ' '\n' | grep -v '^$'
}

# filter_stop_words - Remove common stop words from token array
#
# Args:
#   $@ - Array of tokens OR reads from stdin if no args
#
# Returns:
#   - Filtered array (one token per line)
#
# Usage: filtered=$(filter_stop_words "${tokens[@]}")
#    or: filtered=$(echo "$tokens" | filter_stop_words)
# shellcheck disable=SC2120
filter_stop_words() {
    # Read from args or stdin
    if [[ $# -gt 0 ]]; then
        local tokens=("$@")
        for token in "${tokens[@]}"; do
            local token_lower
            token_lower=$(echo "$token" | tr '[:upper:]' '[:lower:]')

            # Check if token is in stop words list
            if ! echo " $STOP_WORDS " | grep -q " $token_lower "; then
                echo "$token"
            fi
        done
    else
        while IFS= read -r token; do
            local token_lower
            token_lower=$(echo "$token" | tr '[:upper:]' '[:lower:]')

            # Check if token is in stop words list
            if ! echo " $STOP_WORDS " | grep -q " $token_lower "; then
                echo "$token"
            fi
        done
    fi
}

# prioritize_terms - Sort tokens by importance
#
# Priority levels:
#   1. Technical terms (contains uppercase/digits)
#   2. Action verbs
#   3. Other terms
#
# Args:
#   $@ - Array of tokens OR reads from stdin if no args
#
# Returns:
#   - Prioritized array (one token per line)
#
# Usage: prioritized=$(prioritize_terms "${tokens[@]}")
#    or: prioritized=$(echo "$tokens" | prioritize_terms)
# shellcheck disable=SC2120
prioritize_terms() {
    local -a tech_terms=()
    local -a verbs=()
    local -a other=()

    # Read from args or stdin
    if [[ $# -gt 0 ]]; then
        local tokens=("$@")
        for token in "${tokens[@]}"; do
            local token_lower
            token_lower=$(echo "$token" | tr '[:upper:]' '[:lower:]')

            # Check if technical term (contains uppercase or digits in original)
            if [[ "$token" =~ [A-Z0-9] ]]; then
                tech_terms+=("$token")
            # Check if action verb
            elif echo " $ACTION_VERBS " | grep -q " $token_lower "; then
                verbs+=("$token")
            else
                other+=("$token")
            fi
        done
    else
        while IFS= read -r token; do
            local token_lower
            token_lower=$(echo "$token" | tr '[:upper:]' '[:lower:]')

            # Check if technical term (contains uppercase or digits in original)
            if [[ "$token" =~ [A-Z0-9] ]]; then
                tech_terms+=("$token")
            # Check if action verb
            elif echo " $ACTION_VERBS " | grep -q " $token_lower "; then
                verbs+=("$token")
            else
                other+=("$token")
            fi
        done
    fi

    # Output in priority order (handle empty arrays with set -u)
    if [[ ${#tech_terms[@]} -gt 0 ]]; then
        for term in "${tech_terms[@]}"; do echo "$term"; done
    fi
    if [[ ${#verbs[@]} -gt 0 ]]; then
        for term in "${verbs[@]}"; do echo "$term"; done
    fi
    if [[ ${#other[@]} -gt 0 ]]; then
        for term in "${other[@]}"; do echo "$term"; done
    fi
}
