// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {TestData} from "../data/Data.t.sol";
import {ERC20Mock} from "./ERC20Mock.sol";

abstract contract Helpers is TestData {
    function _mintAndApprove(address _user, ERC20Mock _token, uint256 _amount) internal {
        _token.mint(_user, _amount);
        vm.prank(_user);
        _token.approve(address(pool), _amount);
    }

    function _depositAs(address _user, address _asset, uint256 _amount) internal {
        vm.prank(_user);
        pool.deposit(_asset, _amount);
    }

    function _borrowAs(address _user, address _asset, uint256 _amount) internal {
        vm.prank(_user);
        pool.borrow(_asset, _amount);
    }

    function _repayAs(address _user, address _asset, uint256 _amount) internal {
        vm.prank(_user);
        pool.repay(_asset, _amount);
    }

    function _withdrawAs(address _user, address _asset, uint256 _amount) internal {
        vm.prank(_user);
        pool.withdraw(_asset, _amount);
    }
}
