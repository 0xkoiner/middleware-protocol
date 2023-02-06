// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LendingHelpers} from "../helpers/LendingHelpers.t.sol";
import {TestConstants} from "../data/Constants.sol";
import "../../contracts/type/Errors.sol";
import "../../contracts/type/Events.sol";

contract TestRepay is LendingHelpers {
    function test_repay_full() public {
        _setupBorrow(alice, bob, tokenB, tokenA, TestConstants.INITIAL_DEPOSIT, TestConstants.BORROW_AMOUNT);

        _mintAndApprove(bob, tokenA, TestConstants.BORROW_AMOUNT);
        _repayAs(bob, address(tokenA), type(uint256).max);

        uint256 debt = pool.getUserBorrow(bob, address(tokenA));
        assertEq(debt, 0);
    }

    function test_repay_partial() public {
        _setupBorrow(alice, bob, tokenB, tokenA, TestConstants.INITIAL_DEPOSIT, TestConstants.BORROW_AMOUNT);

        uint256 half = TestConstants.BORROW_AMOUNT / 2;
        _mintAndApprove(bob, tokenA, half);
        _repayAs(bob, address(tokenA), half);

        uint256 debt = pool.getUserBorrow(bob, address(tokenA));
        assertGt(debt, 0);
    }

    function test_repay_emits_event() public {
        _setupBorrow(alice, bob, tokenB, tokenA, TestConstants.INITIAL_DEPOSIT, TestConstants.BORROW_AMOUNT);

        _mintAndApprove(bob, tokenA, TestConstants.BORROW_AMOUNT);

        vm.expectEmit(true, true, false, false);
        emit Repay(address(tokenA), bob, 0);

        _repayAs(bob, address(tokenA), type(uint256).max);
    }

    function test_repay_no_debt_reverts() public {
        vm.prank(alice);
        vm.expectRevert(ZeroAmount.selector);
        pool.repay(address(tokenA), 100e18);
    }
}
