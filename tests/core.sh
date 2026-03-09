#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/helpers.sh"

echo "Core commands"
echo "─────────────"

echo "1. init creates expected structure"
setup
"$AGENT" init &>/dev/null
assert '[ -d .agents ]' ".agents/ dir created"
assert '[ -d .agents/handovers ]' "handovers/ dir created"
assert '[ -d .agents/hooks ]' "hooks/ dir created"
assert '[ -f .agents/config.yaml ]' "config.yaml created"
assert '[ -f AGENTS.md ]' "AGENTS.md created"

echo "2. init creates all pointer files"
setup
"$AGENT" init &>/dev/null
assert '[ -f .cursorrules ]' ".cursorrules"
assert '[ -f .windsurfrules ]' ".windsurfrules"
assert '[ -f .clinerules ]' ".clinerules"
assert '[ -f .github/copilot-instructions.md ]' ".github/copilot-instructions.md"
assert '[ -f CLAUDE.md ]' "CLAUDE.md"
assert '[ -f .cosine/instructions.md ]' ".cosine/instructions.md"
assert '[ -f .opencode/instructions.md ]' ".opencode/instructions.md"
assert '[ -f .codex/instructions.md ]' ".codex/instructions.md"
assert '[ -f .aider.conf.yml ]' ".aider.conf.yml"
assert '[ -f CONVENTIONS.md ]' "CONVENTIONS.md"

echo "3. pointers all reference AGENTS.md"
setup
"$AGENT" init &>/dev/null
for f in .cursorrules .windsurfrules .clinerules CLAUDE.md .aider.conf.yml CONVENTIONS.md \
         .github/copilot-instructions.md .cosine/instructions.md .opencode/instructions.md .codex/instructions.md; do
  assert "grep -q 'Read the .AGENTS.md. file' '$f'" "$f → AGENTS.md"
done

echo "4. init is idempotent (warns on second run)"
setup
"$AGENT" init &>/dev/null
output=$("$AGENT" init 2>&1)
assert 'echo "$output" | grep -q "already initialized"' "warns already initialized"

echo "5. reinit regenerates pointers"
setup
"$AGENT" init &>/dev/null
echo "corrupted" > .cursorrules
"$AGENT" reinit &>/dev/null
assert 'grep -q "Read the .AGENTS.md. file" .cursorrules' ".cursorrules restored"

echo "6. reinit requires init first"
setup
output=$("$AGENT" reinit 2>&1 || true)
assert 'echo "$output" | grep -q "not initialized"' "errors without init"

echo "7. status runs without error"
setup
"$AGENT" init &>/dev/null
assert '"$AGENT" status &>/dev/null' "status exits 0"

echo "8. handover (non-interactive)"
setup
"$AGENT" init &>/dev/null
git add -A && git commit -q -m "init"
"$AGENT" handover --summary "test handover" --next "keep going" &>/dev/null
assert '[ "$(ls .agents/handovers/*.md 2>/dev/null | wc -l | tr -d " ")" -ge 1 ]' "handover file created"
assert 'grep -q "test handover" .agents/handovers/*.md' "summary written"

echo "9. log shows handovers"
setup
"$AGENT" init &>/dev/null
git add -A && git commit -q -m "init"
"$AGENT" handover --summary "first" --next "next" &>/dev/null
output=$("$AGENT" log 2>&1)
assert 'echo "$output" | grep -q "first"' "log shows handover summary"

echo "10. onboard creates new pointer"
setup
"$AGENT" init &>/dev/null
"$AGENT" onboard bolt .bolt/instructions.md &>/dev/null
assert '[ -f .bolt/instructions.md ]' "pointer file created"
assert 'grep -q "Read the .AGENTS.md. file" .bolt/instructions.md' "pointer references AGENTS.md"
assert 'grep -q "bolt" .agents/config.yaml' "registered in config"

echo "11. recommend logs suggestion"
setup
"$AGENT" init &>/dev/null
"$AGENT" recommend "use pnpm instead of npm" &>/dev/null
assert '[ -f .agents/recommendations.md ]' "recommendations file created"
assert 'grep -q "use pnpm" .agents/recommendations.md' "suggestion logged"

echo "12. help output"
output=$("$AGENT" help 2>&1)
assert 'echo "$output" | grep -q "init"' "mentions init"
assert 'echo "$output" | grep -q "handover"' "mentions handover"

echo "13. syntax check"
assert 'bash -n "$AGENT"' "bash -n passes"

echo "14. mcp with no args shows usage"
output=$("$AGENT" mcp 2>&1)
assert 'echo "$output" | grep -q "mcp2cli"' "mcp usage mentions mcp2cli"

echo "15. help mentions mcp"
output=$("$AGENT" help 2>&1)
assert 'echo "$output" | grep -q "mcp"' "help mentions mcp"

results
