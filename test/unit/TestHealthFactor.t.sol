// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LendingHelpers} from "../helpers/LendingHelpers.t.sol";
import {TestConstants} from "../data/Constants.sol";

contract TestHealthFactor is LendingHelpers {
    function test_no_debt_returns_max() public {
        _setupDeposit(alice, tokenA, TestConstants.INITIAL_DEPOSIT);

        uint256 hf = pool.getUserHealthFactor(alice);
        assertEq(hf, type(uint256).max);
    }

    function test_health_factor_decreases_with_price_drop() public {
        _setupBorrow(
            alice, bob, tokenB, tokenA,
            TestConstants.INITIAL_DEPOSIT, TestConstants.BORROW_AMOUNT
        );

        uint256 hfBefore = pool.getUserHealthFactor(bob);

        vm.prank(deployer);
        oracle.setAssetPrice(address(tokenB), TestConstants.TOKEN_B_PRICE / 2);

        uint256 hfAfter = pool.getUserHealthFactor(bob);
        assertLt(hfAfter, hfBefore);
    }

    function test_health_factor_improves_after_repay() public {
        _setupBorrow(
            alice, bob, tokenB, tokenA,
            TestConstants.INITIAL_DEPOSIT, TestConstants.BORROW_AMOUNT
        );

        uint256 hfBefore = pool.getUserHealthFactor(bob);

        uint256 repayAmount = TestConstants.BORROW_AMOUNT / 2;
        _mintAndApprove(bob, tokenA, repayAmount);
        _repayAs(bob, address(tokenA), repayAmount);

        uint256 hfAfter = pool.getUserHealthFactor(bob);
        assertGt(hfAfter, hfBefore);
    }

    function test_empty_user_returns_max() public view {
        uint256 hf = pool.getUserHealthFactor(makeAddr("nobody"));
        assertEq(hf, type(uint256).max);
    }
}
