// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @param asset Address of the deposited asset
/// @param user Address of the depositor
/// @param amount Amount deposited
event Deposit(address indexed asset, address indexed user, uint256 amount);

/// @param asset Address of the withdrawn asset
/// @param user Address of the withdrawer
/// @param amount Amount withdrawn
event Withdraw(address indexed asset, address indexed user, uint256 amount);

/// @param asset Address of the borrowed asset
/// @param user Address of the borrower
/// @param amount Amount borrowed
event Borrow(address indexed asset, address indexed user, uint256 amount);

/// @param asset Address of the repaid asset
/// @param user Address of the repayer
/// @param amount Amount repaid
event Repay(address indexed asset, address indexed user, uint256 amount);

/// @param collateralAsset Address of the seized collateral
/// @param debtAsset Address of the repaid debt asset
/// @param user Address of the liquidated user
/// @param debtCovered Amount of debt covered
/// @param collateralSeized Amount of collateral seized
event Liquidation(
    address indexed collateralAsset,
    address indexed debtAsset,
    address indexed user,
    uint256 debtCovered,
    uint256 collateralSeized
);

/// @param asset Address of the reserve asset
/// @param mToken Address of the mToken contract
event ReserveInitialized(address indexed asset, address indexed mToken);

/// @param asset Address of the reserve asset
/// @param liquidityRate Updated liquidity rate
/// @param borrowRate Updated borrow rate
/// @param liquidityIndex Updated liquidity index
/// @param borrowIndex Updated borrow index
event InterestUpdated(
    address indexed asset,
    uint256 liquidityRate,
    uint256 borrowRate,
    uint256 liquidityIndex,
    uint256 borrowIndex
);
