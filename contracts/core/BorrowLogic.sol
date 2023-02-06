// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {DepositLogic} from "./DepositLogic.sol";
import {ReserveData, UserReserveData, Constants} from "../type/Types.sol";
import {MathLib} from "../library/MathLib.sol";
import {ReserveLib} from "../library/ReserveLib.sol";
import {ValidationLib} from "../library/ValidationLib.sol";
import {IERC20} from "../interface/IERC20.sol";
import "../type/Errors.sol";
import "../type/Events.sol";

/// @title BorrowLogic
/// @notice Borrow and repay operations
abstract contract BorrowLogic is DepositLogic {
    using MathLib for uint256;
    using ReserveLib for ReserveData;

    mapping(address => uint256) internal _totalBorrowShares;
    mapping(address => uint256) internal _totalBorrowAmounts;

    function _borrow(address _asset, uint256 _amount) internal {
        ReserveData storage reserve = _reserves[_asset];
        uint256 available = IERC20(_asset).balanceOf(address(this));

        reserve.updateState(
            interestRateModel, _getTotalDeposits(_asset), _totalBorrowAmounts[_asset], _asset
        );
        ValidationLib.validateBorrow(reserve, _amount, available);

        uint256 borrowShares = _amount.rayDiv(reserve.getNormalizedDebt());
        _userReserves[msg.sender][_asset].borrowShares += borrowShares;
        _totalBorrowShares[_asset] += borrowShares;
        _totalBorrowAmounts[_asset] += _amount;

        IERC20(_asset).transfer(msg.sender, _amount);

        reserve.updateState(
            interestRateModel, _getTotalDeposits(_asset), _totalBorrowAmounts[_asset], _asset
        );

        emit Borrow(_asset, msg.sender, _amount);
    }

    function _repay(address _asset, uint256 _amount) internal returns (uint256) {
        ReserveData storage reserve = _reserves[_asset];
        UserReserveData storage userData = _userReserves[msg.sender][_asset];

        if (userData.borrowShares == 0) revert ZeroAmount();

        reserve.updateState(
            interestRateModel, _getTotalDeposits(_asset), _totalBorrowAmounts[_asset], _asset
        );

        uint256 normalizedDebt = reserve.getNormalizedDebt();
        uint256 userDebt = userData.borrowShares.rayMul(normalizedDebt);
        uint256 repayAmount = _amount == type(uint256).max ? userDebt : MathLib.min(_amount, userDebt);

        if (repayAmount == 0) revert ZeroAmount();

        uint256 sharesToRepay = repayAmount.rayDiv(normalizedDebt);
        userData.borrowShares -= sharesToRepay;
        _totalBorrowShares[_asset] -= sharesToRepay;

        uint256 borrowDecrease = MathLib.min(repayAmount, _totalBorrowAmounts[_asset]);
        _totalBorrowAmounts[_asset] -= borrowDecrease;

        IERC20(_asset).transferFrom(msg.sender, address(this), repayAmount);

        reserve.updateState(
            interestRateModel, _getTotalDeposits(_asset), _totalBorrowAmounts[_asset], _asset
        );

        emit Repay(_asset, msg.sender, repayAmount);
        return repayAmount;
    }

    function _getTotalBorrows(address _asset) internal view override returns (uint256) {
        return _totalBorrowAmounts[_asset];
    }
}
