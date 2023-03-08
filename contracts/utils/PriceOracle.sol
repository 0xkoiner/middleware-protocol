// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IPriceOracle} from "../interface/IPriceOracle.sol";
import "../type/Errors.sol";

/// @title PriceOracle
/// @notice Simple admin-settable price oracle
contract PriceOracle is IPriceOracle {
    address public owner;
    mapping(address => uint256) private _prices;

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function getAssetPrice(address _asset) external view returns (uint256) {
        return _prices[_asset];
    }

    function setAssetPrice(address _asset, uint256 _price) external onlyOwner {
        if (_asset == address(0)) revert ZeroAddress();
        if (_price == 0) revert ZeroAmount();
        _prices[_asset] = _price;
    }
}
