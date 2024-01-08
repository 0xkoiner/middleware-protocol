/*
 * Middleware Protocol — Viem client configuration
 *
 * Usage:
 *   Set RPC_URL and PRIVATE_KEY env vars before running scripts.
 */

import { createPublicClient, createWalletClient, http } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { localhost } from "viem/chains";

// --- environment ---
const RPC_URL = process.env.RPC_URL || "http://127.0.0.1:8545";
const PRIVATE_KEY = process.env.PRIVATE_KEY as `0x${string}`;

if (!PRIVATE_KEY) {
  throw new Error("PRIVATE_KEY env var is required");
}

// --- clients ---
export const account = privateKeyToAccount(PRIVATE_KEY);

export const publicClient = createPublicClient({
  chain: localhost,
  transport: http(RPC_URL),
});

export const walletClient = createWalletClient({
  account,
  chain: localhost,
  transport: http(RPC_URL),
});

// --- addresses ---
export const LENDING_POOL = process.env.LENDING_POOL as `0x${string}`;
export const TOKEN_A = process.env.TOKEN_A as `0x${string}`;
export const TOKEN_B = process.env.TOKEN_B as `0x${string}`;
