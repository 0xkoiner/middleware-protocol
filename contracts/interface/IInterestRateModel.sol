// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title IInterestRateModel
/// @notice Interface for the interest rate calculation model
interface IInterestRateModel {
    /// @notice Calculate liquidity and borrow rates
    /// @param _totalDeposits - Total deposits in the reserve
    /// @param _totalBorrows - Total borrows from the reserve
    /// @param _reserveFactorBps - Reserve factor in basis points
    /// @return liquidityRate Liquidity rate in RAY
    /// @return borrowRate Borrow rate in RAY
    function calculateRates(
        uint256 _totalDeposits,
        uint256 _totalBorrows,
        uint256 _reserveFactorBps
    ) external view returns (uint256 liquidityRate, uint256 borrowRate);

    /// @notice Get utilization rate for given deposits and borrows
    /// @param _totalDeposits - Total deposits in the reserve
    /// @param _totalBorrows - Total borrows from the reserve
    /// @return Utilization rate in RAY
    function getUtilizationRate(
        uint256 _totalDeposits,
        uint256 _totalBorrows
    ) external pure returns (uint256);
}
