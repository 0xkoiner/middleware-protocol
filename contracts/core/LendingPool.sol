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
/// @author openfort@0xkoiner
/// @notice Main entry point for the Middleware lending protocol
contract LendingPool is ILendingPool, LiquidationLogic {
    using MathLib for uint256;
    using ReserveLib for ReserveData;

    /// @param _interestRateModel - Address of the interest rate model
    /// @param _priceOracle - Address of the price oracle
    constructor(address _interestRateModel, address _priceOracle) {
        if (_interestRateModel == address(0)) revert ZeroAddress();
        if (_priceOracle == address(0)) revert ZeroAddress();

        owner = msg.sender;
        interestRateModel = IInterestRateModel(_interestRateModel);
        priceOracle = IPriceOracle(_priceOracle);
    }

    /// @notice Deposit assets into the pool
    /// @param _asset - Address of the asset to deposit
    /// @param _amount - Amount to deposit
    function deposit(address _asset, uint256 _amount) external {
        _deposit(_asset, _amount);
    }

    /// @notice Withdraw assets from the pool
    /// @param _asset - Address of the asset to withdraw
    /// @param _amount - Amount to withdraw (type(uint256).max for full)
    function withdraw(address _asset, uint256 _amount) external {
        _withdraw(_asset, _amount);
        _validateHealthAfterAction(msg.sender);
    }

    /// @notice Borrow assets from the pool
    /// @param _asset - Address of the asset to borrow
    /// @param _amount - Amount to borrow
    function borrow(address _asset, uint256 _amount) external {
        _borrow(_asset, _amount);
        uint256 hf = _calculateHealthFactor(msg.sender);
        if (hf < Constants.HEALTH_FACTOR_THRESHOLD) revert BorrowExceedsLTV();
    }

    /// @notice Repay borrowed assets
    /// @param _asset - Address of the asset to repay
    /// @param _amount - Amount to repay (type(uint256).max for full)
    function repay(address _asset, uint256 _amount) external {
        _repay(_asset, _amount);
    }

    /// @notice Liquidate an undercollateralized position
    /// @param _collateralAsset - Address of the collateral to seize
    /// @param _debtAsset - Address of the debt to repay
    /// @param _user - Address of the user to liquidate
    /// @param _debtAmount - Amount of debt to cover
    function liquidate(
        address _collateralAsset,
        address _debtAsset,
        address _user,
        uint256 _debtAmount
    ) external {
        _liquidate(_collateralAsset, _debtAsset, _user, _debtAmount);
    }

    /// @notice Initialize a new reserve
    /// @param _config - Reserve configuration parameters
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

    /// @notice Get reserve data for an asset
    /// @param _asset - Address of the reserve asset
    /// @return Reserve data struct
    function getReserveData(address _asset) external view returns (ReserveData memory) {
        return _reserves[_asset];
    }

    /// @notice Get the health factor for a user
    /// @param _user - Address of the user
    /// @return Health factor in WAD
    function getUserHealthFactor(address _user) external view returns (uint256) {
        return _calculateHealthFactor(_user);
    }

    /// @notice Get all registered reserve asset addresses
    /// @return Array of reserve asset addresses
    function getReserveAssets() external view returns (address[] memory) {
        return _reserveAssets;
    }

    /// @notice Get a user's deposit balance for an asset
    /// @param _user - Address of the user
    /// @param _asset - Address of the asset
    /// @return Deposit balance in underlying tokens
    function getUserDeposit(address _user, address _asset) external view returns (uint256) {
        UserReserveData storage userData = _userReserves[_user][_asset];
        if (userData.depositShares == 0) return 0;
        return userData.depositShares.rayMul(_reserves[_asset].getNormalizedIncome());
    }

    /// @notice Get a user's borrow balance for an asset
    /// @param _user - Address of the user
    /// @param _asset - Address of the asset
    /// @return Borrow balance in underlying tokens
    function getUserBorrow(address _user, address _asset) external view returns (uint256) {
        UserReserveData storage userData = _userReserves[_user][_asset];
        if (userData.borrowShares == 0) return 0;
        return userData.borrowShares.rayMul(_reserves[_asset].getNormalizedDebt());
    }

    // ---- Internal ----

    /// @dev Revert if health factor drops below threshold after an action
    function _validateHealthAfterAction(address _user) private view {
        uint256 hf = _calculateHealthFactor(_user);
        if (hf != type(uint256).max && hf < Constants.HEALTH_FACTOR_THRESHOLD) {
            revert InsufficientCollateral();
        }
    }
}
