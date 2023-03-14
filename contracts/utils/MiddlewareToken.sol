// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IMiddlewareToken} from "../interface/IMiddlewareToken.sol";
import "../type/Errors.sol";

/// @title MiddlewareToken
/// @notice Receipt token representing deposits in the lending pool
contract MiddlewareToken is IMiddlewareToken {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    address public immutable pool;
    address public immutable underlyingAsset;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    modifier onlyPool() {
        if (msg.sender != pool) revert NotOwner();
        _;
    }

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

    function mint(address _to, uint256 _amount) external onlyPool {
        totalSupply += _amount;
        balanceOf[_to] += _amount;
    }

    function burn(address _from, uint256 _amount) external onlyPool {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function transfer(address _to, uint256 _amount) external returns (bool) {
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        return true;
    }

    function approve(address _spender, uint256 _amount) external returns (bool) {
        allowance[msg.sender][_spender] = _amount;
        return true;
    }

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
        return true;
    }
}
