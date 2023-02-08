// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @notice Reserve configuration and state
struct ReserveData {
    uint128 liquidityIndex;
    uint128 borrowIndex;
    uint128 liquidityRate;
    uint128 borrowRate;
    uint40 lastUpdateTimestamp;
    address mTokenAddress;
    uint16 reserveFactorBps;
    uint16 liquidationThresholdBps;
    uint16 liquidationBonusBps;
    uint16 ltvBps;
    bool isActive;
}

/// @notice Per-user reserve state
struct UserReserveData {
    uint256 depositShares;
    uint256 borrowShares;
}

library Constants {
    uint256 constant WAD = 1e18;
    uint256 constant RAY = 1e27;
    uint256 constant HALF_RAY = 5e26;
    uint256 constant SECONDS_PER_YEAR = 365 days;
    uint256 constant BPS = 10_000;
    uint256 constant HEALTH_FACTOR_THRESHOLD = 1e18;
}
