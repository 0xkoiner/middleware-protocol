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

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}
