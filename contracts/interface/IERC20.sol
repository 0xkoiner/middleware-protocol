// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title IERC20
/// @notice Minimal ERC-20 interface
interface IERC20 {
    /// @notice Get total token supply
    /// @return Total supply
    function totalSupply() external view returns (uint256);

    /// @notice Get token balance of an account
    /// @param _account - Address to query
    /// @return Balance
    function balanceOf(address _account) external view returns (uint256);

    /// @notice Transfer tokens to a recipient
    /// @param _to - Recipient address
    /// @param _amount - Amount to transfer
    /// @return success True if transfer succeeded
    function transfer(address _to, uint256 _amount) external returns (bool);

    /// @notice Get spending allowance
    /// @param _owner - Token owner
    /// @param _spender - Approved spender
    /// @return Remaining allowance
    function allowance(address _owner, address _spender) external view returns (uint256);

    /// @notice Approve a spender
    /// @param _spender - Address to approve
    /// @param _amount - Amount to approve
    /// @return success True if approval succeeded
    function approve(address _spender, uint256 _amount) external returns (bool);

    /// @notice Transfer tokens from one address to another
    /// @param _from - Sender address
    /// @param _to - Recipient address
    /// @param _amount - Amount to transfer
    /// @return success True if transfer succeeded
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
}
