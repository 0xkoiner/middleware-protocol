// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title IMiddlewareToken
/// @notice Interface for the deposit receipt token
interface IMiddlewareToken {
    /// @notice Mint mTokens to a depositor
    /// @param _to - Address to mint to
    /// @param _amount - Amount to mint
    function mint(address _to, uint256 _amount) external;

    /// @notice Burn mTokens from a withdrawer
    /// @param _from - Address to burn from
    /// @param _amount - Amount to burn
    function burn(address _from, uint256 _amount) external;

    /// @notice Get mToken balance
    /// @param _account - Address to query
    /// @return Balance of mTokens
    function balanceOf(address _account) external view returns (uint256);

    /// @notice Get the underlying asset address
    /// @return Address of the underlying ERC-20
    function underlyingAsset() external view returns (address);

    /// @notice Get the lending pool address
    /// @return Address of the pool
    function pool() external view returns (address);
}
