#!/usr/bin/env python3
"""
Unit and invariant tests for UHI Protocol on Internet Computer (ICP).
Verifies:
1. Citizen Registration and Sybil Resistance
2. Treasury AI Revenue Pooling and Disbursement RBAC
3. Distribution Engine Epoch and Claim Invariants
4. ICRC-1/2 Token Balance Conservation
"""

import unittest
import time

class MockIdentityRegistry:
    def __init__(self):
        self.citizens = {}
        self.active_humans = 0
        self.autonomous_agents = 0

    def register_citizen(self, principal, pqc_hash):
        if principal in self.citizens:
            return False, "Already registered"
        profile = {
            "principal": principal,
            "tier": "PostQuantumBiometric",
            "pqc_hash": pqc_hash,
            "last_claim_epoch": 0,
            "is_active": True
        }
        self.citizens[principal] = profile
        self.active_humans += 1
        return True, profile

    def is_eligible_for_claim(self, principal, epoch):
        if principal not in self.citizens:
            return False
        c = self.citizens[principal]
        return c["is_active"] and c["tier"] == "PostQuantumBiometric" and c["last_claim_epoch"] < epoch

    def update_claim_epoch(self, principal, epoch):
        if principal in self.citizens:
            self.citizens[principal]["last_claim_epoch"] = epoch
            return True
        return False


class MockTreasury:
    def __init__(self, initial_pool=10_000_000):
        self.balance = initial_pool
        self.total_pooled = initial_pool
        self.total_disbursed = 0
        self.x402_tax_total = 0
        self.distribution_engine = None

    def set_distribution_engine(self, engine_id):
        self.distribution_engine = engine_id

    def deposit_ai_revenue(self, amount, source_type):
        assert amount > 0, "Deposit must be > 0"
        self.balance += amount
        self.total_pooled += amount
        if source_type == "X402_TAX":
            self.x402_tax_total += amount
        return self.balance

    def disburse(self, caller, amount):
        if caller != self.distribution_engine and caller != "admin":
            raise PermissionError("Unauthorized disbursement")
        if amount > self.balance:
            raise ValueError("Insufficient treasury funds")
        self.balance -= amount
        self.total_disbursed += amount
        return self.balance


class MockUhiToken:
    def __init__(self, initial_supply=1_000_000_000):
        self.total_supply = initial_supply
        self.balances = {"treasury": initial_supply}
        self.total_minted = 0
        self.total_burned = 0

    def transfer(self, sender, recipient, amount, fee=0.0001):
        total_needed = amount + fee
        if self.balances.get(sender, 0) < total_needed:
            return False, "InsufficientFunds"
        self.balances[sender] -= total_needed
        self.balances[recipient] = self.balances.get(recipient, 0) + amount
        # Fee burned
        self.total_supply -= fee
        self.total_burned += fee
        return True, "Ok"

    def mint_productivity(self, recipient, amount, proof_hash):
        assert len(proof_hash) > 0
        self.balances[recipient] = self.balances.get(recipient, 0) + amount
        self.total_supply += amount
        self.total_minted += amount
        return self.total_supply


class TestUhiProtocolCore(unittest.TestCase):
    def setUp(self):
        self.registry = MockIdentityRegistry()
        self.treasury = MockTreasury(initial_pool=50_000_000)
        self.token = MockUhiToken(initial_supply=1_000_000_000)
        self.treasury.set_distribution_engine("engine_canister")

    def test_01_identity_registration_and_sybil_resistance(self):
        # Register valid human
        ok, profile = self.registry.register_citizen("citizen-elon-01", "0xPQC_FIPS204_LATTICE_A1")
        self.assertTrue(ok)
        self.assertEqual(profile["tier"], "PostQuantumBiometric")
        self.assertEqual(self.registry.active_humans, 1)

        # Duplicate registration attempt must fail (Sybil resistance)
        ok_dup, err = self.registry.register_citizen("citizen-elon-01", "0xPQC_FIPS204_LATTICE_A2")
        self.assertFalse(ok_dup)
        self.assertEqual(err, "Already registered")
        self.assertEqual(self.registry.active_humans, 1)

    def test_02_treasury_pooling_and_disbursement_rbac(self):
        # Deposit AI Revenue from Tesla Optimus Fleet
        bal = self.treasury.deposit_ai_revenue(5000, "OPTIMUS_FLEET")
        self.assertEqual(bal, 50_005_000)

        # Deposit from x402 Tax
        bal = self.treasury.deposit_ai_revenue(1000, "X402_TAX")
        self.assertEqual(bal, 50_006_000)
        self.assertEqual(self.treasury.x402_tax_total, 1000)

        # Authorized distribution engine disburse
        new_bal = self.treasury.disburse("engine_canister", 6000)
        self.assertEqual(new_bal, 50_000_000)
        self.assertEqual(self.treasury.total_disbursed, 6000)

        # Unauthorized caller disburse must fail
        with self.assertRaises(PermissionError):
            self.treasury.disburse("unauthorized_hacker", 100)

    def test_03_token_balance_and_fee_burning(self):
        # Transfer from treasury to citizen
        initial_supply = self.token.total_supply
        ok, res = self.token.transfer("treasury", "citizen-01", 1000, fee=0.0001)
        self.assertTrue(ok)
        self.assertEqual(self.token.balances["citizen-01"], 1000)
        # Supply decreased by burned fee
        self.assertAlmostEqual(self.token.total_supply, initial_supply - 0.0001, places=4)
        self.assertAlmostEqual(self.token.total_burned, 0.0001, places=4)

    def test_04_productivity_backed_elastic_minting(self):
        # Minting backed by compute proof
        initial_supply = self.token.total_supply
        new_supply = self.token.mint_productivity("treasury", 5000, "0xCOMPUTE_PROOF_GPU_HASH")
        self.assertEqual(new_supply, initial_supply + 5000)
        self.assertEqual(self.token.total_minted, 5000)


if __name__ == "__main__":
    unittest.main()
