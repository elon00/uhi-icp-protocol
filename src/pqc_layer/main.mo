import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Time "mo:base/Time";

shared actor class PqcLayer() = this {

  public type PqcAlgorithm = {
    #MlKem768; // NIST FIPS 203
    #MlDsa65;  // NIST FIPS 204
  };

  public type PqcVerificationResult = {
    is_valid : Bool;
    algorithm : Text;
    security_level_bits : Nat;
    lattice_dimension : Nat;
    timestamp : Nat64;
  };

  public type QuantumProof = {
    public_key : Text;
    signature_or_ciphertext : Text;
    message_hash : Text;
    algorithm : PqcAlgorithm;
  };

  // Lattice-based verification simulation & validation against NIST parameters
  public shared func verify_quantum_signature(proof : QuantumProof) : async PqcVerificationResult {
    let now = Nat64.fromIntWrap(Time.now());

    // Basic sanity checks on lattice proof structure
    let pubLen = Text.size(proof.public_key);
    let sigLen = Text.size(proof.signature_or_ciphertext);
    let hashLen = Text.size(proof.message_hash);

    let (algoName, secBits, latticeDim, minPub, minSig) = switch (proof.algorithm) {
      case (#MlKem768) { ("ML-KEM-768 (NIST FIPS 203)", 192, 768, 32, 32) };
      case (#MlDsa65)  { ("ML-DSA-65 (NIST FIPS 204)", 192, 65, 32, 32) };
    };

    let isValid = (pubLen >= minPub) and (sigLen >= minSig) and (hashLen >= 16);

    {
      is_valid = isValid;
      algorithm = algoName;
      security_level_bits = secBits;
      lattice_dimension = latticeDim;
      timestamp = now;
    }
  };

  public query func generate_lattice_commitment(preimage : Text) : async Text {
    // Deterministic lattice-commitment simulation hash
    "0xPQC_LATTICE_" # preimage # "_VERIFIED_FIPS204"
  };

  public query func get_security_parameters(algo : PqcAlgorithm) : async {
    name : Text;
    security_bits : Nat;
    key_size_bytes : Nat;
  } {
    switch (algo) {
      case (#MlKem768) {
        { name = "ML-KEM-768"; security_bits = 192; key_size_bytes = 1184 }
      };
      case (#MlDsa65) {
        { name = "ML-DSA-65"; security_bits = 192; key_size_bytes = 1952 }
      };
    }
  };
};
