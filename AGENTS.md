# AGENTS.md — opencode-style workflow

This repo follows https://github.com/anomalyco/opencode conventions, mirrored into pi.

## Modes (Tab equivalent)

- `/build` — default, full-access agent for development work
- `/plan` — read-only agent for analysis. Denies edits, asks before bash.
- `/explore <thoroughness>` — fast codebase search: Glob, Grep, Read. `quick` / `medium` / `very thorough`. Returns absolute paths. No writes.
- `/general` — multi-step research subagent, parallel where possible.

## Branch Names

Short, max three words, hyphens. No slashes or type prefixes.

Examples: `session-recovery`, `fix-scroll-state`, `regenerate-sdk`.

## Commits and PR Titles

Conventional: `type(scope): summary`. Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`.

## Style Guide

- Keep things in one function unless composable or reusable.
- No single-use helpers preemptively. Inline unless reused or hiding complexity.
- Prefer `const`, early returns, no `else`. Functional array methods over loops.
- No emojis in communication. Concise output, absolute file paths.
- Read-only by default in plan mode: Glob/Grep/Read first, Bash ask-first.
