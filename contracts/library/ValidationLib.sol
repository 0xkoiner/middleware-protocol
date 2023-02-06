// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ReserveData, Constants} from "../type/Types.sol";
import "../type/Errors.sol";

/// @title ValidationLib
/// @notice Input validation for lending pool operations
library ValidationLib {
    function validateDeposit(ReserveData storage _reserve, uint256 _amount) internal view {
        if (_amount == 0) revert ZeroAmount();
        if (!_reserve.isActive) revert ReserveNotActive();
    }

    function validateWithdraw(
        ReserveData storage _reserve,
        uint256 _amount,
        uint256 _userDeposit
    ) internal view {
        if (_amount == 0) revert ZeroAmount();
        if (!_reserve.isActive) revert ReserveNotActive();
        if (_amount > _userDeposit) revert NotEnoughDeposit();
    }

    function validateBorrow(
        ReserveData storage _reserve,
        uint256 _amount,
        uint256 _availableLiquidity
    ) internal view {
        if (_amount == 0) revert ZeroAmount();
        if (!_reserve.isActive) revert ReserveNotActive();
        if (_amount > _availableLiquidity) revert InsufficientLiquidity();
    }

    function validateLiquidation(
        ReserveData storage _collateralReserve,
        ReserveData storage _debtReserve,
        uint256 _healthFactor
    ) internal view {
        if (!_collateralReserve.isActive) revert ReserveNotActive();
        if (!_debtReserve.isActive) revert ReserveNotActive();
        if (_healthFactor >= Constants.HEALTH_FACTOR_THRESHOLD) {
            revert HealthFactorAboveThreshold();
        }
    }

    function validateInitReserve(
        ReserveData storage _reserve,
        address _asset,
        uint16 _ltvBps,
        uint16 _liquidationThresholdBps
    ) internal view {
        if (_asset == address(0)) revert ZeroAddress();
        if (_reserve.isActive) revert ReserveAlreadyExists();
        if (_ltvBps > _liquidationThresholdBps) revert InvalidParameter();
        if (_liquidationThresholdBps > uint16(Constants.BPS)) revert InvalidParameter();
    }
}
