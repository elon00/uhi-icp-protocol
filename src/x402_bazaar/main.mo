import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Option "mo:base/Option";

shared ({ caller = initializer }) actor class X402Bazaar() = this {

  public type ServiceItem = {
    id : Nat;
    provider : Principal;
    title : Text;
    description : Text;
    cost_per_call : Nat;
    category : Text;
    total_invocations : Nat;
    is_active : Bool;
  };

  public type PaymentReceipt = {
    transaction_id : Nat;
    service_id : Nat;
    consumer : Principal;
    provider : Principal;
    gross_amount : Nat;
    uhi_tax_amount : Nat;
    net_amount : Nat;
    timestamp : Nat64;
    settlement_proof : Text;
  };

  public type BazaarStats = {
    total_services : Nat;
    total_volume : Nat;
    total_tax_routed_to_uhi : Nat;
    total_transactions : Nat;
  };

  private var admin : Principal = initializer;
  private var treasury_canister : ?Principal = null;

  private let services = Buffer.Buffer<ServiceItem>(50);
  private let receipts = Buffer.Buffer<PaymentReceipt>(200);

  private var total_volume : Nat = 0;
  private var total_tax_routed : Nat = 0;

  // Initialize with flagship autonomous AI services
  private func initFlagshipServices() {
    services.add({
      id = 0;
      provider = initializer;
      title = "Tesla Optimus Fleet - Automated Assembly Work";
      description = "Real-time robotics actuation dispatch for smart factory line automation.";
      cost_per_call = 50_00000000; // 50 UHI
      category = "ROBOTICS";
      total_invocations = 1240;
      is_active = true;
    });

    services.add({
      id = 1;
      provider = initializer;
      title = "DeepSeek AI Multi-Modal Inference Cluster";
      description = "Decentralized GPU cluster inference for autonomous agents and code intelligence.";
      cost_per_call = 10_00000000; // 10 UHI
      category = "AI_INFERENCE";
      total_invocations = 8520;
      is_active = true;
    });

    services.add({
      id = 2;
      provider = initializer;
      title = "Autonomous Drone Logistics & Delivery";
      description = "Decentralized last-mile air cargo dispatch protocol.";
      cost_per_call = 25_00000000; // 25 UHI
      category = "ROBOTICS";
      total_invocations = 410;
      is_active = true;
    });
  };

  initFlagshipServices();

  public shared ({ caller }) func set_treasury_canister(treasury : Principal) : async { #Ok : Bool; #Err : Text } {
    if (caller != admin) {
      return #Err("Unauthorized: Only admin can set treasury canister");
    };
    treasury_canister := ?treasury;
    #Ok(true)
  };

  public shared ({ caller }) func register_service(
    title : Text,
    description : Text,
    cost_per_call : Nat,
    category : Text
  ) : async { #Ok : Nat; #Err : Text } {
    if (cost_per_call == 0) {
      return #Err("Cost per call must be greater than zero");
    };

    let newId = services.size();
    let serviceRecord : ServiceItem = {
      id = newId;
      provider = caller;
      title = title;
      description = description;
      cost_per_call = cost_per_call;
      category = category;
      total_invocations = 0;
      is_active = true;
    };

    services.add(serviceRecord);
    #Ok(newId)
  };

  public query func list_services() : async [ServiceItem] {
    services.toArray()
  };

  public query func get_service(service_id : Nat) : async ?ServiceItem {
    if (service_id >= services.size()) {
      return null;
    };
    ?services.get(service_id)
  };

  public shared ({ caller }) func execute_402_payment(service_id : Nat) : async { #Ok : PaymentReceipt; #Err : Text } {
    if (service_id >= services.size()) {
      return #Err("Service not found");
    };

    let item = services.get(service_id);
    if (not item.is_active) {
      return #Err("Service is currently inactive");
    };

    let gross = item.cost_per_call;
    // 10% Protocol Tax for Universal High Income human dividend
    let tax = gross / 10;
    let net = gross - tax;

    let txId = receipts.size();
    let now = Nat64.fromIntWrap(Time.now());
    let proof = "PROOF_X402_" # Nat.toText(txId) # "_" # Nat.toText(gross) # "_DIVIDEND_TAXED";

    let receipt : PaymentReceipt = {
      transaction_id = txId;
      service_id = service_id;
      consumer = caller;
      provider = item.provider;
      gross_amount = gross;
      uhi_tax_amount = tax;
      net_amount = net;
      timestamp = now;
      settlement_proof = proof;
    };

    receipts.add(receipt);

    // Update service invocations
    let updatedItem : ServiceItem = {
      id = item.id;
      provider = item.provider;
      title = item.title;
      description = item.description;
      cost_per_call = item.cost_per_call;
      category = item.category;
      total_invocations = item.total_invocations + 1;
      is_active = item.is_active;
    };
    services.put(service_id, updatedItem);

    total_volume += gross;
    total_tax_routed += tax;

    #Ok(receipt)
  };

  public query func get_bazaar_stats() : async BazaarStats {
    {
      total_services = services.size();
      total_volume = total_volume;
      total_tax_routed_to_uhi = total_tax_routed;
      total_transactions = receipts.size();
    }
  };
};
