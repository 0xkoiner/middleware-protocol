// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Helpers} from "../helpers/Helpers.t.sol";
import "../../contracts/type/Errors.sol";

contract TestOracle is Helpers {
    function test_set_price() public {
        vm.prank(deployer);
        oracle.setAssetPrice(address(tokenA), 2e18);

        assertEq(oracle.getAssetPrice(address(tokenA)), 2e18);
    }

    function test_only_owner_can_set_price() public {
        vm.prank(alice);
        vm.expectRevert(NotOwner.selector);
        oracle.setAssetPrice(address(tokenA), 2e18);
    }

    function test_zero_address_reverts() public {
        vm.prank(deployer);
        vm.expectRevert(ZeroAddress.selector);
        oracle.setAssetPrice(address(0), 1e18);
    }

    function test_zero_price_reverts() public {
        vm.prank(deployer);
        vm.expectRevert(ZeroAmount.selector);
        oracle.setAssetPrice(address(tokenA), 0);
    }

    function test_transfer_ownership() public {
        vm.prank(deployer);
        oracle.transferOwnership(alice);

        assertEq(oracle.owner(), alice);

        vm.prank(alice);
        oracle.setAssetPrice(address(tokenA), 5e18);
        assertEq(oracle.getAssetPrice(address(tokenA)), 5e18);
    }
}
