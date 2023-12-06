// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IPriceOracle} from "../interface/IPriceOracle.sol";
import "../type/Errors.sol";

/// @title PriceOracle
/// @author openfort@0xkoiner
/// @notice Simple admin-settable price oracle
contract PriceOracle is IPriceOracle {
    /// @dev Protocol admin
    address public owner;
    /// @dev asset => price in WAD
    mapping(address => uint256) private _prices;

    event PriceUpdated(address indexed asset, uint256 price);

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Get the price of an asset
    /// @param _asset - Address of the asset
    /// @return Price in WAD
    function getAssetPrice(address _asset) external view returns (uint256) {
        return _prices[_asset];
    }

    /// @notice Set the price of an asset
    /// @param _asset - Address of the asset
    /// @param _price - Price in WAD
    function setAssetPrice(address _asset, uint256 _price) external onlyOwner {
        if (_asset == address(0)) revert ZeroAddress();
        if (_price == 0) revert ZeroAmount();
        _prices[_asset] = _price;
        emit PriceUpdated(_asset, _price);
    }

    /// @notice Transfer ownership to a new admin
    /// @param _newOwner - Address of the new owner
    function transferOwnership(address _newOwner) external onlyOwner {
        if (_newOwner == address(0)) revert ZeroAddress();
        owner = _newOwner;
    }
}
