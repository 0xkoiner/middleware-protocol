// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ReserveData, ReserveConfig} from "../type/Types.sol";

interface ILendingPool {
    function deposit(address _asset, uint256 _amount) external;
    function withdraw(address _asset, uint256 _amount) external;
    function borrow(address _asset, uint256 _amount) external;
    function repay(address _asset, uint256 _amount) external;
    function liquidate(
        address _collateralAsset,
        address _debtAsset,
        address _user,
        uint256 _debtAmount
    ) external;
    function initReserve(ReserveConfig calldata _config) external;
    function getReserveData(address _asset) external view returns (ReserveData memory);
    function getUserHealthFactor(address _user) external view returns (uint256);
}
