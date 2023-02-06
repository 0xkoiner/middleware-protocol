// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IInterestRateModel {
    function calculateRates(
        uint256 _totalDeposits,
        uint256 _totalBorrows,
        uint256 _reserveFactorBps
    ) external view returns (uint256 liquidityRate, uint256 borrowRate);

    function getUtilizationRate(
        uint256 _totalDeposits,
        uint256 _totalBorrows
    ) external pure returns (uint256);
}
