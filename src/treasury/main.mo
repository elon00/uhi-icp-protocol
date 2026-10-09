import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Option "mo:base/Option";

shared ({ caller = initializer }) actor class Treasury() = this {

  public type DepositRecord = {
    sender : Principal;
    amount : Nat;
    source_type : Text;
    timestamp : Nat64;
    memo : Text;
  };

  public type TreasuryStats = {
    total_pooled : Nat;
    total_disbursed : Nat;
    current_balance : Nat;
    total_tax_from_x402 : Nat;
    total_deposits_count : Nat;
  };

  private var admin : Principal = initializer;
  private var distribution_engine : ?Principal = null;

  private var total_pooled : Nat = 10_000_000_00000000; // Seed pool
  private var total_disbursed : Nat = 0;
  private var current_balance : Nat = 10_000_000_00000000;
  private var total_tax_from_x402 : Nat = 0;

  private let deposits = Buffer.Buffer<DepositRecord>(100);

  public shared ({ caller }) func set_distribution_engine(engine : Principal) : async { #Ok : Bool; #Err : Text } {
    if (caller != admin) {
      return #Err("Unauthorized: Only admin can set distribution engine");
    };
    distribution_engine := ?engine;
    #Ok(true)
  };

  public shared ({ caller }) func deposit_ai_revenue(
    amount : Nat,
    source_type : Text,
    memo : Text
  ) : async { #Ok : Nat; #Err : Text } {
    if (amount == 0) {
      return #Err("Deposit amount must be positive");
    };

    let record : DepositRecord = {
      sender = caller;
      amount = amount;
      source_type = source_type;
      timestamp = Nat64.fromIntWrap(Time.now());
      memo = memo;
    };

    deposits.add(record);
    total_pooled += amount;
    current_balance += amount;

    if (source_type == "X402_TAX") {
      total_tax_from_x402 += amount;
    };

    #Ok(current_balance)
  };

  public shared ({ caller }) func disburse_to_distribution(
    recipient : Principal,
    amount : Nat
  ) : async { #Ok : Nat; #Err : Text } {
    let isAuthorized = switch (distribution_engine) {
      case (?engine) { caller == engine or caller == admin };
      case null { caller == admin };
    };

    if (not isAuthorized) {
      return #Err("Unauthorized: Only distribution engine or admin can disburse funds");
    };

    if (amount > current_balance) {
      return #Err("Insufficient treasury balance");
    };

    current_balance -= amount;
    total_disbursed += amount;

    #Ok(current_balance)
  };

  public query func get_treasury_stats() : async TreasuryStats {
    {
      total_pooled = total_pooled;
      total_disbursed = total_disbursed;
      current_balance = current_balance;
      total_tax_from_x402 = total_tax_from_x402;
      total_deposits_count = deposits.size();
    }
  };

  public query func get_recent_deposits(limit : Nat) : async [DepositRecord] {
    let size = deposits.size();
    let count = if (limit > size) size else limit;
    let result = Buffer.Buffer<DepositRecord>(count);
    var i = size;
    while (i > 0 and result.size() < count) {
      i -= 1;
      result.add(deposits.get(i));
    };
    result.toArray()
  };
};
