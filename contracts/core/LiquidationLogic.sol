// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BorrowLogic} from "./BorrowLogic.sol";
import {ReserveData, UserReserveData, Constants} from "../type/Types.sol";
import {MathLib} from "../library/MathLib.sol";
import {ReserveLib} from "../library/ReserveLib.sol";
import {ValidationLib} from "../library/ValidationLib.sol";
import {IMiddlewareToken} from "../interface/IMiddlewareToken.sol";
import {IERC20} from "../interface/IERC20.sol";
import "../type/Errors.sol";
import "../type/Events.sol";

/// @title LiquidationLogic
/// @notice Liquidation of undercollateralized positions
abstract contract LiquidationLogic is BorrowLogic {
    using MathLib for uint256;
    using ReserveLib for ReserveData;

    uint256 internal constant CLOSE_FACTOR_BPS = 5000;

    function _liquidate(
        address _collateralAsset,
        address _debtAsset,
        address _user,
        uint256 _debtToCover
    ) internal {
        if (_user == msg.sender) revert SelfLiquidation();
        if (_debtToCover == 0) revert ZeroAmount();

        ReserveData storage collateralReserve = _reserves[_collateralAsset];
        ReserveData storage debtReserve = _reserves[_debtAsset];

        uint256 healthFactor = _calculateHealthFactor(_user);
        ValidationLib.validateLiquidation(collateralReserve, debtReserve, healthFactor);

        collateralReserve.updateState(
            interestRateModel,
            _getTotalDeposits(_collateralAsset),
            _totalBorrowAmounts[_collateralAsset],
            _collateralAsset
        );
        debtReserve.updateState(
            interestRateModel,
            _getTotalDeposits(_debtAsset),
            _totalBorrowAmounts[_debtAsset],
            _debtAsset
        );

        // Calculate max liquidatable debt (close factor)
        UserReserveData storage debtUserData = _userReserves[_user][_debtAsset];
        uint256 userDebt = debtUserData.borrowShares.rayMul(debtReserve.getNormalizedDebt());
        uint256 maxDebt = userDebt * CLOSE_FACTOR_BPS / Constants.BPS;
        uint256 actualDebt = MathLib.min(_debtToCover, maxDebt);

        // Calculate collateral to seize (with bonus)
        uint256 collateralPrice = priceOracle.getAssetPrice(_collateralAsset);
        uint256 debtPrice = priceOracle.getAssetPrice(_debtAsset);
        uint256 collateralAmount = (actualDebt * debtPrice) / collateralPrice;
        uint256 bonus = collateralAmount * collateralReserve.liquidationBonusBps / Constants.BPS;
        uint256 totalSeize = collateralAmount + bonus;

        // Reduce debt
        uint256 debtShares = actualDebt.rayDiv(debtReserve.getNormalizedDebt());
        debtUserData.borrowShares -= debtShares;
        _totalBorrowShares[_debtAsset] -= debtShares;
        _totalBorrowAmounts[_debtAsset] -= MathLib.min(actualDebt, _totalBorrowAmounts[_debtAsset]);

        // Seize collateral
        UserReserveData storage collateralUserData = _userReserves[_user][_collateralAsset];
        uint256 collateralShares = totalSeize.rayDiv(collateralReserve.getNormalizedIncome());
        collateralUserData.depositShares -= collateralShares;
        IMiddlewareToken(collateralReserve.mTokenAddress).burn(_user, collateralShares);

        // Transfer
        IERC20(_debtAsset).transferFrom(msg.sender, address(this), actualDebt);
        IERC20(_collateralAsset).transfer(msg.sender, totalSeize);

        emit Liquidation(_collateralAsset, _debtAsset, _user, actualDebt, totalSeize);
    }

    function _calculateHealthFactor(address _user) internal view returns (uint256) {
        uint256 totalCollateralValue;
        uint256 totalBorrowValue;

        for (uint256 i; i < _reserveAssets.length;) {
            address asset = _reserveAssets[i];
            ReserveData storage reserve = _reserves[asset];
            UserReserveData storage userData = _userReserves[_user][asset];
            uint256 price = priceOracle.getAssetPrice(asset);

            if (userData.depositShares > 0) {
                uint256 val = userData.depositShares.rayMul(reserve.getNormalizedIncome()) * price
                    / Constants.WAD;
                totalCollateralValue += val * reserve.liquidationThresholdBps / Constants.BPS;
            }

            if (userData.borrowShares > 0) {
                totalBorrowValue +=
                    userData.borrowShares.rayMul(reserve.getNormalizedDebt()) * price / Constants.WAD;
            }

            unchecked { ++i; }
        }

        if (totalBorrowValue == 0) return type(uint256).max;
        return totalCollateralValue.wadDiv(totalBorrowValue);
    }
}
