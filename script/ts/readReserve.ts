/*
 * Read reserve data for a given asset
 *
 * Usage:
 *   RPC_URL=http://... PRIVATE_KEY=0x... LENDING_POOL=0x... TOKEN_A=0x... tsx readReserve.ts
 */

import { formatUnits } from "viem";
import { publicClient, LENDING_POOL, TOKEN_A } from "./config";
import { lendingPoolAbi } from "./abi";

// --- main ---
async function main() {
  const reserve = await publicClient.readContract({
    address: LENDING_POOL,
    abi: lendingPoolAbi,
    functionName: "getReserveData",
    args: [TOKEN_A],
  });

  console.log("Reserve Data for", TOKEN_A);
  console.log("  Active:             ", reserve.isActive);
  console.log("  Liquidity Index:    ", formatUnits(reserve.liquidityIndex, 27));
  console.log("  Borrow Index:       ", formatUnits(reserve.borrowIndex, 27));
  console.log("  Liquidity Rate:     ", formatUnits(reserve.liquidityRate, 27));
  console.log("  Borrow Rate:        ", formatUnits(reserve.borrowRate, 27));
  console.log("  LTV (bps):          ", reserve.ltvBps);
  console.log("  Liq Threshold (bps):", reserve.liquidationThresholdBps);
  console.log("  mToken:             ", reserve.mTokenAddress);
}

main().catch(console.error);
