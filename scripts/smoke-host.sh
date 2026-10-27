#!/usr/bin/env bash
# Host smoke for SemaPLC. No Docker and no LLM key.
#
# Prerequisite (repo root):
#   (cd sema-plc-tools && npm install && npm run build)
#
# Exit 0: offline checks passed. If docker is missing or the daemon is down,
# compile / status / dev.sh are printed as SKIP and were not run.
# Exit 1: Node, the toolchain build, or an offline CLI assertion failed.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS="$ROOT/sema-plc-tools"
CLI="$TOOLS/dist/cli.js"
SAMPLE="$TOOLS/runtime/samples/simple_counter_fixed.st"

fail() { echo "[smoke] FAIL: $*" >&2; exit 1; }
ok() { echo "[smoke] OK: $*"; }
skip() { echo "[smoke] SKIP: $*"; }

if ! command -v node >/dev/null 2>&1; then
  fail "node is not on PATH (need Node.js >= 18)"
fi
node -e 'const major = Number(process.versions.node.split(".")[0]); if (!(major >= 18)) process.exit(1)' \
  || fail "Node.js >= 18 required (found $(node -v))"
ok "node $(node -v)"

if [[ ! -f "$CLI" ]]; then
  fail "missing $CLI — from the repo root: (cd sema-plc-tools && npm install && npm run build)"
fi
if [[ ! -f "$SAMPLE" ]]; then
  fail "missing sample $SAMPLE"
fi

IO_JSON="$(node "$CLI" detectIO "$SAMPLE")" || fail "detectIO exited non-zero"
node -e '
const r = JSON.parse(process.argv[1])
const names = (r.io || []).map((x) => x.name).sort()
const want = ["counter_value", "reset_button", "running_led", "start_button"]
if (r.count !== 4 || JSON.stringify(names) !== JSON.stringify(want)) {
  console.error(JSON.stringify(r))
  process.exit(1)
}
' "$IO_JSON" || fail "detectIO on simple_counter_fixed.st did not return start_button, reset_button, counter_value, running_led"
ok "detectIO simple_counter_fixed.st → 4 located variables"

SCENE_JSON="$(node "$CLI" genScene "$SAMPLE")" || fail "genScene exited non-zero"
PARTS="$(node -e '
const s = JSON.parse(process.argv[1])
if (s.version !== "1" || !Array.isArray(s.parts) || s.parts.length < 1) {
  console.error(JSON.stringify(s).slice(0, 500))
  process.exit(1)
}
process.stdout.write(String(s.parts.length))
' "$SCENE_JSON")" || fail "genScene did not return a Scene Spec (version 1, non-empty parts)"
ok "genScene simple_counter_fixed.st → scene v1 (${PARTS} parts)"

if ! command -v docker >/dev/null 2>&1; then
  skip "docker is not on PATH. Not run: node dist/cli.js compile, node dist/cli.js status, sema-plc-web/dev.sh, runtime image build."
  skip "Those need Docker Engine (Linux) or Docker Desktop (macOS/Windows), then: (cd sema-plc-tools/runtime && ./scripts/build-matiec-base.sh && docker compose up -d --build)"
  ok "host smoke passed (runtime subset skipped)"
  exit 0
fi

if ! docker info >/dev/null 2>&1; then
  skip "docker is installed but the daemon is not reachable. compile / status / dev.sh were not run."
  ok "host smoke passed (runtime subset skipped)"
  exit 0
fi

skip "docker daemon is up. This script does not build the OpenPLC image or call the runtime."
skip "With the container running: (cd sema-plc-tools && node dist/cli.js status && node dist/cli.js compile runtime/samples/simple_counter_fixed.st)"
ok "host smoke passed"
