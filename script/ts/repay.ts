/*
 * Repay borrowed tokens
 *
 * Usage:
 *   AMOUNT=500000000000000000 tsx repay.ts
 */

import { parseUnits, maxUint256 } from "viem";
import { publicClient, walletClient, LENDING_POOL, TOKEN_A } from "./config";
import { lendingPoolAbi, erc20Abi } from "./abi";

// --- main ---
async function main() {
  const amount = BigInt(process.env.AMOUNT || maxUint256.toString());

  // approve repayment
  const approveHash = await walletClient.writeContract({
    address: TOKEN_A,
    abi: erc20Abi,
    functionName: "approve",
    args: [LENDING_POOL, amount],
  });
  await publicClient.waitForTransactionReceipt({ hash: approveHash });
  console.log("Approved repayment");

  // repay
  const hash = await walletClient.writeContract({
    address: LENDING_POOL,
    abi: lendingPoolAbi,
    functionName: "repay",
    args: [TOKEN_A, amount],
  });

  const receipt = await publicClient.waitForTransactionReceipt({ hash });
  console.log("Repaid in tx:", receipt.transactionHash);
}

main().catch(console.error);
