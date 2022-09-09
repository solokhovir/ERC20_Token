// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import './ERC20.sol';

contract Weth is ERC20 {
    constructor() ERC20("WrappedEther", "WETH", 0) {}

    event Deposit(address indexed initiator, uint amount);
    event Withdraw(address indexed initiator, uint amount);

    function deposit() public payable {
        mint(msg.value, msg.sender);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint _amount) public {
        burn(msg.sender, _amount);
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Failed!");
        emit Withdraw(msg.sender, _amount);
    }
}