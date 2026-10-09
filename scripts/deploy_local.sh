#!/usr/bin/env bash
set -e

echo "=========================================================="
echo " Starting UHI Protocol Local Deployment on Internet Computer"
echo "=========================================================="

# Check if dfx is available
if ! command -v dfx &> /dev/null; then
  echo "Error: dfx CLI is not installed or not in PATH."
  echo "Install DFINITY SDK: sh -ci \"\$(curl -fsSL https://internetcomputer.org/install.sh)\""
  exit 1
fi

echo "1. Starting local replica..."
dfx start --background --clean

echo "2. Deploying canisters..."
dfx deploy uhi_token
dfx deploy treasury
dfx deploy identity_registry
dfx deploy conway_engine
dfx deploy pqc_layer
dfx deploy distribution_engine
dfx deploy x402_bazaar
dfx deploy frontend

echo "3. Linking Canister Access Controls..."
TREASURY_ID=$(dfx canister id treasury)
ENGINE_ID=$(dfx canister id distribution_engine)
TOKEN_ID=$(dfx canister id uhi_token)

dfx canister call treasury set_distribution_engine "(principal \"$ENGINE_ID\")"
dfx canister call identity_registry set_distribution_engine "(principal \"$ENGINE_ID\")"
dfx canister call x402_bazaar set_treasury_canister "(principal \"$TREASURY_ID\")"
dfx canister call uhi_token add_authorized_minter "(principal \"$ENGINE_ID\")"

echo "=========================================================="
echo " UHI Protocol deployed successfully to local replica!"
echo " Frontend URL: http://localhost:4943/?canisterId=$(dfx canister id frontend)"
echo "=========================================================="
