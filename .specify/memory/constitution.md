<!--
Sync Impact Report
==================
Version change: 1.1.0 → 1.2.0 (MINOR - added documentation maintenance principle)
Modified principles:
  - III. CI/CD Enforcement: Added strict commit blocking rules (v1.1.0)
  - VI. Documentation Maintenance: NEW - requires README sync with code changes
Added sections:
  - Strict Enforcement Policy (v1.1.0)
  - Principle VI: Documentation Maintenance (v1.2.0)
Removed sections: N/A
Templates requiring updates:
  - All templates remain compatible
Follow-up TODOs: None
-->

# Spec Kit Constitution

## Core Principles

### I. Code Quality Through Linting

All code MUST pass automated linting before merge. This is NON-NEGOTIABLE.

**Requirements**:

- Python code MUST be linted with `ruff` (configured in `pyproject.toml`)
- Shell scripts (bash) MUST be linted with `shellcheck`
- PowerShell scripts MUST pass `PSScriptAnalyzer` checks
- Markdown MUST pass `markdownlint-cli2`
- YAML MUST be validated for syntax correctness

**Implemented Tools**:

- `ruff check src/` - Python linting
- `ruff format --check src/` - Python formatting verification
- `shellcheck scripts/bash/*.sh` - Bash linting
- `PSScriptAnalyzer` - PowerShell linting

**Rationale**: Consistent code style reduces cognitive load during review, catches common bugs early, and maintains professional quality across contributors.

### II. Test Coverage for Scripts

All executable code MUST have automated tests. No exceptions for "simple" scripts.

**Requirements**:

- Python CLI (`src/specify_cli/`) MUST have unit tests using `pytest`
- Bash scripts (`scripts/bash/`) MUST have tests using `bats-core`
- PowerShell scripts (`scripts/powershell/`) MUST have tests using `Pester`
- New features MUST include tests before merge
- Bug fixes MUST include a regression test

**Implemented Test Suites**:

- `tests/python/` - pytest test suite (31+ tests)
- `tests/bash/` - bats-core test suite
- `tests/powershell/` - Pester test suite (pending)

**Rationale**: The CLI and scripts are the primary user-facing components. Untested code is a liability - bugs in `specify init` or workflow scripts directly impact user trust.

### III. CI/CD Enforcement (STRICT)

Quality gates MUST be enforced automatically in CI pipelines. **No commit shall be created without verification loops passing.**

**Requirements**:

- All linting MUST run on every PR via GitHub Actions (`lint.yml`)
- All tests MUST pass before merge is allowed (`test.yml`)
- Branch protection MUST require passing CI checks
- Failed checks MUST block merge with NO exceptions
- Release workflow (`release.yml`) includes quality gate that MUST pass before any release

**Implemented Workflows**:

| Workflow | Jobs | Enforcement |
|----------|------|-------------|
| `lint.yml` | Markdown, Python (ruff), Shell (shellcheck), PowerShell (PSScriptAnalyzer) | Required for merge |
| `test.yml` | Python (pytest, multi-version), Bash (bats) | Required for merge |
| `release.yml` | Quality gate (lint + test) → Release | Blocks release on failure |

**Rationale**: Automation ensures consistency. No human override is permitted for quality checks. If CI fails, the code does not merge. Period.

### IV. Incremental Quality Improvement

Legacy code without tests MAY exist temporarily, but new code MUST meet standards.

**Requirements**:

- New files MUST have corresponding tests
- Modified files MUST have tests added for changed functionality
- Refactored code MUST maintain or improve test coverage
- Technical debt for testing MUST be tracked in issues

**Rationale**: Spec Kit has existing untested code. Requiring immediate 100% coverage is impractical; requiring it for new work is mandatory.

### V. Cross-Platform Parity

Bash and PowerShell implementations MUST have equivalent functionality and testing.

**Requirements**:

- Every bash script in `scripts/bash/` MUST have a PowerShell equivalent in `scripts/powershell/`
- Both implementations MUST produce identical outputs for identical inputs
- Tests MUST verify parity between platforms
- New scripts MUST be implemented in both languages before merge

**Rationale**: Spec Kit supports Windows and Unix. Feature gaps between platforms frustrate users and create support burden.

### VI. Documentation Maintenance

Documentation MUST be kept in sync with code changes. Outdated documentation is worse than no documentation.

**Requirements**:

- README.md MUST be updated when adding new features, tools, or workflows
- Changes to CLI commands, options, or behavior MUST be reflected in documentation
- New development tools or processes MUST be documented in the Development section
- Constitution changes MUST be reflected in any README references to it
- PR descriptions SHOULD note documentation updates made

**Rationale**: Users and contributors rely on documentation to understand the project. Stale documentation leads to confusion, support burden, and contributor friction.

## Quality Infrastructure

This section defines the tooling that enforces the Core Principles.

### Python Tooling

| Tool | Purpose | Config File | Status |
|------|---------|-------------|--------|
| `ruff` | Linting + formatting | `pyproject.toml` | ✅ Implemented |
| `pytest` | Unit testing | `pyproject.toml` | ✅ Implemented |
| `pytest-cov` | Coverage reporting | `pyproject.toml` | ✅ Implemented |

### Shell Script Tooling

| Tool | Purpose | Config File | Status |
|------|---------|-------------|--------|
| `shellcheck` | Bash linting | CI workflow | ✅ Implemented |
| `bats-core` | Bash testing | `tests/bash/` | ✅ Implemented |

### PowerShell Tooling

| Tool | Purpose | Config File | Status |
|------|---------|-------------|--------|
| `PSScriptAnalyzer` | PowerShell linting | CI workflow | ✅ Implemented |
| `Pester` | PowerShell testing | `tests/powershell/` | ⏳ Pending |

### CI Configuration

GitHub Actions workflows:

- `lint.yml`: Runs all linters (markdown, Python, bash, PowerShell) on every push/PR
- `test.yml`: Runs all test suites (Python 3.11-3.13, bash) with coverage reporting
- `release.yml`: Quality gate MUST pass before release artifacts are created

## Development Workflow

### Before Submitting a PR

1. Run linters locally:

   ```bash
   ruff check src/
   ruff format --check src/
   shellcheck scripts/bash/*.sh
   ```

2. Run tests locally:

   ```bash
   pytest tests/python/ -v
   bats tests/bash/
   ```

3. Verify both bash and PowerShell scripts if modifying either
4. Ensure no `NEEDS CLARIFICATION` markers remain in specs

### Code Review Checklist

Reviewers MUST verify:

- [ ] All CI checks pass (lint + test) - **MANDATORY, NO EXCEPTIONS**
- [ ] New code has corresponding tests
- [ ] Cross-platform parity maintained (if applicable)
- [ ] No hardcoded paths or platform-specific assumptions without guards
- [ ] Error messages are clear and actionable

### Commit Standards

- Commits MUST be atomic (one logical change per commit)
- Commit messages MUST follow conventional format: `type: description`
- Types: `feat`, `fix`, `docs`, `test`, `refactor`, `ci`, `chore`
- Commits MUST NOT be created if linting or tests fail locally

## Governance

This constitution supersedes informal practices and ad-hoc decisions. All contributors MUST adhere to these principles.

### Strict Enforcement Policy

**NO COMMIT SHALL BE MERGED WITHOUT:**

1. All lint checks passing (ruff, shellcheck, PSScriptAnalyzer, markdownlint)
2. All test suites passing (pytest, bats)
3. Code review approval from at least one maintainer

**NO RELEASE SHALL BE CREATED WITHOUT:**

1. Quality gate job passing in `release.yml`
2. All prior PR checks having passed

**VIOLATIONS:**

- PRs with failing CI checks MUST NOT be merged under any circumstances
- Force-merging past failed checks is a governance violation
- Repeated violations result in contributor access review

### Amendment Process

1. Propose changes via PR modifying this file
2. Changes require maintainer approval
3. MAJOR changes (principle removal/redefinition) require discussion issue first
4. All amendments MUST update version and `Last Amended` date

### Versioning Policy

- **MAJOR**: Backward-incompatible principle changes (removal, redefinition)
- **MINOR**: New principles, sections, or enforcement rules added
- **PATCH**: Clarifications, typo fixes, non-semantic changes

### Compliance

- PRs MUST NOT be merged if they violate Core Principles
- There are NO exceptions to CI enforcement
- Manual overrides of branch protection are prohibited

**Version**: 1.2.0 | **Ratified**: 2025-12-05 | **Last Amended**: 2025-12-10
