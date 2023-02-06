// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LendingHelpers} from "../helpers/LendingHelpers.t.sol";
import {TestConstants} from "../data/Constants.sol";
import {Constants} from "../../contracts/type/Types.sol";

contract TestInterestRate is LendingHelpers {
    function test_zero_utilization() public view {
        uint256 util = rateModel.getUtilizationRate(1000e18, 0);
        assertEq(util, 0);
    }

    function test_utilization_rate() public view {
        uint256 util = rateModel.getUtilizationRate(1000e18, 500e18);
        assertEq(util, 0.5e27);
    }

    function test_rates_below_optimal() public view {
        (uint256 liqRate, uint256 borrowRate) = rateModel.calculateRates(1000e18, 500e18, 1000);
        assertGt(borrowRate, 0);
        assertGt(liqRate, 0);
        assertLt(liqRate, borrowRate);
    }

    function test_rates_above_optimal() public view {
        (uint256 liqRate, uint256 borrowRate) = rateModel.calculateRates(1000e18, 900e18, 1000);
        assertGt(borrowRate, TestConstants.BASE_RATE + TestConstants.SLOPE1);
        assertGt(liqRate, 0);
    }

    function test_rates_at_full_utilization() public view {
        (uint256 liqRate, uint256 borrowRate) = rateModel.calculateRates(1000e18, 1000e18, 1000);
        uint256 maxRate = TestConstants.BASE_RATE + TestConstants.SLOPE1 + TestConstants.SLOPE2;
        assertEq(borrowRate, maxRate);
        assertGt(liqRate, 0);
    }

    function test_interest_accrual_over_time() public {
        _setupBorrow(
            alice, bob, tokenB, tokenA,
            TestConstants.INITIAL_DEPOSIT, TestConstants.BORROW_AMOUNT
        );

        uint256 debtBefore = pool.getUserBorrow(bob, address(tokenA));
        vm.warp(block.timestamp + 365 days);
        uint256 debtAfter = pool.getUserBorrow(bob, address(tokenA));

        assertGt(debtAfter, debtBefore);
    }

    function test_model_params() public view {
        (uint256 optimal, uint256 base, uint256 s1, uint256 s2) = rateModel.getModelParams();
        assertEq(optimal, TestConstants.OPTIMAL_UTILIZATION);
        assertEq(base, TestConstants.BASE_RATE);
        assertEq(s1, TestConstants.SLOPE1);
        assertEq(s2, TestConstants.SLOPE2);
    }
}
