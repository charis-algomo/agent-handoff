#!/usr/bin/env bash
# Shared test helpers — sourced by each test file

AGENT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/agent"
TEST_TMPDIR=$(mktemp -d)
_PASS=0
_FAIL=0

_cleanup() { rm -rf "$TEST_TMPDIR"; }
trap _cleanup EXIT

setup() {
  rm -rf "$TEST_TMPDIR/repo"
  mkdir -p "$TEST_TMPDIR/repo"
  cd "$TEST_TMPDIR/repo"
  git init -q
}

pass() { _PASS=$((_PASS + 1)); echo "  ✓ $1"; }
fail() { _FAIL=$((_FAIL + 1)); echo "  ✗ $1"; }
assert() { if eval "$1"; then pass "$2"; else fail "$2"; fi; }

results() {
  echo ""
  echo "$_PASS passed, $_FAIL failed"
  [ "$_FAIL" -eq 0 ]
}
