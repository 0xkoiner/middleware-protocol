// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LendingHelpers} from "../helpers/LendingHelpers.t.sol";
import {TestConstants} from "../data/Constants.sol";
import "../../contracts/type/Errors.sol";
import "../../contracts/type/Events.sol";

contract TestWithdraw is LendingHelpers {
    function test_withdraw_after_interest() public {
        _setupDeposit(alice, tokenA, TestConstants.INITIAL_DEPOSIT);

        // Bob borrows to generate interest
        _setupDeposit(bob, tokenB, TestConstants.INITIAL_DEPOSIT);
        _borrowAs(bob, address(tokenA), TestConstants.BORROW_AMOUNT);

        vm.warp(block.timestamp + 30 days);

        // Alice should be able to withdraw more than she deposited
        uint256 userDeposit = pool.getUserDeposit(alice, address(tokenA));
        assertGe(userDeposit, TestConstants.INITIAL_DEPOSIT);
    }

    function test_withdraw_exceeds_deposit_reverts() public {
        _setupDeposit(alice, tokenA, TestConstants.INITIAL_DEPOSIT);

        vm.prank(alice);
        vm.expectRevert(NotEnoughDeposit.selector);
        pool.withdraw(address(tokenA), TestConstants.INITIAL_DEPOSIT * 2);
    }

    function test_withdraw_emits_event() public {
        _setupDeposit(alice, tokenA, TestConstants.INITIAL_DEPOSIT);

        vm.expectEmit(true, true, false, false);
        emit Withdraw(address(tokenA), alice, 0);

        _withdrawAs(alice, address(tokenA), TestConstants.INITIAL_DEPOSIT);
    }

    function test_withdraw_checks_health_factor() public {
        _setupBorrow(
            alice, bob, tokenB, tokenA,
            TestConstants.INITIAL_DEPOSIT, TestConstants.BORROW_AMOUNT
        );

        // Bob tries to withdraw all collateral while having debt
        vm.prank(bob);
        vm.expectRevert(InsufficientCollateral.selector);
        pool.withdraw(address(tokenB), TestConstants.INITIAL_DEPOSIT);
    }
}
