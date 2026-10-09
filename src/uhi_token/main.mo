import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Time "mo:base/Time";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Option "mo:base/Option";

shared ({ caller = initializer }) actor class UhiToken() = this {

  public type Subaccount = Blob;

  public type Account = {
    owner : Principal;
    subaccount : ?Subaccount;
  };

  public type Value = {
    #Nat : Nat;
    #Int : Int;
    #Text : Text;
    #Blob : Blob;
  };

  public type TransferArgs = {
    from_subaccount : ?Subaccount;
    to : Account;
    amount : Nat;
    fee : ?Nat;
    memo : ?Blob;
    created_at_time : ?Nat64;
  };

  public type TransferError = {
    #BadFee : { expected_fee : Nat };
    #BadBurn : { min_burn_amount : Nat };
    #InsufficientFunds : { balance : Nat };
    #TooOld;
    #CreatedInFuture : { ledger_time : Nat64 };
    #Duplicate : { duplicate_of : Nat };
    #TemporarilyUnavailable;
    #GenericError : { error_code : Nat; message : Text };
  };

  public type TransferResult = {
    #Ok : Nat;
    #Err : TransferError;
  };

  public type StandardRecord = {
    name : Text;
    url : Text;
  };

  // State variables
  private var token_name : Text = "Universal High Income";
  private var token_symbol : Text = "UHI";
  private var token_decimals : Nat8 = 8;
  private var default_fee : Nat = 10_000; // 0.0001 UHI
  private var total_supply : Nat = 1_000_000_000_00000000; // Initial supply
  private var total_minted_productivity : Nat = 0;
  private var total_burned_deflationary : Nat = 0;
  private var admin : Principal = initializer;
  private var authorized_minters : HashMap.HashMap<Principal, Bool> = HashMap.HashMap<Principal, Bool>(10, Principal.equal, Principal.hash);

  // Balances stored by Principal text representation
  private let balances = HashMap.HashMap<Text, Nat>(1000, Text.equal, Text.hash);

  // Initialize founder / treasury balance
  balances.put(Principal.toText(initializer), total_supply);

  // Authorization helper
  private func isAuthorized(p : Principal) : Bool {
    p == admin or Option.get(authorized_minters.get(p), false)
  };

  public query func icrc1_name() : async Text {
    token_name
  };

  public query func icrc1_symbol() : async Text {
    token_symbol
  };

  public query func icrc1_decimals() : async Nat8 {
    token_decimals
  };

  public query func icrc1_fee() : async Nat {
    default_fee
  };

  public query func icrc1_total_supply() : async Nat {
    total_supply
  };

  public query func icrc1_minting_account() : async ?Account {
    ?{ owner = admin; subaccount = null }
  };

  public query func icrc1_balance_of(account : Account) : async Nat {
    let key = Principal.toText(account.owner);
    Option.get(balances.get(key), 0)
  };

  public shared ({ caller }) func icrc1_transfer(args : TransferArgs) : async TransferResult {
    let senderKey = Principal.toText(caller);
    let senderBal = Option.get(balances.get(senderKey), 0);
    let fee = Option.get(args.fee, default_fee);

    if (fee != default_fee) {
      return #Err(#BadFee({ expected_fee = default_fee }));
    };

    let totalNeeded = args.amount + fee;
    if (senderBal < totalNeeded) {
      return #Err(#InsufficientFunds({ balance = senderBal }));
    };

    let recipientKey = Principal.toText(args.to.owner);
    let recipientBal = Option.get(balances.get(recipientKey), 0);

    // Debit sender
    balances.put(senderKey, senderBal - totalNeeded);

    // Credit recipient
    balances.put(recipientKey, recipientBal + args.amount);

    // Deflationary fee burning
    total_supply -= fee;
    total_burned_deflationary += fee;

    #Ok(total_supply)
  };

  public query func icrc1_supported_standards() : async [StandardRecord] {
    [
      { name = "ICRC-1"; url = "https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-1" },
      { name = "UHI-Elastic-Abundance"; url = "https://github.com/elon00/uhi-icp-protocol" }
    ]
  };

  // Productivity-Backed Elastic Emission
  // Explicitly fail closed until verified off-chain evidence and authorized
  // on-ledger minting are implemented and independently tested.
  public shared ({ caller }) func mint_elastic_productivity(
    to : Account,
    amount : Nat,
    proof_hash : Text
  ) : async { #Ok : Nat; #Err : Text } {
    #Err("DISABLED: unverified productivity proof and unsafe custom-ledger minting")
  };

  // Deflationary Burn
  public shared ({ caller }) func burn_deflationary(
    from : Account,
    amount : Nat,
    reason : Text
  ) : async { #Ok : Nat; #Err : Text } {
    if (caller != from.owner and not isAuthorized(caller)) {
      return #Err("Unauthorized burn request");
    };

    let targetKey = Principal.toText(from.owner);
    let currentBal = Option.get(balances.get(targetKey), 0);

    if (currentBal < amount) {
      return #Err("Insufficient balance to burn");
    };

    balances.put(targetKey, currentBal - amount);
    total_supply -= amount;
    total_burned_deflationary += amount;

    #Ok(total_supply)
  };

  public shared ({ caller }) func add_authorized_minter(minter : Principal) : async Bool {
    if (caller != admin) { return false };
    authorized_minters.put(minter, true);
    true
  };

  public query func get_total_minted_productivity() : async Nat {
    total_minted_productivity
  };

  public query func get_total_burned_deflationary() : async Nat {
    total_burned_deflationary
  };
};
