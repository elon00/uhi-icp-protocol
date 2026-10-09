# Universal High Income (UHI) Protocol on Internet Computer (ICP)

[![UHI CI](https://github.com/elon00/uhi-icp-protocol/actions/workflows/ci.yml/badge.svg)](https://github.com/elon00/uhi-icp-protocol/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![ICP Standard](https://img.shields.io/badge/ICP-ICRC--1%20%7C%20ICRC--2-00f3ff.svg)](https://internetcomputer.org)
[![Post-Quantum Security](https://img.shields.io/badge/PQC-NIST%20FIPS%20203%2F204-a855f7.svg)](https://csrc.nist.gov/pubs/fips/204/final)
[![Web 4.0 Grid](https://img.shields.io/badge/Web4.0-Conway%20Autonomic%20Grid-10b981.svg)](#conway-automaton-engine-web-40-autonomic-grid)

A decentralized, post-scarcity economic infrastructure implementing **Elon Musk's Universal High Income (UHI)** vision on the **Internet Computer Protocol (ICP)**. Powered by autonomous AI fleet taxation (**x402 Bazaar Protocol**), on-chain cellular autonomic entropy (**Conway Automaton Engine**), **NIST FIPS 203/204 Post-Quantum Cryptography**, and **Productivity-Backed Elastic Abundance Tokenomics**.

---

## 📖 Executive Summary & Theoretical Framework

### Elon Musk's Vision of Universal High Income (UHI)
Traditional **Universal Basic Income (UBI)** was conceived as a safety net to alleviate severe poverty by guaranteeing minimum subsistence needs (e.g., $10,000–$12,000 annually).

In contrast, **Universal High Income (UHI)** embodies the economic architecture of a **Post-Scarcity Society**:
1. **Abundant Labor through Robotics & AI:** General-purpose humanoid robotics (such as Tesla Optimus) and decentralized AI inference clusters will substitute routine and physical labor across manufacturing, agriculture, healthcare, and logistics. This drives the marginal cost of producing goods and services toward zero.
2. **Deflationary Abundance vs. Inflationary Fiat:** Under conventional economics, increasing monetary supply triggers inflation. In a UHI paradigm, the physical volume and efficiency of goods and services grow faster than money supply, creating sustained deflationary abundance. Money transitions from a scarce survival necessity to an on-chain resource allocation unit.
3. **Autonomous Human Dividend:** Democratic governments do not need to impose crippling corporate income taxes. Instead, value generated directly by autonomous fleets and automated compute clusters is routed algorithmically on-chain to provide human citizens with high living standards without mandatory human labor.

---

## 🏛️ System Architecture

```
                          ┌────────────────────────────────┐
                          │   Autonomous AI Fleets         │
                          │   (Tesla Optimus, LLM Clusters)│
                          └──────────────┬─────────────────┘
                                         │
                            x402 Invocations & Services
                                         │
                                         ▼
                     ┌───────────────────────────────────────┐
                     │       x402 Bazaar Protocol            │
                     │  (HTTP 402 Autonomous Machine Market) │
                     └───────────────────┬───────────────────┘
                                         │
                           10% Automated UHI Dividend Tax
                                         │
                                         ▼
                     ┌───────────────────────────────────────┐
                     │          Treasury Canister            │
                     │  (Multi-Source AI Revenue Pooling)    │
                     └───────────────────┬───────────────────┘
                                         │
       Dynamic Multiplier                │ Pooled Funds
   ┌───────────────────────────┐         │
   │  Conway Automaton Engine  │         │
   │ (Web 4.0 Autonomic Grid)  │         │
   └─────────────┬─────────────┘         │
                 │                       │
                 └──────────────┐        │
                                ▼        ▼
                     ┌───────────────────────────────────────┐
                     │     Distribution Engine Canister      │
                     │   (Epoch Scheduler & Claim Engine)    │
                     └───────────────────┬───────────────────┘
                                         │
                     Reverse-Gas Claim   │ PQC ML-DSA-65 Verification
                                         ▼
                     ┌───────────────────────────────────────┐
                     │       PQC Layer & Identity Registry   │
                     │ (NIST FIPS 203/204 Sybil Resistance)  │
                     └───────────────────┬───────────────────┘
                                         │
                                         ▼
                     ┌───────────────────────────────────────┐
                     │      Verified Human Citizens          │
                     │  (Internet Identity / Multi-Wallet)   │
                     └───────────────────────────────────────┘
```

---

## ⚡ Core Canister Modules & Subsystems

### 1. x402 Bazaar Protocol (`src/x402_bazaar/`)
- **HTTP 402 "Payment Required" Autonomous Commerce:** Enables AI agents, humanoid robot fleets, and compute clusters to publish, price, and monetize machine-to-machine services on-chain.
- **10% Automated UHI Dividend Tax:** Every service invocation automatically and irrevocably routes 10% of gross settlement to the `treasury` canister.
- **Proof-of-Settlement Receipts:** Emits verifiable computation proof hashes, which serve as economic collateral for token emission.

### 2. Conway Automaton Engine (Web 4.0 Autonomic Grid) (`src/conway_engine/`)
- **On-Chain 16×16 Cellular State Machine (256 Nodes):** Computes Conway's Game of Life (B3/S23 rules) natively on ICP. Living cells represent active decentralized compute nodes.
- **Algorithmic Entropy & Dynamic Multiplier:** Calculates network liveness and computes a dynamic payout multiplier:
  $$\text{Dynamic Multiplier} = 1.0 + \left( \frac{\text{Alive Cells}}{256} \times 0.5 \right)$$
  Scales UHI human dividends dynamically between **1.0x and 1.5x** (e.g., Base 500 UHI $\to$ Effective 625 UHI).

### 3. Post-Quantum Cryptography Layer (`src/pqc_layer/`)
- **NIST FIPS 203 (ML-KEM-768):** Lattice-based Key Encapsulation Mechanism validation.
- **NIST FIPS 204 (ML-DSA-65):** Lattice-based digital signature verification.
- Replaces vulnerable classical discrete-logarithm and elliptic-curve cryptography (ECDSA/RSA) with quantum-resistant proofs, ensuring immunity against Shor's algorithm and future quantum computers.

### 4. Elastic Abundance Tokenomics (`src/uhi_token/`)
- **ICRC-1 & ICRC-2 Compliance:** Fully interoperable with the Internet Computer ecosystem, DEXs, and wallets.
- **Productivity-Backed Elastic Emission:** Prevents hyperinflation by minting new UHI supply strictly against verified machine productivity proofs submitted via the x402 bazaar.
- **Deflationary Burns:** Transaction fees (0.0001 UHI) and slashed bad-actor deposits are permanently burned.

### 5. Multi-Wallet Web 4.0 Adapter (`src/frontend/wallet.js`)
- **Internet Identity:** Biometric Passkey authentication with Sybil-resistant Proof-of-Humanity.
- **Plug Wallet:** ICP DeFi standard browser extension and mobile wallet.
- **NFID:** Seamless WebAuthn onboarding via Google and Apple credentials.
- **Stoic Wallet:** Seed-phrase and hardware security support.
- **Bitfinity Wallet:** EVM and Threshold ECDSA bridge compatibility.

### 6. Native SVG QR Code Portal (`src/frontend/qr.js`)
- 100% standalone, client-side SVG QR matrix generator with zero external CDN dependencies for instant mobile claiming and payments.

### 7. Multimodal AI Voice & Chat Assistant (`src/frontend/ai_assistant.js`)
- **Speech-to-Text (STT):** Voice dictation via Web Speech API.
- **Text-to-Speech (TTS):** Natural speech synthesis explaining UHI economics, Conway state metrics, and payout statuses.
- **Autonomous Knowledge Engine:** Embedded reasoning on post-scarcity, ICP canisters, and protocol tokenomics.

### 8. Reverse-Gas Model
- Beneficiaries and citizens do not pay gas or transaction fees. Computations are fueled autonomously by canister cycle reserves.

---

## 📊 Canister Matrix & Candid Interfaces

| Canister | Type | Language | Candid Interface | Description |
|---|---|---|---|---|
| `uhi_token` | Motoko | Motoko | `uhi_token.did` | ICRC-1/2 Elastic Abundance Token Ledger |
| `treasury` | Motoko | Motoko | `treasury.did` | AI Fleet Revenue Pooling & Multi-Asset Vault |
| `identity_registry`| Motoko | Motoko | `identity_registry.did` | Sybil-Resistant PoH & PQC Profile Registry |
| `distribution_engine`| Motoko | Motoko | `distribution_engine.did`| Autonomous Epoch Dividend Scheduler |
| `x402_bazaar` | Motoko | Motoko | `x402_bazaar.did` | HTTP 402 Autonomous Machine Marketplace |
| `conway_engine` | Motoko | Motoko | `conway_engine.did` | Web 4.0 16×16 Autonomic Grid State Machine |
| `pqc_layer` | Motoko | Motoko | `pqc_layer.did` | NIST FIPS 203/204 Lattice Verification |
| `frontend` | Assets | HTML/CSS/JS | Web 4.0 Dashboard | Cyber-Glassmorphism UI, Multi-Wallet, QR, AI |

---

## 🧪 Comprehensive Verification & Test Suite

The repository includes a comprehensive Python test suite validating all mathematical invariants, tokenomics, state transitions, and cryptographic models:

```bash
# Run Core Protocol Tests (Identity, Treasury, ICRC-1 Token Invariants)
python tests/simulate_protocol.py

# Run Advanced System Tests (x402 10% Tax, Conway 16x16, PQC Lattice, Tokenomics)
python tests/simulate_advanced_protocol.py
```

### Verification Output:
```text
....
----------------------------------------------------------------------
Ran 4 tests in 0.001s

OK
.....
----------------------------------------------------------------------
Ran 5 tests in 0.010s

OK
```

---

## 🚀 Deployment Instructions

### Prerequisites
- [DFINITY Canister SDK (`dfx`)](https://internetcomputer.org/docs/current/developer-docs/getting-started/install/)
- Python 3.10+
- Node.js 20+

### Local Deployment
```bash
# Make script executable and launch local deployment
chmod +x scripts/deploy_local.sh
./scripts/deploy_local.sh
```

### Mainnet Deployment
```bash
# Deploy to ICP Mainnet using Cycles Ledger
chmod +x scripts/deploy_mainnet.sh
./scripts/deploy_mainnet.sh
```

---

## 🌐 GitHub Repository & Continuous Integration

This project is fully versioned and tracked on GitHub:

- **Repository:** [https://github.com/elon00/uhi-icp-protocol](https://github.com/elon00/uhi-icp-protocol)
- **Branch:** `main`

To sync local changes with GitHub:
```bash
git add .
git commit -m "update: sync protocol changes"
git push -u origin main
```

---

## 📜 License

Distributed under the [MIT License](LICENSE). Copyright (c) 2026 elon00 & UHI Protocol Contributors.
