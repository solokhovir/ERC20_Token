// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import './ERC20.sol';

contract Vault {
    IERC20 public immutable token;

    mapping(address => uint) public balanceOf;
    uint public totalSupply;
    
    constructor(address _token) {
        token = IERC20(_token);
    }

    function deposit(uint _amount) external {
        uint shares;
        if (totalSupply == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply) / token.balanceOf(address(this));
        }
        mint(msg.sender, shares);
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint _shares) external {
        uint _amount = (_shares * token.balanceOf(address(this))) / totalSupply;
        burn(msg.sender, _shares);
        token.transfer(msg.sender, _amount);
    }

    function mint(address _to, uint _shares) private {
        totalSupply += _shares;
        balanceOf[_to] += _shares;
    }

    function burn(address _from, uint _shares) private {
        totalSupply -= _shares;
        balanceOf[_from] -= _shares;
    }
}