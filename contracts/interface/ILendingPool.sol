// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ReserveData, ReserveConfig} from "../type/Types.sol";

/// @title ILendingPool
/// @notice Interface for the main lending pool entry point
interface ILendingPool {
    /// @notice Deposit assets into the pool
    /// @param _asset - Address of the asset to deposit
    /// @param _amount - Amount to deposit
    function deposit(address _asset, uint256 _amount) external;

    /// @notice Withdraw assets from the pool
    /// @param _asset - Address of the asset to withdraw
    /// @param _amount - Amount to withdraw (type(uint256).max for full)
    function withdraw(address _asset, uint256 _amount) external;

    /// @notice Borrow assets from the pool
    /// @param _asset - Address of the asset to borrow
    /// @param _amount - Amount to borrow
    function borrow(address _asset, uint256 _amount) external;

    /// @notice Repay borrowed assets
    /// @param _asset - Address of the asset to repay
    /// @param _amount - Amount to repay (type(uint256).max for full)
    function repay(address _asset, uint256 _amount) external;

    /// @notice Liquidate an undercollateralized position
    /// @param _collateralAsset - Address of the collateral to seize
    /// @param _debtAsset - Address of the debt to repay
    /// @param _user - Address of the user to liquidate
    /// @param _debtAmount - Amount of debt to cover
    function liquidate(
        address _collateralAsset,
        address _debtAsset,
        address _user,
        uint256 _debtAmount
    ) external;

    /// @notice Initialize a new reserve
    /// @param _config - Reserve configuration parameters
    function initReserve(ReserveConfig calldata _config) external;

    /// @notice Get reserve data for an asset
    /// @param _asset - Address of the reserve asset
    /// @return Reserve data struct
    function getReserveData(address _asset) external view returns (ReserveData memory);

    /// @notice Get the health factor for a user
    /// @param _user - Address of the user
    /// @return healthFactor Health factor in WAD
    function getUserHealthFactor(address _user) external view returns (uint256);

    /// @notice Get a user's deposit balance for an asset
    /// @param _user - Address of the user
    /// @param _asset - Address of the asset
    /// @return Deposit balance in underlying tokens
    function getUserDeposit(address _user, address _asset) external view returns (uint256);

    /// @notice Get a user's borrow balance for an asset
    /// @param _user - Address of the user
    /// @param _asset - Address of the asset
    /// @return Borrow balance in underlying tokens
    function getUserBorrow(address _user, address _asset) external view returns (uint256);

    /// @notice Get all registered reserve asset addresses
    /// @return Array of reserve asset addresses
    function getReserveAssets() external view returns (address[] memory);
}
