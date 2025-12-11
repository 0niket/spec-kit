#!/usr/bin/env bash
# parse-constitution.sh - Extract repetitive tasks from constitution
#
# Usage: parse-constitution.sh <path-to-constitution.md>
#
# Outputs JSON with detected repetitive task templates based on constitution content.
# Used by /speckit.commits to inject quality tasks into each commit.

set -euo pipefail

# Show usage if no arguments
if [[ $# -lt 1 ]]; then
    echo "Usage: parse-constitution.sh <constitution-file>" >&2
    echo "  Parses constitution and outputs JSON with repetitive task templates" >&2
    exit 1
fi

CONSTITUTION_FILE="$1"

# Verify file exists
if [[ ! -f "$CONSTITUTION_FILE" ]]; then
    echo "ERROR: Constitution file not found: $CONSTITUTION_FILE" >&2
    exit 1
fi

# Read constitution content
CONTENT=$(cat "$CONSTITUTION_FILE")

# Initialize JSON output structure
echo "{"

# Detect TDD requirements
if echo "$CONTENT" | grep -qi "TDD\|Test-Driven\|Red-Green-Refactor\|RED.*GREEN.*REFACTOR"; then
    echo '  "tdd": {'
    echo '    "enabled": true,'
    echo '    "trigger": "code_change",'
    echo '    "tasks": ['
    echo '      {"id": "TDD-RED", "order": 1, "name": "Write failing test", "phase": "RED"},'
    echo '      {"id": "TDD-GREEN", "order": 2, "name": "Implement to pass test", "phase": "GREEN"},'
    echo '      {"id": "TDD-REFACTOR", "order": 3, "name": "Refactor while green", "phase": "REFACTOR"}'
    echo '    ]'
    echo '  },'
else
    echo '  "tdd": {"enabled": false},'
fi

# Detect linting requirements
echo '  "linting": {'

# Check for shellcheck/bash linting
if echo "$CONTENT" | grep -qi "shellcheck\|bash.*lint\|shell.*scripts.*MUST"; then
    echo '    "bash": {"enabled": true, "tool": "shellcheck", "trigger": "*.sh"},'
else
    echo '    "bash": {"enabled": false},'
fi

# Check for ruff/python linting
if echo "$CONTENT" | grep -qi "ruff\|python.*lint\|Python.*MUST.*lint"; then
    echo '    "python": {"enabled": true, "tool": "ruff", "trigger": "*.py"},'
else
    echo '    "python": {"enabled": false},'
fi

# Check for markdown linting
if echo "$CONTENT" | grep -qi "markdownlint\|markdown.*lint\|Markdown.*MUST"; then
    echo '    "markdown": {"enabled": true, "tool": "markdownlint-cli2", "trigger": "*.md"}'
else
    echo '    "markdown": {"enabled": false}'
fi

echo '  },'

# Detect verification requirements (make check)
if echo "$CONTENT" | grep -qi "make check\|MUST pass.*before.*commit\|verification.*loop"; then
    echo '  "verify": {'
    echo '    "enabled": true,'
    echo '    "trigger": "all",'
    echo '    "tasks": ['
    echo '      {"id": "VERIFY", "order": 99, "name": "Run make check", "command": "make check"}'
    echo '    ]'
    echo '  }'
else
    echo '  "verify": {"enabled": false}'
fi

echo "}"
