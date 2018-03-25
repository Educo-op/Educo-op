pragma solidity ^0.4.11;

import '../Interface/ERC20Interface.sol';

contract WeduToken is ERC20Interface{
	// Variables
	address owner;
	string private constant nameValue;
	string private constant symbolValue;
	uint8 private constant decimalValue;
	uint private totalSupplyValue;

	mapping(address => uint) public balanceValue;
	mapping(address => mapping (address => uint)) internal allowed;
  	mapping(address => bool) public blackList;

  	// Modifier
	modifier onlyOwner() { require(owner == msg.sender); _;}

	// Event
	event ChangeNumberofToken(uint oldValue, uint newValue);
	
	// Constructor
	function testToken(string _nameValue, string _symbolValue, uint8 _decimalValue, uint _totalSupplyValue) public {
		nameValue = _nameValue;
		symbolValue = _symbolValue;
		decimalValue = _decimalValue
		totalSupplyValue = _totalSupplyValue;

		owner = msg.sender;
		balanceValue[owner] = totalSupplyValue;
	}

	// Interface implementation
	function name() public constant returns (string){ return nameValue; }
	function symbol() public constant returns (string){ return symbolValue; }
	function decimals() public constant returns (uint8){ return decimalValue; }
	function totalSupply() public constant returns (uint){ return totalSupplyValue; }
	function balanceOf(address _user) public constant returns (uint ){ return balanceValue[_user]; }

    // Token Transfer
	function transfer(address _to, uint _value) public returns (bool success){
    	// Address validation
    	require(_to != address(0));

		// Blacklist validation
    	require(!blackList[msg.sender]);
    	require(!blackList[_to]);

		// Account balance validation
    	require(_value <= balanceValue[msg.sender]);

    	balanceValue[msg.sender] -= _value;
    	balanceValue[_to] += _value;
    	Transfer(msg.sender, _to, _value);
    	return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success){
    	// Address validation
		require(_to != address(0));
		require(_from != address(0));

		// Blacklist validation
		require(!blackList[msg.sender]);
		require(!blackList[_to]);

    	// Account balance validation
		require(_value <= balanceValue[_from]);
		require(_value <= allowed[_from][msg.sender]);

		balanceValue[_from] -= _value;
		balanceValue[_to] += _value;
		allowed[_from][msg.sender] -= _value;
		Transfer(_from, _to, _value);

		return true;
    }

	function approve(address _spender, uint _value) public returns (bool success){
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
	}

	function allowance(address _owner, address _spender) public constant returns (uint remaining){
		return allowed[_owner][_spender];
	}

	// Number of approval token management
	function increaseApproval(address _spender, uint _addedValue) public returns (bool){
		allowed[msg.sender][_spender] += _addedValue;
		Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}

	function decreaseApproval(address _spender, uint _substractedValue) public returns (bool){
		uint oldValue = allowed[msg.sender][_spender];
		if (_substractedValue > oldValue){
			allowed[msg.sender][_spender] = 0;
		} else {
			allowed[msg.sender][_spender] = oldValue - _substractedValue;
		}
		Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}


    // Black list management
    function addBlackList(address _who) public onlyOwner{
    	require(!blackList[_who]);

    	blackList[_who] = true;
    }
    function removalBlackList(address _who) public onlyOwner{
    	require(blackList[_who]);

    	blackList[_who] = false;
    }

    // Token amount management
    function tokenIssue(uint _value) public onlyOwner{
    	require(_value > 0);

    	uint oldTokenNum = totalSupplyValue;
    	totalSupplyValue += _value;
    	balanceValue[owner] += _value;

    	ChangeNumberofToken(oldTokenNum, totalSupplyValue);
    }
    function tokenBurn(address _who, uint _value) public onlyOwner{
    	require(_who != address(0));
    	require(_value > 0);
    	require(balanceValue[_who] >= _value);

		uint oldTokenNum = totalSupplyValue;
    	totalSupplyValue -= _value;
    	balanceValue[_who] -= _value;
    	ChangeNumberofToken(oldTokenNum, totalSupplyValue);
    }
}
