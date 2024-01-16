/*
 * Approve and deposit tokens into the lending pool
 *
 * Usage:
 *   AMOUNT=1000000000000000000 tsx deposit.ts
 */

import { parseUnits } from "viem";
import { publicClient, walletClient, LENDING_POOL, TOKEN_A } from "./config";
import { lendingPoolAbi, erc20Abi } from "./abi";

// --- main ---
async function main() {
  const amount = BigInt(process.env.AMOUNT || parseUnits("100", 18).toString());

  // approve
  const approveHash = await walletClient.writeContract({
    address: TOKEN_A,
    abi: erc20Abi,
    functionName: "approve",
    args: [LENDING_POOL, amount],
  });
  await publicClient.waitForTransactionReceipt({ hash: approveHash });
  console.log("Approved", amount.toString(), "tokens");

  // deposit
  const depositHash = await walletClient.writeContract({
    address: LENDING_POOL,
    abi: lendingPoolAbi,
    functionName: "deposit",
    args: [TOKEN_A, amount],
  });
  const receipt = await publicClient.waitForTransactionReceipt({ hash: depositHash });
  console.log("Deposited in tx:", receipt.transactionHash);
}

main().catch(console.error);
