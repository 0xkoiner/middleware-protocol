// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LendingHelpers} from "../helpers/LendingHelpers.t.sol";
import {TestConstants} from "../data/Constants.sol";
import "../../contracts/type/Errors.sol";
import "../../contracts/type/Events.sol";

contract TestBorrow is LendingHelpers {
    function test_borrow_success() public {
        _setupDeposit(alice, tokenA, TestConstants.INITIAL_DEPOSIT);
        _setupDeposit(bob, tokenB, TestConstants.INITIAL_DEPOSIT);

        _borrowAs(bob, address(tokenA), TestConstants.BORROW_AMOUNT);

        assertEq(tokenA.balanceOf(bob), TestConstants.BORROW_AMOUNT);
    }

    function test_borrow_emits_event() public {
        _setupDeposit(alice, tokenA, TestConstants.INITIAL_DEPOSIT);
        _setupDeposit(bob, tokenB, TestConstants.INITIAL_DEPOSIT);

        vm.expectEmit(true, true, false, true);
        emit Borrow(address(tokenA), bob, TestConstants.BORROW_AMOUNT);

        _borrowAs(bob, address(tokenA), TestConstants.BORROW_AMOUNT);
    }

    function test_borrow_updates_user_debt() public {
        _setupDeposit(alice, tokenA, TestConstants.INITIAL_DEPOSIT);
        _setupDeposit(bob, tokenB, TestConstants.INITIAL_DEPOSIT);

        _borrowAs(bob, address(tokenA), TestConstants.BORROW_AMOUNT);

        uint256 debt = pool.getUserBorrow(bob, address(tokenA));
        assertGe(debt, TestConstants.BORROW_AMOUNT);
    }

    function test_borrow_zero_reverts() public {
        _setupDeposit(alice, tokenA, TestConstants.INITIAL_DEPOSIT);
        _setupDeposit(bob, tokenB, TestConstants.INITIAL_DEPOSIT);

        vm.prank(bob);
        vm.expectRevert(ZeroAmount.selector);
        pool.borrow(address(tokenA), 0);
    }

    function test_borrow_exceeds_liquidity_reverts() public {
        _setupDeposit(alice, tokenA, TestConstants.SMALL_AMOUNT);
        _setupDeposit(bob, tokenB, TestConstants.INITIAL_DEPOSIT);

        vm.prank(bob);
        vm.expectRevert(InsufficientLiquidity.selector);
        pool.borrow(address(tokenA), TestConstants.INITIAL_DEPOSIT);
    }

    function test_borrow_health_factor_check() public {
        _setupDeposit(alice, tokenA, TestConstants.INITIAL_DEPOSIT);
        _setupDeposit(bob, tokenB, TestConstants.INITIAL_DEPOSIT);

        _borrowAs(bob, address(tokenA), TestConstants.BORROW_AMOUNT);

        uint256 hf = pool.getUserHealthFactor(bob);
        assertGe(hf, 1e18);
    }
}
