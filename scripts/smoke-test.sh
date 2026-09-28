#!/bin/sh
# Creates temporary test wallets and performs real transactions on the local chain.
set -eu
wallet_dir=$(mktemp -d)
trap 'rm -rf "$wallet_dir"' EXIT HUP INT TERM
rpc=http://127.0.0.1:8899
healthcheck.sh
solana-keygen new --no-bip39-passphrase --silent --outfile "$wallet_dir/sender.json"
solana-keygen new --no-bip39-passphrase --silent --outfile "$wallet_dir/receiver.json"
receiver=$(solana-keygen pubkey "$wallet_dir/receiver.json")
solana --url "$rpc" --keypair "$wallet_dir/sender.json" --commitment confirmed airdrop 2
solana --url "$rpc" --keypair "$wallet_dir/sender.json" --commitment confirmed \
  transfer "$receiver" 1 --allow-unfunded-recipient
balance=$(solana --url "$rpc" --commitment confirmed balance "$receiver" --lamports)
test "$balance" = '1000000000 lamports'
printf 'PASS: healthy RPC, airdrop, confirmed transfer, recipient balance = 1 SOL\n'
