#!/usr/bin/env python3
"""Fail-closed, zero-cycle preflight for UHI ICP mainnet readiness."""
from pathlib import Path
import json
import sys

root = Path(__file__).resolve().parents[1]
issues = []
def check(condition, message):
    print(("PASS" if condition else "BLOCKED") + ": " + message)
    if not condition: issues.append(message)

cfg = json.loads((root / "dfx.json").read_text())
check(len(cfg.get("canisters", {})) == 8, "Eight declared canisters")
pqc = (root / "src/pqc_layer/main.mo").read_text()
check("simulation" not in pqc.lower() and "pubLen >= minPub" not in pqc and "PQC_LATTICE_" not in pqc, "Real in-canister post-quantum verification, not length checks or simulated commitments")
bazaar = (root / "src/x402_bazaar/main.mo").read_text()
check("icrc2_transfer_from" in bazaar or "icrc1_transfer" in bazaar, "x402 settlement performs real ledger transfers")
frontend = (root / "src/frontend/main.js").read_text()
check("disbursed to" not in frontend and "Settled & Taxed" not in frontend and "state.treasuryBalance += srv.tax" not in frontend, "Frontend must not fabricate settlement or dividend success")
check((root / "tests/real_canister_integration.py").exists() or (root / "tests/pocketic_integration.py").exists(), "Real canister execution integration tests exist")
check((root / "MAINNET_CANISTERS.json").exists(), "Auditable mainnet canister deployment manifest exists")
print("\nMAINNET READINESS:", "BLOCKED — 0 cycles spent" if issues else "STATIC PREFLIGHT PASSED (not a deployment authorization)")
sys.exit(1 if issues else 0)
