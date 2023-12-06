// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IMiddlewareToken} from "../interface/IMiddlewareToken.sol";
import "../type/Errors.sol";

/// @title MiddlewareToken
/// @author openfort@0xkoiner
/// @notice Receipt token representing deposits in the lending pool
contract MiddlewareToken is IMiddlewareToken {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    /// @dev Address of the lending pool
    address public immutable pool;
    /// @dev Address of the underlying ERC-20 asset
    address public immutable underlyingAsset;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    modifier onlyPool() {
        if (msg.sender != pool) revert NotOwner();
        _;
    }

    /// @param _pool - Address of the lending pool
    /// @param _underlying - Address of the underlying asset
    /// @param _name - Token name
    /// @param _symbol - Token symbol
    constructor(
        address _pool,
        address _underlying,
        string memory _name,
        string memory _symbol
    ) {
        pool = _pool;
        underlyingAsset = _underlying;
        name = _name;
        symbol = _symbol;
    }

    /// @notice Mint mTokens to a depositor
    /// @param _to - Address to mint to
    /// @param _amount - Amount to mint
    function mint(address _to, uint256 _amount) external onlyPool {
        totalSupply += _amount;
        balanceOf[_to] += _amount;
        emit Transfer(address(0), _to, _amount);
    }

    /// @notice Burn mTokens on withdrawal
    /// @param _from - Address to burn from
    /// @param _amount - Amount to burn
    function burn(address _from, uint256 _amount) external onlyPool {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
        emit Transfer(_from, address(0), _amount);
    }

    /// @notice Transfer mTokens
    /// @param _to - Recipient address
    /// @param _amount - Amount to transfer
    /// @return success True
    function transfer(address _to, uint256 _amount) external returns (bool) {
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    /// @notice Approve a spender
    /// @param _spender - Address to approve
    /// @param _amount - Amount to approve
    /// @return success True
    function approve(address _spender, uint256 _amount) external returns (bool) {
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    /// @notice Transfer mTokens via allowance
    /// @param _from - Sender address
    /// @param _to - Recipient address
    /// @param _amount - Amount to transfer
    /// @return success True
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool) {
        if (allowance[_from][msg.sender] != type(uint256).max) {
            allowance[_from][msg.sender] -= _amount;
        }
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }
}
