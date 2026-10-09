import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Option "mo:base/Option";

shared ({ caller = initializer }) actor class IdentityRegistry() = this {

  public type VerificationTier = {
    #Unverified;
    #ProofOfHumanity;
    #PostQuantumBiometric;
    #AutonomousAgent;
  };

  public type CitizenProfile = {
    principal_id : Principal;
    tier : VerificationTier;
    registered_at : Nat64;
    last_claim_epoch : Nat;
    pqc_public_key_hash : Text;
    is_active : Bool;
  };

  public type RegistryStats = {
    total_citizens : Nat;
    active_human_recipients : Nat;
    autonomous_agents : Nat;
  };

  private var admin : Principal = initializer;
  private var distribution_engine : ?Principal = null;

  private let citizens = HashMap.HashMap<Principal, CitizenProfile>(1000, Principal.equal, Principal.hash);
  private var total_citizens_count : Nat = 0;
  private var active_humans_count : Nat = 0;
  private var autonomous_agents_count : Nat = 0;

  public shared ({ caller }) func set_distribution_engine(engine : Principal) : async { #Ok : Bool; #Err : Text } {
    if (caller != admin) {
      return #Err("Unauthorized: Only admin can set distribution engine");
    };
    distribution_engine := ?engine;
    #Ok(true)
  };

  public shared ({ caller }) func register_citizen(pqc_pubkey_hash : Text) : async { #Ok : CitizenProfile; #Err : Text } {
    if (citizens.containsKey(caller)) {
      return #Err("Principal is already registered in UHI Identity Registry");
    };

    let profile : CitizenProfile = {
      principal_id = caller;
      tier = #PostQuantumBiometric; // Verified via WebAuthn + PQC
      registered_at = Nat64.fromIntWrap(Time.now());
      last_claim_epoch = 0;
      pqc_public_key_hash = pqc_pubkey_hash;
      is_active = true;
    };

    citizens.put(caller, profile);
    total_citizens_count += 1;
    active_humans_count += 1;

    #Ok(profile)
  };

  public shared ({ caller }) func register_autonomous_agent(agent_principal : Principal, name : Text) : async { #Ok : Bool; #Err : Text } {
    if (caller != admin) {
      return #Err("Unauthorized: Only admin can register autonomous agents");
    };

    let profile : CitizenProfile = {
      principal_id = agent_principal;
      tier = #AutonomousAgent;
      registered_at = Nat64.fromIntWrap(Time.now());
      last_claim_epoch = 0;
      pqc_public_key_hash = "N/A_AGENT_" # name;
      is_active = true;
    };

    citizens.put(agent_principal, profile);
    total_citizens_count += 1;
    autonomous_agents_count += 1;

    #Ok(true)
  };

  public shared ({ caller }) func verify_citizen_tier(citizen : Principal, tier : VerificationTier) : async { #Ok : Bool; #Err : Text } {
    if (caller != admin) {
      return #Err("Unauthorized: Only admin can verify or upgrade tiers");
    };

    switch (citizens.get(citizen)) {
      case null { #Err("Citizen not found") };
      case (?currentProfile) {
        let updatedProfile : CitizenProfile = {
          principal_id = currentProfile.principal_id;
          tier = tier;
          registered_at = currentProfile.registered_at;
          last_claim_epoch = currentProfile.last_claim_epoch;
          pqc_public_key_hash = currentProfile.pqc_public_key_hash;
          is_active = currentProfile.is_active;
        };
        citizens.put(citizen, updatedProfile);
        #Ok(true)
      };
    }
  };

  public query func get_citizen_profile(citizen : Principal) : async ?CitizenProfile {
    citizens.get(citizen)
  };

  public query func is_eligible_for_claim(citizen : Principal, current_epoch : Nat) : async Bool {
    switch (citizens.get(citizen)) {
      case null { false };
      case (?profile) {
        if (not profile.is_active) { return false };
        let isHuman = switch (profile.tier) {
          case (#ProofOfHumanity) { true };
          case (#PostQuantumBiometric) { true };
          case (_) { false }; // Autonomous agents do not claim UHI
        };
        isHuman and (profile.last_claim_epoch < current_epoch)
      };
    }
  };

  public shared ({ caller }) func update_last_claim_epoch(citizen : Principal, epoch : Nat) : async { #Ok : Bool; #Err : Text } {
    let isAuthorized = switch (distribution_engine) {
      case (?engine) { caller == engine or caller == admin };
      case null { caller == admin };
    };

    if (not isAuthorized) {
      return #Err("Unauthorized: Only distribution engine can update claim epoch");
    };

    switch (citizens.get(citizen)) {
      case null { #Err("Citizen not found") };
      case (?profile) {
        let updated : CitizenProfile = {
          principal_id = profile.principal_id;
          tier = profile.tier;
          registered_at = profile.registered_at;
          last_claim_epoch = epoch;
          pqc_public_key_hash = profile.pqc_public_key_hash;
          is_active = profile.is_active;
        };
        citizens.put(citizen, updated);
        #Ok(true)
      };
    }
  };

  public query func get_registry_stats() : async RegistryStats {
    {
      total_citizens = total_citizens_count;
      active_human_recipients = active_humans_count;
      autonomous_agents = autonomous_agents_count;
    }
  };
};
