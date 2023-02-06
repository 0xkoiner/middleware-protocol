// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LendingHelpers} from "../helpers/LendingHelpers.t.sol";
import {TestConstants} from "../data/Constants.sol";
import {ReserveData} from "../../contracts/type/Types.sol";
import {IMiddlewareToken} from "../../contracts/interface/IMiddlewareToken.sol";
import "../../contracts/type/Errors.sol";
import "../../contracts/type/Events.sol";

contract TestDeposit is LendingHelpers {
    function test_deposit_transfers_tokens() public {
        _mintAndApprove(alice, tokenA, TestConstants.INITIAL_DEPOSIT);
        _depositAs(alice, address(tokenA), TestConstants.INITIAL_DEPOSIT);

        assertEq(tokenA.balanceOf(address(pool)), TestConstants.INITIAL_DEPOSIT);
        assertEq(tokenA.balanceOf(alice), 0);
    }

    function test_deposit_mints_mTokens() public {
        _mintAndApprove(alice, tokenA, TestConstants.INITIAL_DEPOSIT);
        _depositAs(alice, address(tokenA), TestConstants.INITIAL_DEPOSIT);

        ReserveData memory data = pool.getReserveData(address(tokenA));
        uint256 mBalance = IMiddlewareToken(data.mTokenAddress).balanceOf(alice);
        assertGt(mBalance, 0);
    }

    function test_deposit_zero_reverts() public {
        vm.prank(alice);
        vm.expectRevert(ZeroAmount.selector);
        pool.deposit(address(tokenA), 0);
    }

    function test_deposit_emits_event() public {
        _mintAndApprove(alice, tokenA, TestConstants.INITIAL_DEPOSIT);

        vm.expectEmit(true, true, false, true);
        emit Deposit(address(tokenA), alice, TestConstants.INITIAL_DEPOSIT);

        _depositAs(alice, address(tokenA), TestConstants.INITIAL_DEPOSIT);
    }

    function test_deposit_multiple_users() public {
        _mintAndApprove(alice, tokenA, TestConstants.INITIAL_DEPOSIT);
        _mintAndApprove(bob, tokenA, TestConstants.INITIAL_DEPOSIT);

        _depositAs(alice, address(tokenA), TestConstants.INITIAL_DEPOSIT);
        _depositAs(bob, address(tokenA), TestConstants.INITIAL_DEPOSIT);

        assertEq(tokenA.balanceOf(address(pool)), TestConstants.INITIAL_DEPOSIT * 2);
    }

    function test_withdraw_full() public {
        _setupDeposit(alice, tokenA, TestConstants.INITIAL_DEPOSIT);

        _withdrawAs(alice, address(tokenA), type(uint256).max);

        assertEq(tokenA.balanceOf(alice), TestConstants.INITIAL_DEPOSIT);
    }

    function test_withdraw_partial() public {
        _setupDeposit(alice, tokenA, TestConstants.INITIAL_DEPOSIT);
        uint256 half = TestConstants.INITIAL_DEPOSIT / 2;

        _withdrawAs(alice, address(tokenA), half);

        assertEq(tokenA.balanceOf(alice), half);
    }

    function test_withdraw_zero_reverts() public {
        _setupDeposit(alice, tokenA, TestConstants.INITIAL_DEPOSIT);

        vm.prank(alice);
        vm.expectRevert(ZeroAmount.selector);
        pool.withdraw(address(tokenA), 0);
    }
}
