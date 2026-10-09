#!/usr/bin/env python3
"""
Advanced System & Invariant Simulation Tests for UHI Protocol on Internet Computer (ICP).
Tests:
1. x402 Bazaar Protocol: Autonomous AI Service Settlement & 10% UHI Tax Routing
2. Conway Automaton Engine: 16x16 Grid Evolution, Entropy, and Dynamic Multipliers
3. Post-Quantum Cryptography (PQC): NIST FIPS 203 (ML-KEM) & FIPS 204 (ML-DSA) Verification
4. Elastic Abundance Tokenomics: Productivity Backing vs Deflationary Burn Invariants
5. Full Multi-Canister End-to-End Autonomous Flow Synchronization
"""

import unittest
import math

class ConwayEngineSim:
    def __init__(self, size=16):
        self.size = size
        self.total = size * size
        self.grid = [False] * self.total
        self.generation = 0
        self._init_glider()

    def _init_glider(self):
        # Glider pattern
        self.grid[1 * 16 + 2] = True
        self.grid[2 * 16 + 3] = True
        self.grid[3 * 16 + 1] = True
        self.grid[3 * 16 + 2] = True
        self.grid[3 * 16 + 3] = True

    def count_neighbors(self, x, y):
        cnt = 0
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                if dx == 0 and dy == 0:
                    continue
                nx = (x + dx) % self.size
                ny = (y + dy) % self.size
                if self.grid[ny * self.size + nx]:
                    cnt += 1
        return cnt

    def step(self):
        nxt = [False] * self.total
        alive = 0
        for y in range(self.size):
            for x in range(self.size):
                idx = y * self.size + x
                nbrs = self.count_neighbors(x, y)
                cur = self.grid[idx]
                state = (cur and (nbrs in (2, 3))) or (not cur and nbrs == 3)
                nxt[idx] = state
                if state:
                    alive += 1
        self.grid = nxt
        self.generation += 1
        return self.compute_stats(alive)

    def compute_stats(self, alive=None):
        if alive is None:
            alive = sum(1 for c in self.grid if c)
        dead = self.total - alive
        # Basis points: 10000 = 1.0x. Alive cells add up to 0.5x (5000 bps)
        mult_bps = 10000 + int((alive * 5000) / self.total)
        entropy = int((4 * alive * dead) / self.total)
        return {
            "generation": self.generation,
            "alive": alive,
            "dead": dead,
            "multiplier_bps": mult_bps,
            "multiplier_float": mult_bps / 10000.0,
            "entropy": entropy
        }


class X402BazaarSim:
    def __init__(self, treasury):
        self.treasury = treasury
        self.services = {}
        self.total_volume = 0
        self.total_tax_routed = 0

    def register_service(self, srv_id, title, cost_uhi):
        self.services[srv_id] = {
            "title": title,
            "cost": cost_uhi,
            "invocations": 0
        }

    def execute_payment(self, srv_id, consumer):
        assert srv_id in self.services, "Service not found"
        srv = self.services[srv_id]
        gross = srv["cost"]
        tax = gross * 0.10  # 10% UHI Dividend Tax
        net = gross - tax

        srv["invocations"] += 1
        self.total_volume += gross
        self.total_tax_routed += tax

        # Route tax to treasury
        self.treasury["balance"] += tax
        self.treasury["total_tax"] += tax

        return {
            "gross": gross,
            "tax": tax,
            "net": net,
            "settlement_proof": f"PROOF_X402_{srv_id}_{gross}_SETTLED"
        }


class PqcVerifierSim:
    @staticmethod
    def verify(algorithm, public_key, signature, message_hash):
        # NIST FIPS 203 (ML-KEM) and FIPS 204 (ML-DSA) validation
        if algorithm not in ("ML-KEM-768", "ML-DSA-65"):
            return False, "Unsupported PQC Algorithm"
        if len(public_key) < 32 or len(signature) < 32 or len(message_hash) < 16:
            return False, "Invalid lattice proof key/sig length"
        return True, {
            "algorithm": algorithm,
            "security_level": 192,
            "status": "VALID_LATTICE_PROOF"
        }


class TestUhiAdvancedProtocol(unittest.TestCase):
    def test_01_x402_bazaar_automated_10_percent_tax(self):
        treasury = {"balance": 100_000, "total_tax": 0}
        bazaar = X402BazaarSim(treasury)

        bazaar.register_service(1, "Tesla Optimus Automated Factory Run", 50.0)
        bazaar.register_service(2, "DeepSeek Inference Cluster", 10.0)

        # Execute 5 Optimus calls
        for _ in range(5):
            rec = bazaar.execute_payment(1, "autonomous_consumer")
            self.assertEqual(rec["gross"], 50.0)
            self.assertEqual(rec["tax"], 5.0)  # Exactly 10%
            self.assertEqual(rec["net"], 45.0) # Exactly 90%

        # Execute 10 Inference calls
        for _ in range(10):
            rec = bazaar.execute_payment(2, "autonomous_consumer")
            self.assertEqual(rec["tax"], 1.0)

        self.assertEqual(bazaar.total_volume, 350.0)
        self.assertEqual(bazaar.total_tax_routed, 35.0)
        self.assertEqual(treasury["total_tax"], 35.0)
        self.assertEqual(treasury["balance"], 100_035.0)

    def test_02_conway_engine_state_evolution_and_multiplier(self):
        engine = ConwayEngineSim(size=16)
        stats0 = engine.compute_stats()
        self.assertEqual(stats0["generation"], 0)
        self.assertEqual(stats0["alive"], 5) # Glider has 5 living cells
        self.assertGreaterEqual(stats0["multiplier_float"], 1.0)
        self.assertLessEqual(stats0["multiplier_float"], 1.5)

        # Step 4 generations (glider shifts position diagonally)
        for _ in range(4):
            stats = engine.step()

        self.assertEqual(stats["generation"], 4)
        self.assertEqual(stats["alive"], 5) # Glider period is 4, cell count preserved!
        self.assertGreater(stats["entropy"], 0)

    def test_03_pqc_nist_lattice_verification(self):
        pub_key = "0xML_DSA_65_LATTICE_PUBKEY_78a4f9103e5c9a241b7d80ef61c2847a91"
        sig = "0xML_DSA_65_SIGNATURE_55bce901389aa72049e772b10a9c7d4e320f1a"
        msg_hash = "0xCLAIM_UHI_EPOCH_1_HASH_99"

        # Valid ML-DSA-65 signature
        ok, res = PqcVerifierSim.verify("ML-DSA-65", pub_key, sig, msg_hash)
        self.assertTrue(ok)
        self.assertEqual(res["security_level"], 192)
        self.assertEqual(res["status"], "VALID_LATTICE_PROOF")

        # Invalid short key
        ok_bad, err = PqcVerifierSim.verify("ML-DSA-65", "short_key", sig, msg_hash)
        self.assertFalse(ok_bad)
        self.assertIn("Invalid lattice proof", err)

    def test_04_elastic_abundance_tokenomics(self):
        initial_supply = 1_000_000_000.0
        # Simulated emission tied strictly to verified compute tax
        verified_compute_units = 50_000.0
        mint_amount = verified_compute_units * 0.10 # 10% abundance dividend minted
        burned_fees = 12.5

        new_supply = initial_supply + mint_amount - burned_fees
        # Supply increases proportionally to real economic value, not arbitrary debasement
        self.assertEqual(new_supply, 1_000_004_987.5)
        self.assertTrue(mint_amount > 0 and burned_fees > 0)

    def test_05_full_autonomous_ecosystem_sync(self):
        # 1. AI Treasury starts
        treasury = {"balance": 1_000_000.0, "total_tax": 0.0}
        bazaar = X402BazaarSim(treasury)
        bazaar.register_service(10, "Tesla Optimus Heavy Labor", 100.0)

        # 2. 10 AI automated work orders executed
        for _ in range(10):
            bazaar.execute_payment(10, "factory_manager")

        self.assertEqual(treasury["balance"], 1_000_100.0) # +100 UHI tax pooled

        # 3. Conway engine computes network multiplier
        conway = ConwayEngineSim(size=16)
        conway.step()
        stats = conway.compute_stats()
        mult = stats["multiplier_float"]

        # 4. Human Citizen claims dividend with PQC
        base_dividend = 500.0
        effective_dividend = round(base_dividend * mult, 2)
        self.assertGreaterEqual(effective_dividend, 500.0)
        self.assertLessEqual(effective_dividend, 750.0)

        # PQC signature verification
        pqc_ok, _ = PqcVerifierSim.verify(
            "ML-DSA-65",
            "0xPUB_KEY_CITIZEN_ELON_00_LATTICE_SECURITY_PARAM",
            "0xSIG_CITIZEN_ELON_00_DILITHIUM_AUTHENTICATED_OK",
            "0xHASH_OF_EPOCH_DIVIDEND_PAYLOAD_30219"
        )
        self.assertTrue(pqc_ok)


if __name__ == "__main__":
    unittest.main()
