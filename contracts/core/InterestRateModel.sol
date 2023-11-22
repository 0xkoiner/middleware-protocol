// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IInterestRateModel} from "../interface/IInterestRateModel.sol";
import {Constants} from "../type/Types.sol";
import {MathLib} from "../library/MathLib.sol";

/// @title InterestRateModel
/// @author openfort@0xkoiner
/// @notice Two-slope utilization-based interest rate model
contract InterestRateModel is IInterestRateModel {
    using MathLib for uint256;

    /// @dev Target utilization ratio (RAY)
    uint256 public immutable optimalUtilization;
    /// @dev Base borrow rate (RAY)
    uint256 public immutable baseRate;
    /// @dev Rate slope below optimal utilization (RAY)
    uint256 public immutable slope1;
    /// @dev Rate slope above optimal utilization (RAY)
    uint256 public immutable slope2;

    /// @param _optimalUtilization - Target utilization in RAY
    /// @param _baseRate - Base borrow rate in RAY
    /// @param _slope1 - Slope below optimal in RAY
    /// @param _slope2 - Slope above optimal in RAY
    constructor(
        uint256 _optimalUtilization,
        uint256 _baseRate,
        uint256 _slope1,
        uint256 _slope2
    ) {
        optimalUtilization = _optimalUtilization;
        baseRate = _baseRate;
        slope1 = _slope1;
        slope2 = _slope2;
    }

    /// @notice Calculate liquidity and borrow rates based on utilization
    /// @param _totalDeposits - Total deposits in the reserve
    /// @param _totalBorrows - Total borrows from the reserve
    /// @param _reserveFactorBps - Reserve factor in basis points
    /// @return liquidityRate Liquidity rate in RAY
    /// @return borrowRate Borrow rate in RAY
    function calculateRates(
        uint256 _totalDeposits,
        uint256 _totalBorrows,
        uint256 _reserveFactorBps
    ) external view returns (uint256 liquidityRate, uint256 borrowRate) {
        uint256 utilization = getUtilizationRate(_totalDeposits, _totalBorrows);

        if (utilization <= optimalUtilization) {
            borrowRate = baseRate + utilization.rayMul(slope1).rayDiv(optimalUtilization);
        } else {
            uint256 excessUtil = utilization - optimalUtilization;
            uint256 maxExcess = Constants.RAY - optimalUtilization;
            borrowRate = baseRate + slope1 + excessUtil.rayMul(slope2).rayDiv(maxExcess);
        }

        uint256 reserveFactor = _reserveFactorBps * Constants.RAY / Constants.BPS;
        liquidityRate = borrowRate.rayMul(utilization).rayMul(Constants.RAY - reserveFactor);
    }

    /// @notice Utilization = totalBorrows / totalDeposits (in RAY)
    /// @param _totalDeposits - Total deposits in the reserve
    /// @param _totalBorrows - Total borrows from the reserve
    /// @return Utilization rate in RAY
    function getUtilizationRate(
        uint256 _totalDeposits,
        uint256 _totalBorrows
    ) public pure returns (uint256) {
        if (_totalDeposits == 0) return 0;
        return _totalBorrows.rayDiv(_totalDeposits);
    }

    /// @notice Return model parameters
    /// @return Optimal utilization, base rate, slope1, slope2
    function getModelParams()
        external
        view
        returns (uint256, uint256, uint256, uint256)
    {
        return (optimalUtilization, baseRate, slope1, slope2);
    }
}
