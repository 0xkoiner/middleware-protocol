// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Constants} from "../type/Types.sol";

/// @title MathLib
/// @notice Fixed-point arithmetic for ray (1e27) and wad (1e18) math
library MathLib {
    function rayMul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        assembly {
            if iszero(or(iszero(b), iszero(gt(a, div(sub(not(0), div(b, 2)), b))))) { revert(0, 0) }
            c := div(add(mul(a, b), div(b, 2)), 1000000000000000000000000000)
        }
    }

    function rayDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {
        assembly {
            if iszero(b) { revert(0, 0) }
            if iszero(iszero(gt(a, div(sub(not(0), div(b, 2)), 1000000000000000000000000000)))) {
                revert(0, 0)
            }
            c := div(add(mul(a, 1000000000000000000000000000), div(b, 2)), b)
        }
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

        uint256 expMinusOne;
        uint256 expMinusTwo;
        unchecked {
            expMinusOne = exp - 1;
            expMinusTwo = exp > 2 ? exp - 2 : 0;
        }

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
