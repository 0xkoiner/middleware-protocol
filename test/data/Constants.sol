// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library TestConstants {
    uint256 constant INITIAL_DEPOSIT = 1000e18;
    uint256 constant BORROW_AMOUNT = 500e18;
    uint256 constant SMALL_AMOUNT = 100e18;
    uint256 constant TOKEN_A_PRICE = 1e18;
    uint256 constant TOKEN_B_PRICE = 2000e18;

    // Interest rate model params (RAY)
    uint256 constant OPTIMAL_UTILIZATION = 0.8e27;
    uint256 constant BASE_RATE = 0.02e27;
    uint256 constant SLOPE1 = 0.04e27;
    uint256 constant SLOPE2 = 0.75e27;

    // Reserve config (BPS)
    uint16 constant RESERVE_FACTOR = 1000;
    uint16 constant LIQ_THRESHOLD = 8000;
    uint16 constant LIQ_BONUS = 500;
    uint16 constant LTV = 7500;
}
