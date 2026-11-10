# ICP Mainnet Reality-Gate Checklist

**Launch status: BLOCKED** — no new mainnet deployment authorized; no cycles should be spent until all technical gates are genuinely green.

| Gate | Present evidence | Status |
|---|---|---|
| Repository files and Candid configuration | Eight canisters in dfx.json | Present, not compiled in CI |
| CI | Python simulation and JSON count | Insufficient |
| ML-DSA cryptographic verification | Length checks and simulated commitment | BLOCKED |
| ML-KEM separation | Same signature API mixes KEM and DSA | BLOCKED |
| x402 treasury settlement | Local receipt/variable updates, no ledger transfer | BLOCKED |
| Frontend claims and marketplace | JavaScript mutates local numbers and claims success | BLOCKED |
| End-to-end canister tests | No real PocketIC/local-replica integration tests | BLOCKED |
| Security audit and upgrade/rollback tests | No independent audit evidence | BLOCKED |
| Mainnet IDs and on-chain verification | No committed verified canister manifest | BLOCKED |

## Zero-spend preflight
```bash
python3 scripts/reality_gate.py
```

All failed checks **must remain failed until implementations and independent evidence exist**. Do not edit the gate to create artificial green results.

## Required deployment evidence
Record commit SHA, toolchain versions, audit report, local canister test logs, verified identity and controller settings, Candid hashes, deployed module hashes, mainnet canister IDs, cycle budgets, and read-only blockchain explorer links. Only after those are verified should the operator explicitly authorize a funded release.
