// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {LendingPool} from "../../contracts/core/LendingPool.sol";
import {InterestRateModel} from "../../contracts/core/InterestRateModel.sol";
import {PriceOracle} from "../../contracts/utils/PriceOracle.sol";
import {ReserveConfig} from "../../contracts/type/Types.sol";
import {TestConstants} from "./Constants.sol";
import {ERC20Mock} from "../helpers/ERC20Mock.sol";

abstract contract TestData is Test {
    LendingPool internal pool;
    InterestRateModel internal rateModel;
    PriceOracle internal oracle;
    ERC20Mock internal tokenA;
    ERC20Mock internal tokenB;

    address internal deployer = makeAddr("deployer");
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal liquidator = makeAddr("liquidator");

    function setUp() public virtual {
        vm.startPrank(deployer);

        rateModel = new InterestRateModel(
            TestConstants.OPTIMAL_UTILIZATION,
            TestConstants.BASE_RATE,
            TestConstants.SLOPE1,
            TestConstants.SLOPE2
        );

        oracle = new PriceOracle();
        pool = new LendingPool(address(rateModel), address(oracle));

        tokenA = new ERC20Mock("Token A", "TKNA", 18);
        tokenB = new ERC20Mock("Token B", "TKNB", 18);

        oracle.setAssetPrice(address(tokenA), TestConstants.TOKEN_A_PRICE);
        oracle.setAssetPrice(address(tokenB), TestConstants.TOKEN_B_PRICE);

        pool.initReserve(
            ReserveConfig({
                asset: address(tokenA),
                reserveFactorBps: TestConstants.RESERVE_FACTOR,
                liquidationThresholdBps: TestConstants.LIQ_THRESHOLD,
                liquidationBonusBps: TestConstants.LIQ_BONUS,
                ltvBps: TestConstants.LTV
            })
        );

        pool.initReserve(
            ReserveConfig({
                asset: address(tokenB),
                reserveFactorBps: TestConstants.RESERVE_FACTOR,
                liquidationThresholdBps: TestConstants.LIQ_THRESHOLD,
                liquidationBonusBps: TestConstants.LIQ_BONUS,
                ltvBps: TestConstants.LTV
            })
        );

        vm.stopPrank();
    }
}
