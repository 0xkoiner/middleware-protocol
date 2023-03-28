# Middleware Protocol

Minimalistic lending protocol built with Solidity and Foundry.

## Overview

- Deposit ERC-20 tokens as collateral
- Borrow against deposited collateral (subject to LTV)
- Two-slope utilization-based interest rate model
- Liquidation of undercollateralized positions

## Build

```shell
forge build
```

## Test

```shell
forge test -vvv
```

## Format

```shell
forge fmt
```
