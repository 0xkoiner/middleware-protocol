// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ReserveData, UserReserveData} from "../type/Types.sol";
import {IInterestRateModel} from "../interface/IInterestRateModel.sol";
import {IPriceOracle} from "../interface/IPriceOracle.sol";
import "../type/Errors.sol";

/// @title LendingPoolStorage
/// @author openfort@0xkoiner
/// @notice Centralized storage layout for the lending pool
abstract contract LendingPoolStorage {
    /// @dev Protocol admin
    address public owner;
    /// @dev Interest rate model used for all reserves
    IInterestRateModel public interestRateModel;
    /// @dev Price oracle for asset valuations
    IPriceOracle public priceOracle;

    /// @dev asset => reserve state
    mapping(address => ReserveData) internal _reserves;
    /// @dev user => asset => user position
    mapping(address => mapping(address => UserReserveData)) internal _userReserves;
    /// @dev List of all registered reserve assets
    address[] internal _reserveAssets;

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }
}
