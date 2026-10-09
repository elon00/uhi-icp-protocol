#!/usr/bin/env bash
# One-command, zero-cycle execution of the UHI readiness verification.
set -euo pipefail
cd "$(dirname "$0")/.."
echo 'UHI One-Click Verification — ZERO ICP CYCLES'
python3 tests/simulate_protocol.py
python3 tests/simulate_advanced_protocol.py
python3 scripts/reality_gate.py
echo 'Static checks passed. This does NOT deploy to mainnet.'
