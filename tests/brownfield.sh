#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/helpers.sh"

echo "Brownfield support"
echo "──────────────────"

echo "1. Fresh repo"
setup
"$AGENT" init &>/dev/null
assert '[ -f AGENTS.md ]' "AGENTS.md created"
assert '[ -f .cursorrules ]' ".cursorrules created"
assert 'grep -q "_TODO: Add project overview_" AGENTS.md' "AGENTS.md has template content"

echo "2. Unedited template gets regenerated"
setup
"$AGENT" init &>/dev/null
rm -rf .agents
"$AGENT" init &>/dev/null
assert 'grep -q "_TODO: Add project overview_" AGENTS.md' "template regenerated"

echo "3. Edited AGENTS.md preserved"
setup
echo "# My real project docs" > AGENTS.md
"$AGENT" init &>/dev/null
assert 'grep -q "My real project docs" AGENTS.md' "user content preserved"
assert '! grep -q "_TODO: Add project overview_" AGENTS.md' "template not injected"

echo "4. Existing .cursorrules merges"
setup
echo "Always use semicolons" > .cursorrules
"$AGENT" init &>/dev/null
assert 'grep -q "Read the .AGENTS.md. file" .cursorrules' "pointer prepended"
assert 'grep -q "Previous Instructions" .cursorrules' "previous section added"
assert 'grep -q "Always use semicolons" .cursorrules' "original content preserved"

echo "5. Pointer from previous init overwrites cleanly"
setup
"$AGENT" init &>/dev/null
rm -rf .agents
"$AGENT" init &>/dev/null
assert '! grep -q "Previous Instructions" .cursorrules' "no merge section"

echo "6. reinit preserves AGENTS.md"
setup
"$AGENT" init &>/dev/null
echo "User-edited content" > AGENTS.md
"$AGENT" reinit &>/dev/null
assert 'grep -q "User-edited content" AGENTS.md' "AGENTS.md untouched"

echo "7. onboard merges existing config"
setup
"$AGENT" init &>/dev/null
mkdir -p .devin
echo "Custom devin rules" > .devin/instructions.md
"$AGENT" onboard devin .devin/instructions.md &>/dev/null
assert 'grep -q "Read the .AGENTS.md. file" .devin/instructions.md' "pointer prepended"
assert 'grep -q "Custom devin rules" .devin/instructions.md' "original content preserved"

echo "8. --force overwrites everything"
setup
echo "# My real docs" > AGENTS.md
echo "Custom rules" > .cursorrules
"$AGENT" init --force &>/dev/null
assert 'grep -q "_TODO: Add project overview_" AGENTS.md' "AGENTS.md overwritten"
assert '! grep -q "Previous Instructions" .cursorrules' "pointer not merged"
assert '! grep -q "Custom rules" .cursorrules' "old content gone"

results
