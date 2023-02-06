// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Helpers} from "./Helpers.t.sol";
import {ERC20Mock} from "./ERC20Mock.sol";

abstract contract LendingHelpers is Helpers {
    function _setupDeposit(
        address _user,
        ERC20Mock _token,
        uint256 _amount
    ) internal {
        _mintAndApprove(_user, _token, _amount);
        _depositAs(_user, address(_token), _amount);
    }

    function _setupBorrow(
        address _depositor,
        address _borrower,
        ERC20Mock _collateralToken,
        ERC20Mock _borrowToken,
        uint256 _collateralAmount,
        uint256 _borrowAmount
    ) internal {
        // Provide liquidity for borrowing
        _setupDeposit(_depositor, _borrowToken, _borrowAmount * 2);
        // Borrower deposits collateral and borrows
        _setupDeposit(_borrower, _collateralToken, _collateralAmount);
        _borrowAs(_borrower, address(_borrowToken), _borrowAmount);
    }
}
