# Solana local RPC

A private Solana test blockchain powered by Agave's `solana-test-validator`, packaged for a Linux Docker server. It provides JSON-RPC, WebSocket subscriptions, test SOL airdrops, and program deployment. Test SOL has no real value; this chain does not connect to mainnet or devnet.

## Start on the server

Use an x86-64 Linux server with Docker Engine and Docker Compose v2. Start with 4 CPU cores, 8 GB RAM, and 30 GB free SSD space for light development; measure and increase these for your workload. The Agave prebuilt binary requires a compatible CPU (including AVX2). ARM servers are not supported by this image.

Copy this directory to the server, then run:

```sh
cp .env.example .env
docker compose up -d --build --wait --wait-timeout 180
docker compose ps
docker compose exec -T validator smoke-test.sh
```

The first build downloads the pinned Agave release. The image runs as an unprivileged user. The ledger lives in a named Docker volume and is reused on restart; startup never resets it.

Agave 4.3 requires Linux `io_uring` support. The included seccomp profile extends Docker's standard profile to allow `io_uring_setup`, `io_uring_enter`, and `io_uring_register`. Use a recent Linux kernel (6.8 or newer recommended) with io_uring enabled. This profile is required at runtime, so copy the `docker/` directory along with the Compose file.

| Interface | Default endpoint |
| --- | --- |
| HTTP JSON-RPC | `http://127.0.0.1:8899` |
| WebSocket | `ws://127.0.0.1:8900` |
| From another service in this Compose project | `http://validator:8899`, `ws://validator:8900` |

If you change the HTTP host port, set the WebSocket host port to HTTP + 1 for clients that derive it automatically. Container ports remain 8899 and 8900.

## Connect your application

Configure your application's RPC URL with the HTTP endpoint above. With an existing `@solana/web3.js` v1 application:

```js
import { Connection } from '@solana/web3.js';

const connection = new Connection('http://127.0.0.1:8899', {
  commitment: 'confirmed',
  wsEndpoint: 'ws://127.0.0.1:8900',
});
console.log(await connection.getSlot());
```

From the host:

```sh
curl --fail http://127.0.0.1:8899 \
  -H 'Content-Type: application/json' \
  --data '{"jsonrpc":"2.0","id":1,"method":"getHealth"}'
```

Expected result: `{"jsonrpc":"2.0","result":"ok","id":1}` (field order may differ).

The container includes the Solana CLI; fund your development wallet with:

```sh
docker compose exec validator solana --url http://127.0.0.1:8899 airdrop 10 YOUR_WALLET_PUBLIC_KEY
```

With a CLI installed on your development machine, use `solana config set --url http://127.0.0.1:8899` and deploy using `solana program deploy /path/to/program.so`. Your deployment wallet needs test SOL first.

## Access from another machine

For development, keep the default localhost binding and forward both ports over SSH:

```sh
ssh -N -L 8899:127.0.0.1:8899 -L 8900:127.0.0.1:8900 user@YOUR_SERVER
```

Then use the local endpoints on your development machine. Alternatively set `RPC_BIND_ADDRESS` in `.env` to the server's private LAN/VPN IP and recreate the service with `docker compose up -d`. Allow both ports only from trusted clients. RPC has no built-in authentication and callers can submit transactions or request test SOL; do not expose it directly to the public internet. A browser wallet's localhost refers to the browser's machine, so use the tunnel or a reachable private endpoint.

## Operations

```sh
docker compose logs --tail=100 -f validator
docker compose restart validator
docker compose stop
docker compose up -d --wait --wait-timeout 180
```

Docker restarts the process after a crash or host reboot unless explicitly stopped. An unhealthy health check reports a problem but does not itself trigger a restart. Enable Docker at boot on the server. `docker compose down` preserves the ledger; `docker compose down --volumes` permanently deletes this chain, wallets stored in its ledger, balances, and programs. Only use the latter when intentionally resetting the test network.

The ledger shred limit bounds retained block history, not total disk usage; account state and snapshots can still grow. Docker logs rotate. Monitor disk space and memory for long-running deployments. For backups, stop the validator and back up the entire ledger volume consistently; retain its keypairs privately. Do not run two validators against the same volume.

Change `AGAVE_VERSION` explicitly and rebuild to upgrade. Back up the ledger first: ledger compatibility across releases is not guaranteed. This is a single-node development chain, without high availability or mainnet consensus participation.

## Troubleshooting

- Port already allocated: change `RPC_PORT` and `WS_PORT` in `.env` and run `docker compose up -d`.
- Startup fails: inspect `docker compose logs --tail=200 validator`. Check CPU compatibility, free memory, and disk space. Increase `RUST_LOG` to `info` if needed and recreate the service.
- Windows development: run Docker Desktop using Linux containers/WSL2, then use the same Compose commands. Use `Copy-Item .env.example .env` in PowerShell.
- No balance/programs from devnet or mainnet: this is an independent chain. Fund local wallets and deploy programs locally.

## References

- [Official Agave installation and binary distribution](https://docs.anza.xyz/cli/install)
- [Pinned Agave v4.3.0 release](https://github.com/anza-xyz/agave/releases/tag/v4.3.0)
- [Solana test validator documentation](https://docs.anza.xyz/cli/examples/test-validator)
