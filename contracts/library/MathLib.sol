// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Constants} from "../type/Types.sol";

/// @title MathLib
/// @notice Fixed-point arithmetic for ray (1e27) and wad (1e18) math
library MathLib {
    function rayMul(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * b + Constants.HALF_RAY) / Constants.RAY;
    }

    function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * Constants.RAY + b / 2) / b;
    }

    function wadMul(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * b + 0.5e18) / 1e18;
    }

    function wadDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * 1e18 + b / 2) / b;
    }

    /// @notice Compound interest via binomial approximation
    function calculateCompoundInterest(
        uint256 _rate,
        uint256 _lastTimestamp,
        uint256 _now
    ) internal pure returns (uint256) {
        uint256 exp = _now - _lastTimestamp;
        if (exp == 0) return Constants.RAY;

        uint256 expMinusOne = exp - 1;
        uint256 expMinusTwo = exp > 2 ? exp - 2 : 0;
        uint256 rps = _rate / Constants.SECONDS_PER_YEAR;
        uint256 rpsSq = (rps * rps) / Constants.RAY;

        uint256 basePowerTwo = (rpsSq * expMinusOne) / 2;
        uint256 basePowerThree = (basePowerTwo * rps * expMinusTwo) / (Constants.RAY * 3);

        return Constants.RAY + (rps * exp) + basePowerTwo + basePowerThree;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}
