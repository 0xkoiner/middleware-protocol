// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ReserveData, UserReserveData} from "../type/Types.sol";
import {IInterestRateModel} from "../interface/IInterestRateModel.sol";
import {IPriceOracle} from "../interface/IPriceOracle.sol";
import "../type/Errors.sol";

/// @title LendingPoolStorage
/// @notice Centralized storage layout for the lending pool
abstract contract LendingPoolStorage {
    address public owner;
    IInterestRateModel public interestRateModel;
    IPriceOracle public priceOracle;

    mapping(address => ReserveData) internal _reserves;
    mapping(address => mapping(address => UserReserveData)) internal _userReserves;
    address[] internal _reserveAssets;

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }
}
