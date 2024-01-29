# Viem Interaction Scripts

TypeScript scripts for interacting with the Middleware lending pool using [viem](https://viem.sh/).

## Setup

```bash
cd script/ts
npm install
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `RPC_URL` | JSON-RPC endpoint (default: `http://127.0.0.1:8545`) |
| `PRIVATE_KEY` | Deployer/user private key (`0x...`) |
| `LENDING_POOL` | Deployed LendingPool address |
| `TOKEN_A` | First reserve token address |
| `TOKEN_B` | Second reserve token address |

## Scripts

```bash
# Read reserve data
npx tsx readReserve.ts

# Deposit 100 tokens
AMOUNT=100000000000000000000 npx tsx deposit.ts

# Borrow 50 tokens
AMOUNT=50000000000000000000 npx tsx borrow.ts

# Check health factor
USER=0x... npx tsx healthFactor.ts

# Repay all debt
npx tsx repay.ts

# Liquidate a position
USER=0x... DEBT_AMOUNT=50000000000000000000 npx tsx liquidate.ts
```
