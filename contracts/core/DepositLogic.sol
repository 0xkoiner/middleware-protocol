// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LendingPoolStorage} from "./LendingPoolStorage.sol";
import {ReserveData, UserReserveData, Constants} from "../type/Types.sol";
import {MathLib} from "../library/MathLib.sol";
import {ReserveLib} from "../library/ReserveLib.sol";
import {ValidationLib} from "../library/ValidationLib.sol";
import {IMiddlewareToken} from "../interface/IMiddlewareToken.sol";
import {IERC20} from "../interface/IERC20.sol";
import "../type/Errors.sol";
import "../type/Events.sol";

/// @title DepositLogic
/// @notice Deposit and withdraw operations
abstract contract DepositLogic is LendingPoolStorage {
    using MathLib for uint256;
    using ReserveLib for ReserveData;

    function _deposit(address _asset, uint256 _amount) internal {
        ReserveData storage reserve = _reserves[_asset];
        ValidationLib.validateDeposit(reserve, _amount);

        reserve.updateState(
            interestRateModel, _getTotalDeposits(_asset), _getTotalBorrows(_asset), _asset
        );

        uint256 shares = _amount.rayDiv(reserve.getNormalizedIncome());
        _userReserves[msg.sender][_asset].depositShares += shares;

        IMiddlewareToken(reserve.mTokenAddress).mint(msg.sender, shares);
        IERC20(_asset).transferFrom(msg.sender, address(this), _amount);

        reserve.updateState(
            interestRateModel, _getTotalDeposits(_asset), _getTotalBorrows(_asset), _asset
        );

        emit Deposit(_asset, msg.sender, _amount);
    }

    function _withdraw(address _asset, uint256 _amount) internal {
        ReserveData storage reserve = _reserves[_asset];
        UserReserveData storage userData = _userReserves[msg.sender][_asset];

        reserve.updateState(
            interestRateModel, _getTotalDeposits(_asset), _getTotalBorrows(_asset), _asset
        );

        uint256 userDeposit = userData.depositShares.rayMul(reserve.getNormalizedIncome());
        uint256 toWithdraw = _amount == type(uint256).max ? userDeposit : _amount;

        ValidationLib.validateWithdraw(reserve, toWithdraw, userDeposit);

        uint256 sharesToBurn = toWithdraw.rayDiv(reserve.getNormalizedIncome());
        userData.depositShares -= sharesToBurn;

        IMiddlewareToken(reserve.mTokenAddress).burn(msg.sender, sharesToBurn);
        IERC20(_asset).transfer(msg.sender, toWithdraw);

        reserve.updateState(
            interestRateModel, _getTotalDeposits(_asset), _getTotalBorrows(_asset), _asset
        );

        emit Withdraw(_asset, msg.sender, toWithdraw);
    }

    function _getTotalDeposits(address _asset) internal view returns (uint256) {
        return IERC20(_asset).balanceOf(address(this));
    }

    function _getTotalBorrows(address _asset) internal view virtual returns (uint256);
}
