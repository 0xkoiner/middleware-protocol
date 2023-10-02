# Middleware Protocol

Minimalistic lending protocol built with Solidity and Foundry.

## Overview

- Deposit ERC-20 tokens as collateral, receive mTokens
- Borrow against deposited collateral (subject to LTV)
- Two-slope utilization-based interest rate model
- Liquidation of undercollateralized positions with bonus

## Build

```shell
forge build
```

## Test

```shell
forge test -vvv
```

## Deploy

```shell
forge script script/Deploy.s.sol --rpc-url <RPC_URL> --private-key <KEY> --broadcast
```

## Format

```shell
forge fmt
```

## Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/PROTOCOL.md](docs/PROTOCOL.md).
