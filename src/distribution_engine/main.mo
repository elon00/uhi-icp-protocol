import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Option "mo:base/Option";

shared ({ caller = initializer }) actor class DistributionEngine() = this {

  public type ClaimRecord = {
    citizen : Principal;
    epoch : Nat;
    amount : Nat;
    conway_multiplier_bps : Nat;
    timestamp : Nat64;
    pqc_proof : Text;
  };

  public type EpochInfo = {
    epoch_number : Nat;
    base_payout : Nat;
    dynamic_multiplier_bps : Nat;
    effective_payout : Nat;
    total_claims_in_epoch : Nat;
    total_disbursed_in_epoch : Nat;
    is_active : Bool;
  };

  public type DistributionStats = {
    current_epoch : Nat;
    total_all_time_claims : Nat;
    total_all_time_disbursed : Nat;
    active_epoch_info : EpochInfo;
  };

  private var admin : Principal = initializer;
  private var treasury_canister : ?Principal = null;
  private var token_canister : ?Principal = null;
  private var identity_registry : ?Principal = null;
  private var conway_engine : ?Principal = null;

  private var base_payout : Nat = 500_00000000; // 500 UHI per citizen per epoch
  private var current_epoch : Nat = 1;
  private var dynamic_multiplier_bps : Nat = 12500; // 1.25x initial (125%)
  private var epoch_claims_count : Nat = 0;
  private var epoch_disbursed_sum : Nat = 0;

  private var total_all_time_claims : Nat = 0;
  private var total_all_time_disbursed : Nat = 0;

  // Track claims per citizen per epoch: key = principal#epoch
  private let claims_history = Buffer.Buffer<ClaimRecord>(500);
  private let citizen_claimed_in_epoch = HashMap.HashMap<Text, Bool>(1000, Text.equal, Text.hash);

  private func calcEffectivePayout() : Nat {
    (base_payout * dynamic_multiplier_bps) / 10000
  };

  public shared ({ caller }) func set_base_payout(amount : Nat) : async { #Ok : Bool; #Err : Text } {
    if (caller != admin) {
      return #Err("Unauthorized: Only admin can set base payout");
    };
    base_payout := amount;
    #Ok(true)
  };

  public shared ({ caller }) func start_next_epoch(conway_multiplier_bps_input : Nat) : async { #Ok : EpochInfo; #Err : Text } {
    if (caller != admin) {
      return #Err("Unauthorized: Only admin can advance epoch");
    };

    current_epoch += 1;
    dynamic_multiplier_bps := if (conway_multiplier_bps_input >= 10000) conway_multiplier_bps_input else 10000;
    epoch_claims_count := 0;
    epoch_disbursed_sum := 0;

    #Ok(getCurrentEpochInfo())
  };

  private func getCurrentEpochInfo() : EpochInfo {
    {
      epoch_number = current_epoch;
      base_payout = base_payout;
      dynamic_multiplier_bps = dynamic_multiplier_bps;
      effective_payout = calcEffectivePayout();
      total_claims_in_epoch = epoch_claims_count;
      total_disbursed_in_epoch = epoch_disbursed_sum;
      is_active = true;
    }
  };

  public query func get_current_epoch_info() : async EpochInfo {
    getCurrentEpochInfo()
  };

  public shared ({ caller }) func claim_uhi_dividend(pqc_proof : Text) : async { #Ok : ClaimRecord; #Err : Text } {
    let key = Principal.toText(caller) # "_" # Nat.toText(current_epoch);
    if (Option.get(citizen_claimed_in_epoch.get(key), false)) {
      return #Err("UHI Dividend already claimed for this epoch");
    };

    if (Text.size(pqc_proof) < 8) {
      return #Err("Invalid PQC proof: Lattice signature required");
    };

    let effectivePayout = calcEffectivePayout();
    let record : ClaimRecord = {
      citizen = caller;
      epoch = current_epoch;
      amount = effectivePayout;
      conway_multiplier_bps = dynamic_multiplier_bps;
      timestamp = Nat64.fromIntWrap(Time.now());
      pqc_proof = pqc_proof;
    };

    citizen_claimed_in_epoch.put(key, true);
    claims_history.add(record);

    epoch_claims_count += 1;
    epoch_disbursed_sum += effectivePayout;
    total_all_time_claims += 1;
    total_all_time_disbursed += effectivePayout;

    #Ok(record)
  };

  public query func get_distribution_stats() : async DistributionStats {
    {
      current_epoch = current_epoch;
      total_all_time_claims = total_all_time_claims;
      total_all_time_disbursed = total_all_time_disbursed;
      active_epoch_info = getCurrentEpochInfo();
    }
  };
};
