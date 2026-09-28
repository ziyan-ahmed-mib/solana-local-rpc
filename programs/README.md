# Metaplex Core binary

`mpl-core.so` was downloaded on 2026-09-28 from Solana mainnet using:

```sh
solana program dump --url https://api.mainnet-beta.solana.com \
  CoREENxT6tW1HoK8ypY1SxRMZTcVPm7R94rH4PZNhX7d mpl-core.so
```

This is a local copy, not an ongoing mainnet connection. The opt-in Compose
configuration loads it at the standard Core address during genesis. Existing
ledgers ignore genesis program-loading flags.

SHA-256: `96fa631a61234766afa538437c5166c628100dbc70e5c3ddb2f306d5dc5a8ba5`

Upstream project and licensing: https://github.com/metaplex-foundation/mpl-core
Setup reference: https://www.metaplex.com/docs/solana/setup-a-local-validator
