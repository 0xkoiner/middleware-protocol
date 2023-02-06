// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Helpers} from "../helpers/Helpers.t.sol";
import {ReserveData, Constants} from "../../contracts/type/Types.sol";
import "../../contracts/type/Errors.sol";

contract TestDeployment is Helpers {
    function test_pool_owner() public view {
        assertEq(pool.owner(), deployer);
    }

    function test_rate_model_set() public view {
        assertEq(address(pool.interestRateModel()), address(rateModel));
    }

    function test_oracle_set() public view {
        assertEq(address(pool.priceOracle()), address(oracle));
    }

    function test_reserve_initialized() public view {
        ReserveData memory data = pool.getReserveData(address(tokenA));
        assertTrue(data.isActive);
        assertEq(data.liquidityIndex, uint128(Constants.RAY));
        assertEq(data.borrowIndex, uint128(Constants.RAY));
        assertEq(data.ltvBps, 7500);
        assertEq(data.liquidationThresholdBps, 8000);
        assertEq(data.liquidationBonusBps, 500);
    }

    function test_reserve_count() public view {
        address[] memory assets = pool.getReserveAssets();
        assertEq(assets.length, 2);
    }

    function test_cannot_init_duplicate_reserve() public {
        vm.prank(deployer);
        vm.expectRevert(ReserveAlreadyExists.selector);
        pool.initReserve(
            ReserveConfig({
                asset: address(tokenA),
                reserveFactorBps: 1000,
                liquidationThresholdBps: 8000,
                liquidationBonusBps: 500,
                ltvBps: 7500
            })
        );
    }

    function test_only_owner_can_init_reserve() public {
        vm.prank(alice);
        vm.expectRevert(NotOwner.selector);
        pool.initReserve(
            ReserveConfig({
                asset: makeAddr("newToken"),
                reserveFactorBps: 1000,
                liquidationThresholdBps: 8000,
                liquidationBonusBps: 500,
                ltvBps: 7500
            })
        );
    }
}
