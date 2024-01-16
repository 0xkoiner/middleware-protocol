/*
 * Borrow tokens from the lending pool
 *
 * Usage:
 *   AMOUNT=500000000000000000 tsx borrow.ts
 */

import { parseUnits } from "viem";
import { publicClient, walletClient, LENDING_POOL, TOKEN_A } from "./config";
import { lendingPoolAbi } from "./abi";

// --- main ---
async function main() {
  const amount = BigInt(process.env.AMOUNT || parseUnits("50", 18).toString());

  const hash = await walletClient.writeContract({
    address: LENDING_POOL,
    abi: lendingPoolAbi,
    functionName: "borrow",
    args: [TOKEN_A, amount],
  });

  const receipt = await publicClient.waitForTransactionReceipt({ hash });
  console.log("Borrowed", amount.toString(), "in tx:", receipt.transactionHash);
}

main().catch(console.error);
