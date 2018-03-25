pragma solidity ^0.4.11;

contract ERC20Interface {
	// Returns main information
	function name() public constant returns (string);
	function symbol() public constant returns (string);
	function decimals() public constant returns (uint8);

	// Returns the total token supply
	function totalSupply() public constant returns (uint);

	// Returns the account balance of another account with address _owner
	function balanceOf(address _owner) public constant returns (uint balance);

	// Transfers _value amount of tokens to address _to with Event Transfer
	function transfer(address _to, uint _value) returns (bool success);

	// Transfers _value amount of tokens from address _from to address _to  with Event Transfer
	function transferFrom(address _from, address _to, uint _value) returns (bool success);

	// Allows _spender to withdraw from your account multiple times, up to the _value amount.
	function approve(address _spender, uint _value) returns (bool success);

	//Returns the amount which _spender is still allowed to withdraw from _owner.
	function allowance(address _owner, address _spender) constant returns (uint remaining);

	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}