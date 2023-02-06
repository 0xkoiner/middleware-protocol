// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {MathLib} from "../../contracts/library/MathLib.sol";
import {Constants} from "../../contracts/type/Types.sol";

contract TestMathLib is Test {
    using MathLib for uint256;

    function test_rayMul_identity() public pure {
        uint256 result = uint256(2e27).rayMul(Constants.RAY);
        assertEq(result, 2e27);
    }

    function test_rayDiv_identity() public pure {
        uint256 result = uint256(2e27).rayDiv(Constants.RAY);
        assertEq(result, 2e27);
    }

    function test_wadMul_basic() public pure {
        uint256 result = MathLib.wadMul(2e18, 3e18);
        assertEq(result, 6e18);
    }

    function test_wadDiv_basic() public pure {
        uint256 result = MathLib.wadDiv(6e18, 3e18);
        assertEq(result, 2e18);
    }

    function test_compound_interest_zero_time() public pure {
        uint256 result = MathLib.calculateCompoundInterest(0.05e27, 100, 100);
        assertEq(result, Constants.RAY);
    }

    function test_compound_interest_one_year() public pure {
        uint256 result = MathLib.calculateCompoundInterest(
            0.05e27, 0, 365 days
        );
        // ~5% annual rate should give slightly above RAY + 5%
        assertGt(result, Constants.RAY + 0.05e27 - 0.001e27);
        assertLt(result, Constants.RAY + 0.06e27);
    }

    function test_min() public pure {
        assertEq(MathLib.min(1, 2), 1);
        assertEq(MathLib.min(2, 1), 1);
        assertEq(MathLib.min(1, 1), 1);
    }

    function testFuzz_rayMul_commutative(uint128 a, uint128 b) public pure {
        uint256 ab = uint256(a).rayMul(uint256(b));
        uint256 ba = uint256(b).rayMul(uint256(a));
        assertEq(ab, ba);
    }
}
