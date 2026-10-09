#!/usr/bin/env bash
set -e

echo "=========================================================="
echo " UHI Protocol Mainnet Deployment Pipeline (Internet Computer)"
echo " Network: ic | Wallet: Cycles Ledger"
echo "=========================================================="

if ! command -v dfx &> /dev/null; then
  echo "Error: dfx CLI is not installed or not in PATH."
  exit 1
fi

echo "Checking ICP Cycles balance..."
dfx cycles balance --network ic || {
  echo "Warning: Ensure you have cycles deposited in your cycles ledger."
}

read -p "Are you sure you want to deploy to ICP MAINNET? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Deployment aborted."
  exit 0
fi

echo "1. Deploying Core Tokens and Vaults..."
dfx deploy --network ic uhi_token --with-cycles 1000000000000
dfx deploy --network ic treasury --with-cycles 1000000000000
dfx deploy --network ic identity_registry --with-cycles 1000000000000
dfx deploy --network ic conway_engine --with-cycles 1000000000000
dfx deploy --network ic pqc_layer --with-cycles 1000000000000
dfx deploy --network ic distribution_engine --with-cycles 1000000000000
dfx deploy --network ic x402_bazaar --with-cycles 1000000000000
dfx deploy --network ic frontend --with-cycles 1500000000000

echo "2. Wire Cross-Canister Authorization on Mainnet..."
TREASURY_ID=$(dfx canister --network ic id treasury)
ENGINE_ID=$(dfx canister --network ic id distribution_engine)
TOKEN_ID=$(dfx canister --network ic id uhi_token)

dfx canister --network ic call treasury set_distribution_engine "(principal \"$ENGINE_ID\")"
dfx canister --network ic call identity_registry set_distribution_engine "(principal \"$ENGINE_ID\")"
dfx canister --network ic call x402_bazaar set_treasury_canister "(principal \"$TREASURY_ID\")"
dfx canister --network ic call uhi_token add_authorized_minter "(principal \"$ENGINE_ID\")"

echo "=========================================================="
echo " MAINNET DEPLOYMENT COMPLETE!"
echo " Frontend live on IC: https://$(dfx canister --network ic id frontend).ic0.app"
echo "=========================================================="
