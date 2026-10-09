# UHI ICP Protocol — End-to-End Production Blueprint

**Release decision: BLOCKED. No mainnet spend until genuine acceptance gates are green.**
Last blueprint revision: 2026-10-09. This file defines work to do, not claims that it has been completed.

## Purpose and boundaries
Build a verifiable on-chain research platform for future Universal High Income experiments. The financial model is hypothetical: no guaranteed dividend, return, robotic fleet partnership, proven revenue, or government-endorsed proof of personhood. Keep empirical metrics separate from policy assumptions.

## Architecture and authoritative sources
Browser (authenticated wallet) → application canisters (identity, marketplace, distribution, Conway) → ICRC ledger → treasury-controlled ledger accounts. All balances and payments must be sourced from ledger results. Never infer money moved merely because an internal receipt or frontend variable changed. Keep ML-DSA verification independent of account authentication; ML-KEM does not verify signatures. Run Conway as a bounded policy experiment; do not claim alive cells prove actual compute productivity.

## Priority-0 findings from reviewed source
1. `src/frontend/wallet.js` contains placeholder principals and reports simulated connections; disabled in the safety PR. Real Internet Identity/NFID/Plug/other wallet integrations still need implementation and testing.
2. `src/frontend/main.js` used to display balances and mark claims/settlements successful without a canister call. Those success paths are disabled in the safety PR; real adapters are still outstanding.
3. `src/uhi_token/main.mo`: advertises ICRC-2 but does not implement approvals or `icrc2_transfer_from`; stores balances keyed only by owner (ignores subaccounts), has no durable transaction ledger, and returns total supply rather than a transfer block index.
4. `src/treasury/main.mo`: accepts unauthenticated, unbacked accounting deposits and reduces an internal balance on disbursement without ledger transfer. Initial reserve is an internal number, not proven deposited tokens.
5. `src/x402_bazaar/main.mo`: `execute_402_payment` writes a local receipt and increases counters without taking payment, paying providers, or transferring tax to treasury. Seeded named services must be clearly demo data and removed unless providers have consented.
6. `src/distribution_engine/main.mo`: accepts an 8-character proof, records claim as paid without using treasury or token canisters, and has no cross-call rollback/idempotency design.
7. `src/identity_registry/main.mo`: self-registration immediately assigns a high verification tier without third-party human eligibility proof.
8. `src/pqc_layer/main.mo`: length-based checks and artificial hash strings, not NIST cryptographic verification.
9. Mutable HashMaps and Buffers require explicit persistence/upgrade strategy; test actual upgrades in PocketIC.
10. Existing CI executes Python models, not compiled Motoko Wasm in a replica.

## Delivery sequence / tasks with evidence
### A. Reproducible foundation
- Pin Motoko and dfx/icp-cli versions, lock dependency versions and record checksum of toolchain and generated Wasm.
- Build all eight canisters on a clean runner and typecheck the Candid surface with candid tooling.
- Provide explicit threat model, risk register, admin roles, and release provenance.
**Gate:** clean build passes in a fresh container with no network secrets and reproducible artifacts.

### B. Ledger and token
- Prefer a maintained, audited ICRC-1/2 ledger implementation rather than extending the current non-conformant custom token.
- Verify account owner AND subaccount, approvals/expiration, spender permissions, duplicate protection, time skew, fees, mint/burn roles, total supply, block indexes, indexing, durable state and upgrades.
- Do not allocate real token supply without an approved tokenomics and legal/compliance review.
**Gate:** ICRC test vectors and PocketIC transfer/allowance/upgrade tests, invariant `supply == sum(balances)`.

### C. x402 commerce
- Implement genuine HTTP 402 challenge/resource flow with priced services and strict authorization.
- Store unique nonce/payment request; validate ledger block or approved spender transfer with exact token, destination, amount, fee policy, payer, expiry, replay key and finality.
- Write a state machine `Quoted → AwaitingPayment → Paid → Fulfilled/RefundPending/Failed`; never fulfill on a generated local proof string.
- Treasury allocation and provider settlement need independent on-ledger transactions (or an auditable authorized split/escrow design). Reconcile both.
**Gate:** malformed, stale, double-spent, duplicate and partially settled attempts rejected; verified service response only after recorded settlement.

### D. Treasury and distribution
- Create segregated ICRC subaccounts and verified balances. All deposit records must bind to real ledger transactions.
- Reconcile on-chain balance = opening funds + verified inflows - actual outflows - applicable fees.
- Claims require authenticated principal, independently verified eligibility, available funds, epoch limits, unique claim key, and signed/verified authorization.
- Persist claim/payment state *before* external ledger calls, and use idempotency keys and recovery jobs for asynchronous failure. Treat pending payouts as pending, never paid.
- Test concurrent claims, timeouts, ledger errors, insufficient reserves, and upgrade/restart.
**Gate:** each valid claim causes at most one real economic payout; all success messages include verifiable block index.

### E. Identity and privacy
- Integrate Internet Identity and explicitly selected compatible wallets using official SDKs and signature/authentication flows, not hardcoded strings.
- Internet Identity establishes principal authentication, not proof of unique personhood; design a separately governed eligibility provider and appeals/revocation process.
- Avoid raw biometrics and personal details on public canisters; use minimum required attestations and consent.
**Gate:** unauthorized enrollment, spoofed principals, revoked claims and replay attempts rejected.

### F. Post-quantum cryptography
- Replace placeholder checks with validated ML-DSA-65 message/signature/public key verification, using known-answer vectors and negative mutation tests *inside the target execution environment*.
- If Motoko implementation is infeasible, isolate a properly reviewed Rust/Wasm verifier canister and explicitly bind its Candid interface.
- Use ML-KEM only for encapsulation workflows (if justified); never treat KEM ciphertext as an ML-DSA signature.
- Bind signed context to principal, epoch, intent, amount, canister ID, network domain separator, expiration and nonce.
**Gate:** valid vectors pass; changed payload/key/signature, expired/replayed proof rejected; memory/cycles benchmarked.

### G. Conway / policy engine
- Keep automaton simulations observable but independent from financial issuance.
- Any multiplier policy must be admin-authorized, bounded, transparently versioned and independently reviewed; never accept arbitrary multipliers from public calls.
**Gate:** deterministic reference vectors, overflow/bounds, governance changes and rollback tests.

### H. Web and accessibility
- Replace placeholder balances, citizen counts, service invocations and payout values with authenticated certified queries or explicitly marked 'Unavailable'.
- Hook wallet modal and payment/claim controls to canister actors and verified transaction receipts.
- Add security headers/CSP, XSS protection, keyboard navigation, screen-reader support, responsive/mobile regression tests, error states and disconnection recovery.
**Gate:** E2E browser tests prove no success unless a verified on-chain receipt exists.

### I. Security and release operations
- Threat-model mint authority, provider spoofing, unauthorized treasury withdrawals, duplicate claims, cycle exhaustion, denial of service, upgrade loss, dependencies and leaked deploy identity.
- Separate deploy operator and treasury controllers, use multisig/governance where suitable, limit high-risk administration.
- Run dependency audit, static scans, canister integration tests, contract invariants, fuzzing/property-based tests, load/cycle benchmarks and upgrade/rollback rehearsals.
- Commission independent external audit, remediate critical/high findings and document any accepted residual risk.
**Gate:** green audited build; evidence manifest matches exact release commit and Wasm/module hashes.

## One-click developer workflow (zero mainnet cycles)
`bash scripts/one_click_verify.sh` runs Python model checks and strict preflight, and will fail until reality checks pass. GitHub Actions `One-Click UHI Reality Verification` allows manual dispatch. A passing model test does not imply deployment readiness. The current `scripts/reality_gate.py` is *only* a basic conservative static blocker; strengthen it with compiled-Wasm PocketIC test artifacts, signature verification vectors, actual ledger proof assertions, coverage and signed provenance. Do not make it green by adding empty files or matching strings.

## Release manifest acceptance
Before mainnet require immutable machine-readable evidence of: Git commit, toolchain lock, each canister Wasm SHA-256, Candid hash, build/test audit, PocketIC logs, approval record, network identity/controller plan, cycle budget cap, upgrade/rollback backup strategy, and expected canister names. Only after approved funding and actual deployment, record verifiable ICP canister IDs, module hashes, owners/controllers, version, ledger block IDs, and frontend URL. Do not invent canister IDs or pre-create `MAINNET_CANISTERS.json` simply to fool a check.

## Mainnet authorization workflow
1. Run reproducible build, PocketIC multi-canister integration, proof and transfer security tests locally; zero ICP mainnet cycles.
2. Security review and acceptance report signed by accountable maintainers.
3. Manual release approval after reviewing network, cycles estimate/cap, identity and controller.
4. Deploy controlled canisters in dependency order to ICP; funding spends real cycles, so never auto-trigger from a push.
5. Wire exact canister principals and use read-only checks to verify actor results, ledger movements, hashes, status, and certified frontend.
6. Exercise a pre-authorized small-value smoke transfer only if separately approved; compare block history and funding.
7. Publish verified on-chain identifiers and operational dashboard; monitor cycle burn, errors, unauthorized actions and payout reconciliation.
8. Roll back/pause safely on mismatch, with operator playbook and incident log.

## Definition of Done
Project is *complete* only when all above acceptance gates have primary evidence, CI is green without bypass, critical/high audit findings are resolved, live canister deployment is independently verified, and the owner approves the real cycles budget. Until then, status is BLOCKED, not 'mission complete'.

## Official platform references
- https://docs.internetcomputer.org/guides/testing/pocket-ic/
- https://docs.internetcomputer.org/guides/digital-assets/ledgers/
- https://docs.internetcomputer.org/guides/testing/strategies/
- https://docs.internetcomputer.org/concepts/canisters/
