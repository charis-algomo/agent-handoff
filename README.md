# agent — git for agents

Structured handoff system so any AI coding agent can pick up where the last one left off.

Start with Cursor, continue with Claude Code, finish with Cosine — no context lost.

## The problem

You're building with AI agents. You start a task with Cursor, hit a wall, switch to Claude Code for a tricky refactor, then want to finish in Cosine. But each agent starts fresh — no memory of what the last one did, what decisions were made, or what's left to do.

`agent` solves this by creating a universal handoff document (`AGENTS.md`) that every agent tool reads, plus a structured log of progress and decisions that survives across sessions.

## Install

```bash
# Clone and add to PATH
git clone https://github.com/charis-algomo/agent-handoff.git ~/agent-handoff
echo 'export PATH="$HOME/agent-handoff:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify
agent version
```

## Quick start

```bash
# Initialize any git repo for agent handoff
cd my-project
agent init

# Edit AGENTS.md with your project context
# ... then start working with any agent tool

# Before switching agents, log what you did
agent handover -s "Built auth with NextAuth" -d "Chose JWT over sessions" -n "Add protected routes"

# Check state
agent status
```

## What `agent init` creates

```
my-project/
├── AGENTS.md                      ← THE source of truth (edit this)
├── .agents/
│   ├── config.yaml                ← project config
│   ├── handovers/                 ← timestamped handover logs
│   └── hooks/                     ← hook templates
│
│  Agent pointers (auto-generated, all say "read AGENTS.md"):
├── .cursorrules                   Cursor
├── .windsurfrules                 Windsurf
├── .clinerules                    Cline
├── .github/copilot-instructions.md  GitHub Copilot
├── CLAUDE.md                      Claude Code
├── .cosine/instructions.md        Cosine (cos2)
├── .opencode/instructions.md      OpenCode
├── .codex/instructions.md         Codex
├── .aider.conf.yml                Aider
└── CONVENTIONS.md                 Generic fallback
```

Every agent tool reads its own config file. They all point to `AGENTS.md`. One source of truth, many readers.

## Commands

| Command | What it does |
|---------|-------------|
| `agent init` | Set up agent handoff in a git repo |
| `agent handover` | Log progress, decisions, and context |
| `agent status` | Show current state |
| `agent log` | Show recent handover entries |
| `agent onboard <name> [path]` | Register a new/unknown agent tool |
| `agent reinit` | Regenerate all config/pointer files |

## Handover options

```bash
# Interactive (prompts you)
agent handover

# Non-interactive (for scripts and agents)
agent handover --summary "what was done"
agent handover -s "summary" -d "decisions" -n "next steps"

# Pipe conversation context
cat conversation.txt | agent handover -s "Debugging session"

# Agent dumps its context
agent handover -s "Auth refactor" --context "full conversation text..."
```

## How it works

```
Agent A works on the project
    ↓
Agent A runs: agent handover -s "Built X" -d "Chose Y" -n "Do Z"
    ↓
Handover saved to .agents/handovers/2026-03-06T14-30-00.md
AGENTS.md updated with progress entry
    ↓
Agent A commits and pushes
Pre-commit hook reminds about handover if forgotten
    ↓
Agent B starts a new session
    ↓
Agent B reads AGENTS.md (via .cursorrules / CLAUDE.md / .cosine/instructions.md / etc.)
    ↓
Agent B knows: what was done, what was decided, what to do next
    ↓
Agent B continues the work seamlessly
```

## Supported agents

| Agent Tool | Config File | Status |
|-----------|-------------|--------|
| Cursor | `.cursorrules` | ✓ |
| Windsurf | `.windsurfrules` | ✓ |
| Cline | `.clinerules` | ✓ |
| GitHub Copilot | `.github/copilot-instructions.md` | ✓ |
| Claude Code | `CLAUDE.md` | ✓ |
| Cosine (cos2) | `.cosine/instructions.md` | ✓ |
| OpenCode | `.opencode/instructions.md` | ✓ |
| Codex | `.codex/instructions.md` | ✓ |
| Aider | `.aider.conf.yml` | ✓ |

New agent tool? Onboard it in one command:

```bash
# Register a new agent with its config file path
agent onboard devin .devin/instructions.md

# Or let it auto-create the path
agent onboard bolt    # creates .bolt/instructions.md → AGENTS.md
```

## Git hooks

`agent init` installs two git hooks automatically:

**pre-commit** — If no handover has been logged in the last 10 minutes and AGENTS.md isn't being updated in the commit, shows a reminder box. It never blocks the commit.

**post-commit** — Appends the commit hash and message to the most recent handover log, linking handovers to commits.

## Philosophy

- **AGENTS.md is the source of truth.** Everything else is a pointer.
- **Handovers are append-only.** History is never rewritten.
- **Hooks remind, don't block.** The pre-commit hook warns but never prevents a commit.
- **Zero dependencies.** Just bash and git. Works anywhere.
- **Agent-agnostic.** No vendor lock-in. Switch tools freely.

## License

MIT