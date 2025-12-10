# Spec Kit Makefile
# Run `make help` to see available commands

.PHONY: help install install-tools lint lint-python lint-markdown lint-shell test test-python test-bash check clean format

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

install: ## Install Python dev dependencies
	@echo "$(CYAN)Installing Python dependencies...$(RESET)"
	pip install -e ".[dev]"
	@echo "$(GREEN)Done! Run 'make install-tools' to install linting/testing tools.$(RESET)"

install-tools: ## Install all dev tools (shellcheck, bats, npm for markdownlint)
	@echo "$(CYAN)Installing development tools...$(RESET)"
	@echo ""
	@# Detect OS and install accordingly
	@if [ "$$(uname)" = "Darwin" ]; then \
		echo "$(CYAN)Detected macOS - using Homebrew...$(RESET)"; \
		if command -v brew > /dev/null 2>&1; then \
			echo "Installing shellcheck..."; \
			brew install shellcheck 2>/dev/null || echo "shellcheck already installed"; \
			echo "Installing bats-core..."; \
			brew install bats-core 2>/dev/null || echo "bats-core already installed"; \
		else \
			echo "$(YELLOW)Homebrew not found. Install from https://brew.sh$(RESET)"; \
		fi; \
	elif [ -f /etc/debian_version ]; then \
		echo "$(CYAN)Detected Debian/Ubuntu - using apt...$(RESET)"; \
		sudo apt-get update && sudo apt-get install -y shellcheck bats; \
	elif [ -f /etc/fedora-release ]; then \
		echo "$(CYAN)Detected Fedora - using dnf...$(RESET)"; \
		sudo dnf install -y ShellCheck bats; \
	else \
		echo "$(YELLOW)Unknown OS. Please install manually:$(RESET)"; \
		echo "  - shellcheck: https://github.com/koalaman/shellcheck"; \
		echo "  - bats-core: https://github.com/bats-core/bats-core"; \
	fi
	@echo ""
	@echo "$(CYAN)Checking for Node.js/npm (needed for markdown linting)...$(RESET)"
	@if command -v npm > /dev/null 2>&1; then \
		echo "$(GREEN)✓ npm found$(RESET)"; \
	else \
		echo "$(YELLOW)npm not found. Install Node.js from https://nodejs.org$(RESET)"; \
	fi
	@echo ""
	@echo "$(GREEN)Tool installation complete!$(RESET)"
	@echo ""
	@echo "$(CYAN)Installed tools status:$(RESET)"
	@command -v shellcheck > /dev/null 2>&1 && echo "  $(GREEN)✓$(RESET) shellcheck" || echo "  $(YELLOW)✗$(RESET) shellcheck (missing)"
	@command -v bats > /dev/null 2>&1 && echo "  $(GREEN)✓$(RESET) bats" || echo "  $(YELLOW)✗$(RESET) bats (missing)"
	@command -v npx > /dev/null 2>&1 && echo "  $(GREEN)✓$(RESET) npx (markdownlint)" || echo "  $(YELLOW)✗$(RESET) npx (missing)"
	@command -v ruff > /dev/null 2>&1 && echo "  $(GREEN)✓$(RESET) ruff" || echo "  $(YELLOW)✗$(RESET) ruff (run 'make install')"
	@command -v pytest > /dev/null 2>&1 && echo "  $(GREEN)✓$(RESET) pytest" || echo "  $(YELLOW)✗$(RESET) pytest (run 'make install')"

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
		shellcheck --severity=warning scripts/bash/*.sh; \
		shellcheck --severity=warning .specify/scripts/bash/*.sh 2>/dev/null || true; \
	else \
		echo "$(YELLOW)Error: shellcheck not found.$(RESET)"; \
		echo "$(YELLOW)Run 'make install-tools' or install manually:$(RESET)"; \
		echo "$(YELLOW)  brew install shellcheck (macOS)$(RESET)"; \
		echo "$(YELLOW)  apt install shellcheck (Linux)$(RESET)"; \
		exit 1; \
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
		echo "$(YELLOW)Error: bats not found.$(RESET)"; \
		echo "$(YELLOW)Run 'make install-tools' or install manually:$(RESET)"; \
		echo "$(YELLOW)  brew install bats-core (macOS)$(RESET)"; \
		echo "$(YELLOW)  apt install bats (Linux)$(RESET)"; \
		exit 1; \
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
