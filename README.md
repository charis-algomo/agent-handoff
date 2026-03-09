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

# Before switching agents, have the current agent draft a handover for human review
agent handover -s "Built auth with NextAuth" -d "Chose JWT over sessions" -l "Middleware expects req.auth to be present" -n "Add protected routes"

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
│   ├── recommendations.md         ← workflow recommendations log
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
| `agent recommend` | Show or log workflow recommendations |
| `agent setup` | Check/install global tools |

### CMUX commands (require [CMUX](https://cmux.dev))

| Command | What it does |
|---------|-------------|
| `agent workspace sync` | Sync CMUX sidebar with repo state |
| `agent ws name "title"` | Rename the CMUX workspace |
| `agent peek [workspace:N]` | Read another workspace's screen |
| `agent dashboard` | Show all workspaces at a glance |
| `agent spawn "task"` | Spin up a new workspace for a task |
| `agent signal send/wait <name>` | Send/wait for signals between agents |
| `agent browse <url>` | Open URL in CMUX browser split |
| `agent context push/pull [name]` | Share context between workspaces |
| `agent focus "task"` | Start focus mode with timer |

### Testing commands (require [Playwright CLI](https://playwright.dev/))

| Command | What it does |
|---------|-------------|
| `agent test <url>` | Open Playwright browser session |
| `agent test <url> --headed` | Visible browser window |
| `agent test <url> --parallel N` | Spawn N parallel test sessions |
| `agent test install` | Install Playwright CLI + browsers |

## Handover options

```bash
# Interactive (prompts you)
agent handover

# Non-interactive (for scripts and agents)
agent handover --summary "what was done"
agent handover -s "summary" -d "decisions" -l "learnings" -n "next steps"

# Include a workflow recommendation
agent handover -s "Built auth" -r "Add rate limiting to login endpoint"

# Pipe conversation context
cat conversation.txt | agent handover -s "Debugging session"

# Agent dumps its context
agent handover -s "Auth refactor" --context "full conversation text..."
```

## Workflow recommendations

Agents notice things humans miss — missing tests, slow patterns, missing tooling. The recommendations system captures these observations.

```bash
# Show auto-detected issues + logged recommendations
agent recommend

# Log a recommendation
agent recommend "Use bun instead of npm for faster installs"
agent recommend --category tooling "Add biome for linting"

# Run auto-detection only
agent recommend --auto
```

Auto-detection checks for: missing `.gitignore`, no test directory, no CI config, missing `.env.example`, uncommitted lockfiles, `node_modules` not gitignored, no README, unfilled AGENTS.md placeholders, and missing tools.

Recommendations are also auto-appended to handover files and stored in `.agents/recommendations.md`.

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

## Handover responsibility

The current agent should draft the handover before ending its session, and a human should review it before it is accepted.

- In interactive mode, `agent handover` drafts a handover from the current repo state, then lets the human review, edit, and accept it.
- In non-interactive mode, pass `-s`, `-d`, `-l`, and `-n` directly from the agent.
- Use the learnings / gotchas field (`-l`) to record anything the next agent should know, such as sharp edges, environment quirks, failed approaches, or assumptions hidden in the code.
- Use `--recommend` / `-r` to attach a workflow recommendation that gets logged to `.agents/recommendations.md`.
- Auto-detected project issues are appended to every handover file automatically.
- If you want to attach a conversation dump, pass `--context` or pipe it through stdin.

## Philosophy

- **AGENTS.md is the source of truth.** Everything else is a pointer.
- **Handovers are append-only.** History is never rewritten.
- **Hooks remind, don't block.** The pre-commit hook warns but never prevents a commit.
- **Zero dependencies.** Just bash and git. Works anywhere.
- **Agent-agnostic.** No vendor lock-in. Switch tools freely.

## License

MIT
