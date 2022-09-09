// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import './IERC20.sol';

contract ERC20 is IERC20 {
    uint totalTokens;
    address owner;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;
    string _name;
    string _symbol;

    function name() external view returns(string memory) {
        return _name;
    }

    function symbol() external view returns(string memory) {
        return _symbol;
    }

    constructor(string memory name_, string memory symbol_, uint initialSupply) {
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;
        mint(initialSupply, owner);
    }

    modifier enoughTokens(address _from, uint _amount) {
        require(balanceOf(_from) >= _amount, "Not enough tokens!");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner!");
        _;
    }

    function decimals() override public pure returns(uint) {
        return 0;
    }

    function totalSupply() override public view returns(uint) {
        return totalTokens;
    }

    function balanceOf(address account) override public view returns(uint) {
        return balances[account];
    }

    function transfer(address to, uint amount) override external enoughTokens(msg.sender, amount) {
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function allowance(address _owner, address spender) override external view returns(uint) {
        return allowances[_owner][spender];
    }

    function approve(address spender, uint amount) override external onlyOwner {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint amount) override public enoughTokens(sender, amount) {
        allowances[sender][recipient] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function mint(uint amount, address to) public onlyOwner {
        balances[to] += amount;
        totalTokens += amount;
        emit Transfer(address(0), to, amount);
    }

    function burn(address _from, uint amount) public enoughTokens(msg.sender, amount) {
        balances[_from] -= amount;
        totalTokens -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    fallback() external payable {

    }

    receive() external payable {

    }
}

contract TokenSell {
    IERC20 public token;
    address owner;
    address public thisAddr = address(this);

    event Bought(address indexed buyer, uint amount);
    event Sell(address indexed seller, uint amount);

    constructor(IERC20 _token) {
        token = _token;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner!");
        _;
    }

    function balance() public view returns(uint) {
        return thisAddr.balance;
    }

    function buy() public payable {
        require(msg.value >= _rate(), "Incorrect sum!");
        uint tokensAvailable = token.balanceOf(thisAddr);
        uint tokensToBuy = msg.value / _rate();
        require(tokensToBuy <= tokensAvailable, "Not enough tokens!");
        token.transfer(msg.sender, tokensToBuy);
        emit Bought(msg.sender, tokensToBuy);
    }

    function sell(uint amount) public {
        require(amount > 0, "Tokens must be greater than 0");
        uint allowance = token.allowance(msg.sender, thisAddr);
        require(allowance >= amount, "Wrong allowance");
        token.transferFrom(msg.sender, thisAddr, amount);
        payable(msg.sender).transfer(amount * _rate());
        emit Sell(msg.sender, amount);
    } 

    function withdraw(uint amount) public onlyOwner {
        require(amount <=  balance(), "Not enough funds");
        payable(msg.sender).transfer(amount);
    }

    function _rate() private pure returns(uint) {
        return 1 ether;
    }
}