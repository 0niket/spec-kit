# Commits: [FEATURE NAME]

**Generated**: [TIMESTAMP]
**Source**: [TASKS_PATH]
**Constitution**: [CONSTITUTION_PATH]

## Summary

- Total Commits: [COMMIT_COUNT]
- Total Tasks: [NON_REPETITIVE_COUNT] (non-repetitive) + [REPETITIVE_COUNT] (repetitive)
- Stories Covered: [STORY_LIST]

---

<!--
  TEMPLATE INSTRUCTIONS:

  This template is filled by the /speckit.commits command.

  For each commit:
  1. Replace [COMMIT_N] with sequential number (1, 2, 3...)
  2. Replace [COMMIT_MESSAGE] with conventional commit format: type(scope): description
  3. Replace [COMMIT_ID] with C### format (C001, C002...)
  4. Replace [STORY_REF] with user story reference (US1, US2...)
  5. List non-repetitive tasks from tasks.md grouped by story/file
  6. Add repetitive tasks based on constitution requirements

  Commit types: feat, fix, test, refactor, docs, chore
-->

## Commit [COMMIT_N]: [COMMIT_MESSAGE]

**ID**: [COMMIT_ID]
**Status**: pending
**Story**: [STORY_REF]
**Git SHA**: <!-- runtime: populated by /speckit.implement after commit creation -->

### Non-Repetitive Tasks

- [ ] [TASK_ID] [PRIORITY] Task description `file/path.ext`

### Repetitive Tasks

<!-- Added based on constitution requirements -->

- [ ] [TDD-RED] Write failing test for [component]
- [ ] [TDD-GREEN] Implement [component] to pass test
- [ ] [TDD-REFACTOR] Refactor [component] if needed
- [ ] [VERIFY] Run make check

---

<!-- Repeat commit sections as needed -->
