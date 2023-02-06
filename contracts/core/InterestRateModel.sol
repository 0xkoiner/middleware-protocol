// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IInterestRateModel} from "../interface/IInterestRateModel.sol";
import {Constants} from "../type/Types.sol";
import {MathLib} from "../library/MathLib.sol";

/// @title InterestRateModel
/// @notice Two-slope utilization-based interest rate model
contract InterestRateModel is IInterestRateModel {
    using MathLib for uint256;

    uint256 public immutable optimalUtilization;
    uint256 public immutable baseRate;
    uint256 public immutable slope1;
    uint256 public immutable slope2;

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
    function getUtilizationRate(
        uint256 _totalDeposits,
        uint256 _totalBorrows
    ) public pure returns (uint256) {
        if (_totalDeposits == 0) return 0;
        return _totalBorrows.rayDiv(_totalDeposits);
    }

    /// @notice Return model parameters
    function getModelParams()
        external
        view
        returns (uint256, uint256, uint256, uint256)
    {
        return (optimalUtilization, baseRate, slope1, slope2);
    }
}
