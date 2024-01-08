/*
 * Middleware Protocol — ABI fragments for viem scripts
 */

// --- LendingPool ---
export const lendingPoolAbi = [
  {
    name: "deposit",
    type: "function",
    stateMutability: "nonpayable",
    inputs: [
      { name: "_asset", type: "address" },
      { name: "_amount", type: "uint256" },
    ],
    outputs: [],
  },
  {
    name: "withdraw",
    type: "function",
    stateMutability: "nonpayable",
    inputs: [
      { name: "_asset", type: "address" },
      { name: "_amount", type: "uint256" },
    ],
    outputs: [],
  },
  {
    name: "borrow",
    type: "function",
    stateMutability: "nonpayable",
    inputs: [
      { name: "_asset", type: "address" },
      { name: "_amount", type: "uint256" },
    ],
    outputs: [],
  },
  {
    name: "repay",
    type: "function",
    stateMutability: "nonpayable",
    inputs: [
      { name: "_asset", type: "address" },
      { name: "_amount", type: "uint256" },
    ],
    outputs: [],
  },
  {
    name: "liquidate",
    type: "function",
    stateMutability: "nonpayable",
    inputs: [
      { name: "_collateralAsset", type: "address" },
      { name: "_debtAsset", type: "address" },
      { name: "_user", type: "address" },
      { name: "_debtAmount", type: "uint256" },
    ],
    outputs: [],
  },
  {
    name: "getReserveData",
    type: "function",
    stateMutability: "view",
    inputs: [{ name: "_asset", type: "address" }],
    outputs: [
      {
        name: "",
        type: "tuple",
        components: [
          { name: "liquidityIndex", type: "uint128" },
          { name: "borrowIndex", type: "uint128" },
          { name: "liquidityRate", type: "uint128" },
          { name: "borrowRate", type: "uint128" },
          { name: "lastUpdateTimestamp", type: "uint40" },
          { name: "mTokenAddress", type: "address" },
          { name: "reserveFactorBps", type: "uint16" },
          { name: "liquidationThresholdBps", type: "uint16" },
          { name: "liquidationBonusBps", type: "uint16" },
          { name: "ltvBps", type: "uint16" },
          { name: "isActive", type: "bool" },
        ],
      },
    ],
  },
  {
    name: "getUserHealthFactor",
    type: "function",
    stateMutability: "view",
    inputs: [{ name: "_user", type: "address" }],
    outputs: [{ name: "", type: "uint256" }],
  },
  {
    name: "getUserDeposit",
    type: "function",
    stateMutability: "view",
    inputs: [
      { name: "_user", type: "address" },
      { name: "_asset", type: "address" },
    ],
    outputs: [{ name: "", type: "uint256" }],
  },
  {
    name: "getUserBorrow",
    type: "function",
    stateMutability: "view",
    inputs: [
      { name: "_user", type: "address" },
      { name: "_asset", type: "address" },
    ],
    outputs: [{ name: "", type: "uint256" }],
  },
] as const;

// --- ERC-20 ---
export const erc20Abi = [
  {
    name: "approve",
    type: "function",
    stateMutability: "nonpayable",
    inputs: [
      { name: "_spender", type: "address" },
      { name: "_amount", type: "uint256" },
    ],
    outputs: [{ name: "", type: "bool" }],
  },
  {
    name: "balanceOf",
    type: "function",
    stateMutability: "view",
    inputs: [{ name: "_account", type: "address" }],
    outputs: [{ name: "", type: "uint256" }],
  },
] as const;
