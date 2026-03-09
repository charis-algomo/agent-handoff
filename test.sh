#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
SUITES=("$DIR"/tests/*.sh)
PASSED=0
FAILED=0
FAILED_NAMES=()

echo "agent test suite"
echo "================"
echo ""

for suite in "${SUITES[@]}"; do
  name=$(basename "$suite" .sh)
  [ "$name" = "helpers" ] && continue

  if bash "$suite"; then
    PASSED=$((PASSED + 1))
  else
    FAILED=$((FAILED + 1))
    FAILED_NAMES+=("$name")
  fi
  echo ""
done

echo "================"
echo "$((PASSED + FAILED)) suites: $PASSED passed, $FAILED failed"
if [ "$FAILED" -gt 0 ]; then
  echo "failed: ${FAILED_NAMES[*]}"
  exit 1
fi
