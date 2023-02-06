// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LendingHelpers} from "../helpers/LendingHelpers.t.sol";
import {TestConstants} from "../data/Constants.sol";
import "../../contracts/type/Errors.sol";
import "../../contracts/type/Events.sol";

contract TestLiquidation is LendingHelpers {
    function test_liquidation_success() public {
        // Setup: bob borrows tokenA against tokenB collateral
        _setupBorrow(
            alice, bob, tokenB, tokenA,
            TestConstants.INITIAL_DEPOSIT, TestConstants.BORROW_AMOUNT
        );

        // Drop collateral price to make bob undercollateralized
        vm.prank(deployer);
        oracle.setAssetPrice(address(tokenB), 1e18);

        uint256 hf = pool.getUserHealthFactor(bob);
        assertLt(hf, 1e18);

        // Liquidator repays part of bob's debt
        uint256 debtToCover = TestConstants.BORROW_AMOUNT / 4;
        _mintAndApprove(liquidator, tokenA, debtToCover);

        vm.prank(liquidator);
        pool.liquidate(address(tokenB), address(tokenA), bob, debtToCover);

        // Verify liquidator received collateral
        assertGt(tokenB.balanceOf(liquidator), 0);
    }

    function test_liquidation_healthy_reverts() public {
        _setupBorrow(
            alice, bob, tokenB, tokenA,
            TestConstants.INITIAL_DEPOSIT, TestConstants.BORROW_AMOUNT
        );

        _mintAndApprove(liquidator, tokenA, TestConstants.BORROW_AMOUNT);

        vm.prank(liquidator);
        vm.expectRevert(HealthFactorAboveThreshold.selector);
        pool.liquidate(address(tokenB), address(tokenA), bob, TestConstants.BORROW_AMOUNT);
    }

    function test_self_liquidation_reverts() public {
        _setupBorrow(
            alice, bob, tokenB, tokenA,
            TestConstants.INITIAL_DEPOSIT, TestConstants.BORROW_AMOUNT
        );

        vm.prank(deployer);
        oracle.setAssetPrice(address(tokenB), 1e18);

        _mintAndApprove(bob, tokenA, TestConstants.BORROW_AMOUNT);

        vm.prank(bob);
        vm.expectRevert(SelfLiquidation.selector);
        pool.liquidate(address(tokenB), address(tokenA), bob, TestConstants.BORROW_AMOUNT);
    }

    function test_liquidation_emits_event() public {
        _setupBorrow(
            alice, bob, tokenB, tokenA,
            TestConstants.INITIAL_DEPOSIT, TestConstants.BORROW_AMOUNT
        );

        vm.prank(deployer);
        oracle.setAssetPrice(address(tokenB), 1e18);

        uint256 debtToCover = TestConstants.BORROW_AMOUNT / 4;
        _mintAndApprove(liquidator, tokenA, debtToCover);

        vm.expectEmit(true, true, true, false);
        emit Liquidation(address(tokenB), address(tokenA), bob, 0, 0);

        vm.prank(liquidator);
        pool.liquidate(address(tokenB), address(tokenA), bob, debtToCover);
    }

    function test_liquidation_respects_close_factor() public {
        _setupBorrow(
            alice, bob, tokenB, tokenA,
            TestConstants.INITIAL_DEPOSIT, TestConstants.BORROW_AMOUNT
        );

        vm.prank(deployer);
        oracle.setAssetPrice(address(tokenB), 1e18);

        // Try to liquidate more than close factor allows
        _mintAndApprove(liquidator, tokenA, TestConstants.BORROW_AMOUNT);

        vm.prank(liquidator);
        pool.liquidate(address(tokenB), address(tokenA), bob, TestConstants.BORROW_AMOUNT);

        // Debt should still exist (only 50% can be liquidated at once)
        uint256 remainingDebt = pool.getUserBorrow(bob, address(tokenA));
        assertGt(remainingDebt, 0);
    }
}
