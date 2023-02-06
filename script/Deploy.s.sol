// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import {LendingPool} from "../contracts/core/LendingPool.sol";
import {InterestRateModel} from "../contracts/core/InterestRateModel.sol";
import {PriceOracle} from "../contracts/utils/PriceOracle.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        InterestRateModel rateModel = new InterestRateModel(
            0.8e27,  // 80% optimal utilization
            0.02e27, // 2% base rate
            0.04e27, // 4% slope1
            0.75e27  // 75% slope2
        );

        PriceOracle oracle = new PriceOracle();

        new LendingPool(address(rateModel), address(oracle));

        vm.stopBroadcast();
    }
}
