// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

event Deposit(address indexed asset, address indexed user, uint256 amount);
event Withdraw(address indexed asset, address indexed user, uint256 amount);
event Borrow(address indexed asset, address indexed user, uint256 amount);
event Repay(address indexed asset, address indexed user, uint256 amount);
event Liquidation(
    address indexed collateralAsset,
    address indexed debtAsset,
    address indexed user,
    uint256 debtCovered,
    uint256 collateralSeized
);
event ReserveInitialized(address indexed asset, address indexed mToken);
event InterestUpdated(
    address indexed asset,
    uint256 liquidityRate,
    uint256 borrowRate,
    uint256 liquidityIndex,
    uint256 borrowIndex
);
