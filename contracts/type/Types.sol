// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @notice Reserve configuration and state
struct ReserveData {
    /// @dev Normalized income for deposits (RAY)
    uint128 liquidityIndex;
    /// @dev Normalized variable debt (RAY)
    uint128 borrowIndex;
    /// @dev Current liquidity rate (RAY)
    uint128 liquidityRate;
    /// @dev Current borrow rate (RAY)
    uint128 borrowRate;
    /// @dev Timestamp of last reserve update
    uint40 lastUpdateTimestamp;
    /// @dev Address of the associated mToken
    address mTokenAddress;
    /// @dev Reserve factor in basis points
    uint16 reserveFactorBps;
    /// @dev Liquidation threshold in basis points
    uint16 liquidationThresholdBps;
    /// @dev Liquidation bonus in basis points
    uint16 liquidationBonusBps;
    /// @dev Loan-to-value ratio in basis points
    uint16 ltvBps;
    /// @dev Whether the reserve accepts deposits
    bool isActive;
}

/// @notice Per-user reserve state
struct UserReserveData {
    /// @dev Scaled deposit balance (shares)
    uint256 depositShares;
    /// @dev Scaled borrow balance (shares)
    uint256 borrowShares;
}

/// @notice Parameters for initializing a new reserve
struct ReserveConfig {
    /// @dev Address of the underlying ERC-20 asset
    address asset;
    /// @dev Reserve factor in basis points
    uint16 reserveFactorBps;
    /// @dev Liquidation threshold in basis points
    uint16 liquidationThresholdBps;
    /// @dev Liquidation bonus in basis points
    uint16 liquidationBonusBps;
    /// @dev Loan-to-value ratio in basis points
    uint16 ltvBps;
}

library Constants {
    uint256 constant WAD = 1e18;
    uint256 constant RAY = 1e27;
    uint256 constant HALF_RAY = 5e26;
    uint256 constant SECONDS_PER_YEAR = 365 days;
    uint256 constant BPS = 10_000;
    uint256 constant HEALTH_FACTOR_THRESHOLD = 1e18;
}
