// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title IPriceOracle
/// @notice Interface for the asset price oracle
interface IPriceOracle {
    /// @notice Get the price of an asset
    /// @param _asset - Address of the asset
    /// @return Price in WAD
    function getAssetPrice(address _asset) external view returns (uint256);

    /// @notice Set the price of an asset
    /// @param _asset - Address of the asset
    /// @param _price - Price in WAD
    function setAssetPrice(address _asset, uint256 _price) external;
}
