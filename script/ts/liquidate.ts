/*
 * Liquidate an undercollateralized position
 *
 * Usage:
 *   USER=0x... DEBT_AMOUNT=100000000000000000 tsx liquidate.ts
 */

import { parseUnits } from "viem";
import { publicClient, walletClient, LENDING_POOL, TOKEN_A, TOKEN_B } from "./config";
import { lendingPoolAbi, erc20Abi } from "./abi";

// --- main ---
async function main() {
  const user = process.env.USER as `0x${string}`;
  if (!user) throw new Error("USER env var is required");

  const debtAmount = BigInt(process.env.DEBT_AMOUNT || parseUnits("50", 18).toString());

  // approve debt repayment
  const approveHash = await walletClient.writeContract({
    address: TOKEN_A,
    abi: erc20Abi,
    functionName: "approve",
    args: [LENDING_POOL, debtAmount],
  });
  await publicClient.waitForTransactionReceipt({ hash: approveHash });
  console.log("Approved debt token for liquidation");

  // liquidate: seize TOKEN_B collateral by repaying TOKEN_A debt
  const hash = await walletClient.writeContract({
    address: LENDING_POOL,
    abi: lendingPoolAbi,
    functionName: "liquidate",
    args: [TOKEN_B, TOKEN_A, user, debtAmount],
  });

  const receipt = await publicClient.waitForTransactionReceipt({ hash });
  console.log("Liquidated in tx:", receipt.transactionHash);
}

main().catch(console.error);
