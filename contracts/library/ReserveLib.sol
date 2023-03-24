// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ReserveData, Constants} from "../type/Types.sol";
import {MathLib} from "./MathLib.sol";
import {IInterestRateModel} from "../interface/IInterestRateModel.sol";
import "../type/Events.sol";

/// @title ReserveLib
/// @notice Reserve state management and interest accrual
library ReserveLib {
    using MathLib for uint256;

    function updateState(
        ReserveData storage _reserve,
        IInterestRateModel _model,
        uint256 _totalDeposits,
        uint256 _totalBorrows,
        address _asset
    ) internal {
        _updateIndexes(_reserve);
        _updateRates(_reserve, _model, _totalDeposits, _totalBorrows);

        emit InterestUpdated(
            _asset,
            _reserve.liquidityRate,
            _reserve.borrowRate,
            _reserve.liquidityIndex,
            _reserve.borrowIndex
        );
    }

    function getNormalizedIncome(ReserveData storage _reserve) internal view returns (uint256) {
        if (_reserve.lastUpdateTimestamp == uint40(block.timestamp)) {
            return _reserve.liquidityIndex;
        }
        uint256 interest = MathLib.calculateCompoundInterest(
            _reserve.liquidityRate, _reserve.lastUpdateTimestamp, block.timestamp
        );
        return uint256(_reserve.liquidityIndex).rayMul(interest);
    }

    function getNormalizedDebt(ReserveData storage _reserve) internal view returns (uint256) {
        if (_reserve.lastUpdateTimestamp == uint40(block.timestamp)) {
            return _reserve.borrowIndex;
        }
        uint256 interest = MathLib.calculateCompoundInterest(
            _reserve.borrowRate, _reserve.lastUpdateTimestamp, block.timestamp
        );
        return uint256(_reserve.borrowIndex).rayMul(interest);
    }

    function _updateIndexes(ReserveData storage _reserve) private {
        if (_reserve.lastUpdateTimestamp == uint40(block.timestamp)) return;

        uint256 borrowInterest = MathLib.calculateCompoundInterest(
            _reserve.borrowRate, _reserve.lastUpdateTimestamp, block.timestamp
        );
        _reserve.borrowIndex = uint128(uint256(_reserve.borrowIndex).rayMul(borrowInterest));

        uint256 liqInterest = MathLib.calculateCompoundInterest(
            _reserve.liquidityRate, _reserve.lastUpdateTimestamp, block.timestamp
        );
        _reserve.liquidityIndex = uint128(uint256(_reserve.liquidityIndex).rayMul(liqInterest));
        _reserve.lastUpdateTimestamp = uint40(block.timestamp);
    }

    function _updateRates(
        ReserveData storage _reserve,
        IInterestRateModel _model,
        uint256 _totalDeposits,
        uint256 _totalBorrows
    ) private {
        (uint256 liqRate, uint256 borrowRate) =
            _model.calculateRates(_totalDeposits, _totalBorrows, _reserve.reserveFactorBps);
        _reserve.liquidityRate = uint128(liqRate);
        _reserve.borrowRate = uint128(borrowRate);
    }
}
