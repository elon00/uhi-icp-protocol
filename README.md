# UHI ICP Protocol — Universal High Income Research on the Internet Computer

[Repository](https://github.com/elon00/uhi-icp-protocol) · [CI](https://github.com/elon00/uhi-icp-protocol/actions) · [License](LICENSE)

> **Status: Experimental — NOT verified mainnet-ready.** No on-chain deployment, earned dividends, live merchant integration, real PQC verification, or actual AI-fleet revenue is established by this repository. Do not deposit funds, spend cycles or rely on dashboard values for financial decisions.

## Overview
UHI ICP Protocol explores an experimental architecture for a Universal High Income system using Internet Computer canisters and an HTML/JavaScript dashboard. The project examines whether future autonomous services could fund a distributed dividend; it does not establish that this economic model currently works or that payments can be made.

## Components
| Component | Source | Present implementation |
| --- | --- | --- |
| UHI token | `src/uhi_token` | Motoko token prototype; ICRC compatibility requires independent verification |
| Treasury | `src/treasury` | Accounting/vault prototype |
| Identity registry | `src/identity_registry` | Identity data/proof prototype; not verified proof-of-personhood |
| Distribution engine | `src/distribution_engine` | Epoch-based distribution prototype |
| x402 bazaar | `src/x402_bazaar` | Service registry and internal receipts; **no proven ledger settlement** |
| Conway engine | `src/conway_engine` | Cellular automaton |
| PQC layer | `src/pqc_layer` | **Simulation only**, NOT FIPS 203/204 cryptographic verification |
| Frontend | `src/frontend` | Experimental interface; metrics, claims and commerce must not be treated as live |

## Verify without spending cycles
```bash
python3 scripts/reality_gate.py
python3 tests/simulate_protocol.py
python3 tests/simulate_advanced_protocol.py
```
The Python tests are **simulations**, not local-replica or PocketIC tests. The reality gate is expected to report BLOCKED until genuine implementations and evidence exist.

## Deployment policy
Mainnet is **prohibited** until real cryptography, ledger settlement, live frontend, end-to-end canister tests, audit and deployment evidence pass. The deployment script runs the preflight first and stops when it fails. A passing static check by itself never authorizes production deployment.

**Do not run mainnet deployment or transfer cycles yet.** See [the detailed project description](ABOUT.md) and [mainnet checklist](MAINNET_READINESS.md).

## Independence and limitations
This is an independent open-source research project. It is not affiliated with or endorsed by Elon Musk, Tesla, DeepSeek, DFINITY or the Internet Computer Foundation. There is no guaranteed income, return or deployment claim.

## License
MIT — see [LICENSE](LICENSE).
