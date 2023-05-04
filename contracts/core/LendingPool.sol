// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LiquidationLogic} from "./LiquidationLogic.sol";
import {ILendingPool} from "../interface/ILendingPool.sol";
import {IInterestRateModel} from "../interface/IInterestRateModel.sol";
import {IPriceOracle} from "../interface/IPriceOracle.sol";
import {ReserveData, UserReserveData, ReserveConfig, Constants} from "../type/Types.sol";
import {ValidationLib} from "../library/ValidationLib.sol";
import {ReserveLib} from "../library/ReserveLib.sol";
import {MathLib} from "../library/MathLib.sol";
import {MiddlewareToken} from "../utils/MiddlewareToken.sol";
import {IERC20} from "../interface/IERC20.sol";
import "../type/Errors.sol";
import "../type/Events.sol";

/// @title LendingPool
/// @notice Main entry point for the Middleware lending protocol
contract LendingPool is ILendingPool, LiquidationLogic {
    using MathLib for uint256;
    using ReserveLib for ReserveData;

    constructor(address _interestRateModel, address _priceOracle) {
        if (_interestRateModel == address(0)) revert ZeroAddress();
        if (_priceOracle == address(0)) revert ZeroAddress();

        owner = msg.sender;
        interestRateModel = IInterestRateModel(_interestRateModel);
        priceOracle = IPriceOracle(_priceOracle);
    }

    function deposit(address _asset, uint256 _amount) external {
        _deposit(_asset, _amount);
    }

    function withdraw(address _asset, uint256 _amount) external {
        _withdraw(_asset, _amount);
        _validateHealthAfterAction(msg.sender);
    }

    function borrow(address _asset, uint256 _amount) external {
        _borrow(_asset, _amount);
        uint256 hf = _calculateHealthFactor(msg.sender);
        if (hf < Constants.HEALTH_FACTOR_THRESHOLD) revert BorrowExceedsLTV();
    }

    function repay(address _asset, uint256 _amount) external {
        _repay(_asset, _amount);
    }

    function liquidate(
        address _collateralAsset,
        address _debtAsset,
        address _user,
        uint256 _debtAmount
    ) external {
        _liquidate(_collateralAsset, _debtAsset, _user, _debtAmount);
    }

    function initReserve(ReserveConfig calldata _config) external onlyOwner {
        ValidationLib.validateInitReserve(
            _reserves[_config.asset],
            _config.asset,
            _config.ltvBps,
            _config.liquidationThresholdBps
        );

        MiddlewareToken mToken = new MiddlewareToken(
            address(this),
            _config.asset,
            string.concat("Middleware ", "Token"),
            string.concat("m", "TOKEN")
        );

        _reserves[_config.asset] = ReserveData({
            liquidityIndex: uint128(Constants.RAY),
            borrowIndex: uint128(Constants.RAY),
            liquidityRate: 0,
            borrowRate: 0,
            lastUpdateTimestamp: uint40(block.timestamp),
            mTokenAddress: address(mToken),
            reserveFactorBps: _config.reserveFactorBps,
            liquidationThresholdBps: _config.liquidationThresholdBps,
            liquidationBonusBps: _config.liquidationBonusBps,
            ltvBps: _config.ltvBps,
            isActive: true
        });

        _reserveAssets.push(_config.asset);
        emit ReserveInitialized(_config.asset, address(mToken));
    }

    // ---- View functions ----

    function getReserveData(address _asset) external view returns (ReserveData memory) {
        return _reserves[_asset];
    }

    function getUserHealthFactor(address _user) external view returns (uint256) {
        return _calculateHealthFactor(_user);
    }

    function getReserveAssets() external view returns (address[] memory) {
        return _reserveAssets;
    }

    function getUserDeposit(address _user, address _asset) external view returns (uint256) {
        UserReserveData storage userData = _userReserves[_user][_asset];
        if (userData.depositShares == 0) return 0;
        return userData.depositShares.rayMul(_reserves[_asset].getNormalizedIncome());
    }

    function getUserBorrow(address _user, address _asset) external view returns (uint256) {
        UserReserveData storage userData = _userReserves[_user][_asset];
        if (userData.borrowShares == 0) return 0;
        return userData.borrowShares.rayMul(_reserves[_asset].getNormalizedDebt());
    }

    // ---- Internal ----

    function _validateHealthAfterAction(address _user) private view {
        uint256 hf = _calculateHealthFactor(_user);
        if (hf != type(uint256).max && hf < Constants.HEALTH_FACTOR_THRESHOLD) {
            revert InsufficientCollateral();
        }
    }
}
