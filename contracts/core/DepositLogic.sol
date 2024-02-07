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
/// @author openfort@0xkoiner
/// @notice Deposit and withdraw operations
abstract contract DepositLogic is LendingPoolStorage {
    using MathLib for uint256;
    using ReserveLib for ReserveData;

    /// @notice Deposit assets into a reserve
    /// @dev Mints mTokens proportional to the current normalized income
    /// @param _asset - Address of the asset to deposit
    /// @param _amount - Amount to deposit
    function _deposit(address _asset, uint256 _amount) internal {
        ReserveData storage reserve = _reserves[_asset];
        ValidationLib.validateDeposit(reserve, _amount);

        reserve.updateState(
            interestRateModel, _getTotalDeposits(_asset), _getTotalBorrows(_asset), _asset
        );

        uint256 normalizedIncome = reserve.getNormalizedIncome();
        uint256 shares = _amount.rayDiv(normalizedIncome);
        _userReserves[msg.sender][_asset].depositShares += shares;

        IMiddlewareToken(reserve.mTokenAddress).mint(msg.sender, shares);
        IERC20(_asset).transferFrom(msg.sender, address(this), _amount);

        reserve.updateState(
            interestRateModel, _getTotalDeposits(_asset), _getTotalBorrows(_asset), _asset
        );

        emit Deposit(_asset, msg.sender, _amount);
    }

    /// @notice Withdraw assets from a reserve
    /// @dev Burns mTokens and transfers the underlying asset back
    /// @param _asset - Address of the asset to withdraw
    /// @param _amount - Amount to withdraw (type(uint256).max for full balance)
    function _withdraw(address _asset, uint256 _amount) internal {
        ReserveData storage reserve = _reserves[_asset];
        UserReserveData storage userData = _userReserves[msg.sender][_asset];

        reserve.updateState(
            interestRateModel, _getTotalDeposits(_asset), _getTotalBorrows(_asset), _asset
        );

        uint256 normalizedIncome = reserve.getNormalizedIncome();
        uint256 userDeposit = userData.depositShares.rayMul(normalizedIncome);
        uint256 toWithdraw = _amount == type(uint256).max ? userDeposit : _amount;

        ValidationLib.validateWithdraw(reserve, toWithdraw, userDeposit);

        uint256 sharesToBurn = toWithdraw.rayDiv(normalizedIncome);
        if (sharesToBurn > userData.depositShares) {
            sharesToBurn = userData.depositShares;
        }
        userData.depositShares -= sharesToBurn;

        IMiddlewareToken(reserve.mTokenAddress).burn(msg.sender, sharesToBurn);
        IERC20(_asset).transfer(msg.sender, toWithdraw);

        reserve.updateState(
            interestRateModel, _getTotalDeposits(_asset), _getTotalBorrows(_asset), _asset
        );

        emit Withdraw(_asset, msg.sender, toWithdraw);
    }

    /// @dev Get total liquidity held by the pool for an asset
    function _getTotalDeposits(address _asset) internal view returns (uint256) {
        return IERC20(_asset).balanceOf(address(this));
    }

    /// @dev Get total borrows for an asset
    function _getTotalBorrows(address _asset) internal view virtual returns (uint256);
}
