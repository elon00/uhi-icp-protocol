#!/usr/bin/env python3
"""Regression guard: unavailable financial flows must fail closed, not succeed synthetically."""
from pathlib import Path
import unittest
R = Path(__file__).resolve().parents[1]
class SafetyRegression(unittest.TestCase):
    def test_unfunded_treasury_has_no_fake_reserve(self):
        s=(R/"src/treasury/main.mo").read_text()
        self.assertIn("private var current_balance : Nat = 0;",s)
        self.assertIn("no verified ICRC ledger transfer proof",s)
        self.assertIn("no ICRC ledger disbursement",s)
    def test_unpaid_bazaar_disallowed(self):
        s=(R/"src/x402_bazaar/main.mo").read_text()
        self.assertIn("settlement requires verified ICRC ledger transfer",s)
        self.assertIn("// initFlagshipServices();",s)
    def test_unverified_claim_disallowed(self):
        s=(R/"src/distribution_engine/main.mo").read_text()
        self.assertIn("DISABLED: claim requires verified human eligibility",s)
        self.assertIn("conway_multiplier_bps_input > 15000",s)
    def test_new_users_unverified(self):
        s=(R/"src/identity_registry/main.mo").read_text()
        self.assertIn("tier = #Unverified;",s)
        self.assertNotIn("tier = #PostQuantumBiometric; // Verified via WebAuthn + PQC",s)
    def test_no_wallet_spoofing(self):
        s=(R/"src/frontend/wallet.js").read_text()
        self.assertIn("no synthetic principals permitted",s)
        self.assertNotIn("Fallback simulation for dev/sandbox",s)
if __name__ == "__main__": unittest.main()
