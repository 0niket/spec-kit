# spec-kit Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-12-11

## Active Technologies

- Markdown (slash commands), Bash 5.x (scripts), Python 3.11+ (CLI utilities if needed) + Existing Spec Kit infrastructure (check-prerequisites.sh, common.sh), Claude Code slash command system (001-commit-based-tasks)

## Project Structure

```text
src/
tests/
```

## Commands

```bash
# Development commands
make check      # Run linting and tests (required before commit)
make lint       # Run all linters
make test       # Run all tests
pytest          # Run Python tests
bats tests/bash/ # Run Bash tests
ruff check src/ # Python linting
shellcheck scripts/bash/*.sh  # Bash linting
```

## Code Style

Markdown (slash commands), Bash 5.x (scripts), Python 3.11+ (CLI utilities if needed): Follow standard conventions

## Recent Changes

- 001-commit-based-tasks: Added Markdown (slash commands), Bash 5.x (scripts), Python 3.11+ (CLI utilities if needed) + Existing Spec Kit infrastructure (check-prerequisites.sh, common.sh), Claude Code slash command system

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
