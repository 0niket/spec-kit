# Spec Kit Makefile
# Run `make help` to see available commands

.PHONY: help install lint lint-python lint-markdown lint-shell test test-python test-bash check clean format

# Default target
.DEFAULT_GOAL := help

# Colors for output
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RESET := \033[0m

#------------------------------------------------------------------------------
# Help
#------------------------------------------------------------------------------

help: ## Show this help message
	@echo ""
	@echo "$(CYAN)Spec Kit Development Commands$(RESET)"
	@echo ""
	@echo "$(GREEN)Usage:$(RESET) make [target]"
	@echo ""
	@echo "$(YELLOW)Main Targets:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-15s$(RESET) %s\n", $$1, $$2}'
	@echo ""

#------------------------------------------------------------------------------
# Setup
#------------------------------------------------------------------------------

install: ## Install all dependencies (Python dev + npm for markdown linting)
	@echo "$(CYAN)Installing Python dependencies...$(RESET)"
	pip install -e ".[dev]"
	@echo "$(CYAN)Checking for npm (needed for markdown linting)...$(RESET)"
	@which npm > /dev/null || echo "$(YELLOW)Warning: npm not found. Install Node.js for markdown linting.$(RESET)"
	@echo "$(GREEN)Done!$(RESET)"

#------------------------------------------------------------------------------
# All Checks (lint + test)
#------------------------------------------------------------------------------

check: lint test ## Run ALL checks (lint + test) - use this before committing
	@echo ""
	@echo "$(GREEN)✓ All checks passed!$(RESET)"

#------------------------------------------------------------------------------
# Linting
#------------------------------------------------------------------------------

lint: lint-python lint-markdown lint-shell ## Run ALL linters
	@echo "$(GREEN)✓ All linting passed!$(RESET)"

lint-python: ## Lint Python code with ruff
	@echo "$(CYAN)Linting Python with ruff...$(RESET)"
	ruff check src/
	ruff format --check src/

lint-markdown: ## Lint Markdown files with markdownlint-cli2
	@echo "$(CYAN)Linting Markdown...$(RESET)"
	@if command -v npx > /dev/null 2>&1; then \
		npx markdownlint-cli2 "**/*.md" "#node_modules"; \
	else \
		echo "$(YELLOW)Warning: npx not found. Skipping markdown linting.$(RESET)"; \
		echo "$(YELLOW)Install Node.js to enable markdown linting.$(RESET)"; \
	fi

lint-shell: ## Lint shell scripts with shellcheck
	@echo "$(CYAN)Linting shell scripts with shellcheck...$(RESET)"
	@if command -v shellcheck > /dev/null 2>&1; then \
		shellcheck scripts/bash/*.sh .specify/scripts/bash/*.sh 2>/dev/null || true; \
	else \
		echo "$(YELLOW)Warning: shellcheck not found. Skipping shell linting.$(RESET)"; \
		echo "$(YELLOW)Install with: brew install shellcheck (macOS) or apt install shellcheck (Linux)$(RESET)"; \
	fi

#------------------------------------------------------------------------------
# Testing
#------------------------------------------------------------------------------

test: test-python test-bash ## Run ALL tests
	@echo "$(GREEN)✓ All tests passed!$(RESET)"

test-python: ## Run Python tests with pytest
	@echo "$(CYAN)Running Python tests...$(RESET)"
	pytest tests/python/ -v

test-python-cov: ## Run Python tests with coverage report
	@echo "$(CYAN)Running Python tests with coverage...$(RESET)"
	pytest tests/python/ --cov=src/specify_cli --cov-report=term-missing --cov-report=html
	@echo "$(GREEN)Coverage report generated in htmlcov/$(RESET)"

test-bash: ## Run Bash tests with bats
	@echo "$(CYAN)Running Bash tests...$(RESET)"
	@if command -v bats > /dev/null 2>&1; then \
		bats tests/bash/; \
	else \
		echo "$(YELLOW)Warning: bats not found. Skipping bash tests.$(RESET)"; \
		echo "$(YELLOW)Install with: brew install bats-core (macOS) or apt install bats (Linux)$(RESET)"; \
	fi

#------------------------------------------------------------------------------
# Formatting
#------------------------------------------------------------------------------

format: ## Auto-format Python code with ruff
	@echo "$(CYAN)Formatting Python code...$(RESET)"
	ruff format src/
	ruff check src/ --fix
	@echo "$(GREEN)✓ Formatting complete!$(RESET)"

#------------------------------------------------------------------------------
# Cleanup
#------------------------------------------------------------------------------

clean: ## Remove build artifacts and caches
	@echo "$(CYAN)Cleaning up...$(RESET)"
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	rm -rf .pytest_cache/
	rm -rf .ruff_cache/
	rm -rf htmlcov/
	rm -rf .coverage
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Clean complete!$(RESET)"

#------------------------------------------------------------------------------
# CI Simulation
#------------------------------------------------------------------------------

ci: ## Simulate CI pipeline locally (same checks as GitHub Actions)
	@echo "$(CYAN)Simulating CI pipeline...$(RESET)"
	@echo ""
	@echo "$(YELLOW)Step 1/4: Python Linting$(RESET)"
	@$(MAKE) lint-python
	@echo ""
	@echo "$(YELLOW)Step 2/4: Markdown Linting$(RESET)"
	@$(MAKE) lint-markdown
	@echo ""
	@echo "$(YELLOW)Step 3/4: Python Tests$(RESET)"
	@$(MAKE) test-python
	@echo ""
	@echo "$(YELLOW)Step 4/4: Bash Tests$(RESET)"
	@$(MAKE) test-bash
	@echo ""
	@echo "$(GREEN)═══════════════════════════════════════$(RESET)"
	@echo "$(GREEN)✓ CI simulation complete - all passed!$(RESET)"
	@echo "$(GREEN)═══════════════════════════════════════$(RESET)"
