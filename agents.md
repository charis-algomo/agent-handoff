# Project Knowledge Base

## 1. Project Overview
- **Purpose:** This repository provides `agent`, a lightweight Bash CLI for structured handoffs between AI coding tools.
- **Core problem solved:** Prevents context loss when switching between tools (e.g., Cursor → Claude Code → Cosine) by centralizing project context in `AGENTS.md` and logging timestamped handovers.
- **Target users:** Developers/teams using multiple AI agents in the same git repository.
- **Key capabilities:**
  - Initialize handoff scaffolding in any git repo (`agent init`)
  - Capture handover summaries/decisions/learnings/next steps (`agent handover`)
  - Inspect state/history (`agent status`, `agent log`)
  - Surface and log workflow recommendations (`agent recommend`)
  - Onboard new agent tools (`agent onboard`)
  - Regenerate pointers/hooks (`agent reinit`)
  - CMUX workspace management (`agent workspace`, `agent spawn`, `agent peek`, etc.)
  - Browser testing via Playwright CLI (`agent test`)
  - Global tool setup (`agent setup`)

## 2. Architecture Overview
- **Architecture style:** Single-file CLI application (`agent`) with function-based command dispatch.
- **Main components:**
  - **Core command handlers:** `cmd_init`, `cmd_handover`, `cmd_status`, `cmd_log`, `cmd_onboard`, `cmd_reinit`, `cmd_recommend`, `cmd_help`
  - **CMUX command handlers:** `cmd_workspace`, `cmd_peek`, `cmd_dashboard`, `cmd_spawn`, `cmd_signal`, `cmd_browse`, `cmd_context`, `cmd_focus`
  - **Testing command handlers:** `cmd_test`, `cmd_setup`
  - **Internal generators/installers:** `_generate_agents_md`, `_create_agent_pointers`, `_install_hooks`, `_update_agents_md_progress`, `_detect_project_issues`
  - **Utility helpers:** `require_git`, `require_init`, `timestamp`, `iso_date`, colorized logging, CMUX integration helpers (`cmux_set_status`, `cmux_log`, etc.), Playwright CLI helpers
- **Data flow:**
  1. `init` creates `.agents/` structure, config, `AGENTS.md` template, agent pointer files, and git hooks.
  2. `handover` writes markdown logs under `.agents/handovers/`, updates the `AGENTS.md` progress section, and appends auto-detected + agent workflow recommendations.
  3. `recommend` runs `_detect_project_issues` for auto-detection and reads/writes `.agents/recommendations.md` for logged recommendations.
  4. `status` and `log` parse handover files for summaries.
  5. `onboard` adds additional pointer files and appends path metadata to `.agents/config.yaml`.
- **External dependencies:** Shell utilities and git (`git`, `sed`, `grep`, `stat`, `date`, `mkdir`, `cat`, etc.). No language runtime beyond Bash.

## 3. Tech Stack
- **Language:** Bash (`#!/usr/bin/env bash`, strict mode `set -euo pipefail`)
- **Versioning in code:** `VERSION="0.1.0"`
- **Build/packaging:** None (script-distribution model via git clone + PATH)
- **Package manager:** None
- **Testing framework:** None present
- **CI/CD:** None present in repository
- **Storage:** File-based state in project working tree (`AGENTS.md`, `.agents/config.yaml`, `.agents/handovers/*.md`, `.agents/recommendations.md`) plus local `.git/hooks`

## 4. Directory Structure
Current repository contents are minimal:
- `agent` — executable CLI script containing all business logic
- `README.md` — user documentation and workflow explanation
- `agents.md` — internal project knowledge base
- `.gitignore` — currently only `.DS_Store`

Generated in downstream repos when running `agent init`:
- `AGENTS.md` — primary shared context file for all agents
- `.agents/config.yaml` — generated metadata/config
- `.agents/handovers/` — timestamped handover markdown files
- `.agents/recommendations.md` — append-only workflow recommendations log
- `.agents/hooks/` — directory created (currently not populated with templates by this script)
- Pointer/instruction files for supported tools:
  - `.cursorrules`, `.windsurfrules`, `.clinerules`
  - `.github/copilot-instructions.md`
  - `CLAUDE.md`
  - `.cosine/instructions.md`, `.opencode/instructions.md`, `.codex/instructions.md`
  - `.aider.conf.yml`, `CONVENTIONS.md`

## 5. Key Entry Points
- **Main CLI entry point:** `agent` (top-level `case "${1:-help}"` dispatch)
- **Core commands:** `init`, `handover`, `status`, `log`, `onboard`, `reinit`, `recommend` (alias `rec`), `help`, `version`
- **CMUX commands:** `workspace`/`ws`, `peek`, `dashboard`, `spawn`, `signal`, `browse`, `context`/`ctx`, `focus`
- **Testing commands:** `test`, `setup`
- **API endpoints:** None (no HTTP server)
- **Background jobs/workers:** None

## 6. Core Concepts
- **Single source of truth:** `AGENTS.md` is intended to be the canonical project context for all AI tools.
- **Pointer file pattern:** Tool-specific config files all contain identical instruction text directing agents to `AGENTS.md`.
- **Handover-first workflow:** Sessions should end with `agent handover` so progress survives agent switches.
- **Append-style history:** Each handover is written as a timestamped file in `.agents/handovers/`.
- **Git-context capture:** Handover logs include branch, recent commits, staged diff stat, and unstaged diff stat.
- **Non-blocking guardrails:** Pre-commit hook reminds users if handover is stale but never blocks commit.
- **Workflow recommendations:** Agents can log improvement suggestions via `agent recommend`. Auto-detection (`_detect_project_issues`) surfaces common project issues (missing .gitignore, tests, CI, README, lockfiles, etc.). Recommendations are appended to handover files and stored in `.agents/recommendations.md`.
- **CMUX integration:** Optional workspace management, browser splits, shared buffers, signals between agents, and focus timers — all via CMUX terminal multiplexer.
- **Playwright CLI integration:** Optional browser testing with named sessions, parallel test spawning, and CMUX-integrated test workspaces.

## 7. Development Patterns
- **Code organization:**
  - Command functions use `cmd_*` naming.
  - Internal helper functions use `_name` naming.
  - Constants defined near file top (`AGENTS_DIR`, `HANDOVERS_DIR`, etc.).
- **Error handling:**
  - Strict shell mode (`set -euo pipefail`)
  - Hard precondition checks (`require_git`, `require_init`) with explicit fatal messaging.
- **Logging/UI conventions:**
  - Colorized symbols/messages (`→`, `✓`, `!`) for CLI UX.
- **Configuration management:**
  - `.agents/config.yaml` is generated and appended to, but current code does not read it to drive regeneration logic.
- **AuthN/AuthZ:** Not applicable (local CLI tool, no service layer).

## 8. Testing Strategy
- **Automated tests:** None detected.
- **Test directories/frameworks:** None detected.
- **CI validation:** None detected.
- **Current quality mechanisms:**
  - Strict Bash mode
  - Runtime guard checks
  - Git hook reminders for handover hygiene
- **Implication for future contributors/agents:** Behavioral verification is currently manual (run CLI commands in a test repo and inspect generated artifacts).

## 9. Getting Started
- **Prerequisites:**
  - Bash-compatible shell
  - Git installed
- **Install (from README):**
  1. Clone this repo.
  2. Add repo path to `PATH`.
  3. Verify with `agent version`.
- **Typical usage in a target repo:**
  1. `agent init`
  2. Edit generated `AGENTS.md` with project-specific context.
  3. Work with any AI tool.
  4. Before switching agents: `agent handover -s "..." -d "..." -n "..."`
  5. Check continuity with `agent status` and `agent log`.
- **Useful commands:**
  - `agent help`
  - `agent handover -s "..." -d "..." -l "..." -n "..." -r "..."`
  - `agent handover --stdin`
  - `agent recommend "suggestion"` / `agent recommend --auto`
  - `agent onboard <tool-name> [config-path]`
  - `agent reinit`
  - `agent setup`

## 10. Areas of Complexity
- **Hook behavior and local environment coupling:**
  - Hooks are installed directly into `.git/hooks` and may overwrite existing hooks.
- **Template/update fragility:**
  - `AGENTS.md` progress insertion relies on exact section headers and line-offset `sed` insertion.
- **Config authority mismatch:**
  - `.agents/config.yaml` records agent files, but pointer regeneration is hardcoded in `_create_agent_pointers`.
- **Documentation/implementation drift spots to watch:**
  - `.agents/hooks/` directory is created, but hooks are not stored there as templates by current implementation.
  - `onboard` prompt text suggests one default path, while implementation defaults to `.<name>/instructions.md` (lowercased).
- **Testing gap:**
  - No automated test suite or CI makes regressions in shell behavior more likely during future edits.
