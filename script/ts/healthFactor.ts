/*
 * Check a user's health factor
 *
 * Usage:
 *   USER=0x... tsx healthFactor.ts
 */

import { formatUnits } from "viem";
import { publicClient, account, LENDING_POOL } from "./config";
import { lendingPoolAbi } from "./abi";

/** Format a WAD value to a readable string */
function formatWad(value: bigint): string {
  return formatUnits(value, 18);
}

// --- main ---
async function main() {
  const user = (process.env.USER || account.address) as `0x${string}`;

  const healthFactor = await publicClient.readContract({
    address: LENDING_POOL,
    abi: lendingPoolAbi,
    functionName: "getUserHealthFactor",
    args: [user],
  });

  const MAX_UINT256 = 2n ** 256n - 1n;

  if (healthFactor === MAX_UINT256) {
    console.log("Health Factor: MAX (no borrows)");
  } else {
    console.log("Health Factor:", formatWad(healthFactor));
    if (healthFactor < BigInt(1e18)) {
      console.log("WARNING: Position is liquidatable");
    }
  }
}

main().catch(console.error);
