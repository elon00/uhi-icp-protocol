# UHI ICP Protocol — About

**Project name:** UHI ICP Protocol (Universal High Income Protocol)

**GitHub About description (copy into repository Settings):**
> Experimental Universal High Income protocol on ICP, featuring Motoko canisters, a Conway engine, an x402 marketplace prototype, and a Web dashboard. Mainnet not verified.

**Suggested topics:** `internet-computer`, `icp`, `motoko`, `universal-high-income`, `x402`, `conway-game-of-life`, `web3`, `post-quantum`, `experimental`

## Purpose
UHI ICP Protocol explores a decentralized, AI-enabled infrastructure for hypothetical universal income distribution. It includes a token canister, treasury, identity registry, distribution engine, marketplace prototype, Conway automaton and post-quantum research module, plus a web interface.

## Development status
**Experimental; not audited and not verified on ICP mainnet.** Simulation-based tests are not equivalent to canister execution or real transfers. The current post-quantum module performs format/length checks rather than cryptographic verification. The marketplace does not currently settle payments on a token ledger. The frontend previously simulated successful claims and settlements. These statements must not be interpreted as proof of deployed functionality, guaranteed income, an investment return or a relationship with Elon Musk, Tesla or DeepSeek.

## Mainnet acceptance criteria
1. Motoko canisters compile reproducibly and all Candid interfaces match.
2. Tests run against real canisters (local replica/PocketIC), including unauthorized calls, rollback, upgrade and replay safety.
3. PQC verification uses independently tested ML-DSA verification for exact messages/signatures and rejects tampering; ML-KEM is not misrepresented as a digital signature.
4. x402 receives verifiable on-ledger payment, handles duplicate/replayed receipts and routes real treasury allocations.
5. Token ICRC interfaces, mint permissions, identity/Sybil claims and treasury controls pass security review.
6. Frontend only reports proven on-chain state, transactions and actual network connection.
7. Independent security review, reproducible release, authenticated deployment identity and public canister ID evidence.
8. Mainnet release is an explicit, separately approved action only after all prior gates pass.

See `scripts/reality_gate.py`; it is a deliberately strict static blocker, not a replacement for an audit.
