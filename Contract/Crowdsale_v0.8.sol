pragma solidity ^0.4.17;

import './WeduToken_v0.8.sol';

contract Crowdsale{
	// Parameter Setting
	address private owner;
	address private wallet;		// Address where funds are collected
	
	WeduToken public token;		// Linking with "WEDU" token
	
	uint private totalWedu;		// Amount of token in this contract
	uint private soldWedu;		// Amount of token solded by investor

	uint private weiRaised;		// Amount of wei raised
	uint private weiTarget;
	uint private price;
	uint private LowEther;
	uint private HighEther;

	uint private start;			// Start for crowdsale
	uint private deadline;		// Deadline for crowdsale
	
	mapping (address => bool) private whiteList;

	struct membersStruct {
		uint investedDate;
		address members;
		uint tokenWeight;
	}
	membersStruct[] public investMember;

	modifier onlyOwner() { require(msg.sender == owner); _; }
	modifier nowProceeding() { require(now >= start); require(now <= deadline); require(weiRaised <= weiTarget); _; }

	// Event
	event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint value, uint amount);

	// Amount related parameters
	function getRaisedWei() public constant returns (uint){ return weiRaised; }
	function gettotalWedu() public constant returns (uint){ return totalWedu; }
	function getsoldWedu() public constant returns (uint){ return soldWedu; }
	function getRemainToken() public constant returns (uint){ return totalWedu-soldWedu; }

	// Time related parameters
	function getStart() public constant returns (uint){ return start; }
	function getNow() public constant returns (uint){ return now; }
	function getDeadline() public constant returns (uint){ return deadline; }

	// Limit related parameters
	function getMinWei() public constant returns(uint){ return LowEther; }
	function getMaxWei() public constant returns(uint){ return HighEther; }
	function getPermission(address _user) public constant returns(bool){ return whiteList[_user]; }

	function getNumInvestor() public constant returns (uint)  { return investMember.length; }

	// Constructor
	function Crowdsale(address _wallet, WeduToken _token, uint _totalWedu, uint _weiTarget, uint _LowEther, uint _HighEther, uint _weduPerEther) public {
		require(_wallet != address(0));
		require(_token != address(0));

		wallet = _wallet;
		token = _token;
		totalWedu = _totalWedu;
		weiTarget = _weiTarget;
		LowEther = _LowEther;
		HighEther = _HighEther;
		price = (1 ether)/_weduPerEther;

		owner = msg.sender;
	}

	// Start the crowdsale
	function CrowdsaleStart(uint _duration) public onlyOwner {
		start = now;
		deadline = start + _duration * (1 days);
	}

	function () public payable nowProceeding  {
		address investor = msg.sender;
		require(investor != address(0));
		require(whiteList[investor]);
		require(msg.value >= LowEther * (1 ether));
		require(msg.value <= HighEther * (1 ether));

		uint weiAmount = msg.value;

		// The exchange rate are not specified
		uint tokenRatio = weiAmount / price;
		require(tokenRatio+soldWedu <= totalWedu);

		wallet.transfer(msg.value);
		investMember.push(membersStruct({investedDate: now, members: investor,tokenWeight:tokenRatio }));

		// Total collected Ethereum
		weiRaised += weiAmount;
		soldWedu += tokenRatio;

		emit TokenPurchase(msg.sender, msg.sender, msg.value, 1);
	}

	// Control the number of token for ICO
	function withdraForOwner(uint _amount, address _receiver) public onlyOwner {
	    require(_receiver != address(0));
		uint value = _amount;
		if (_amount > getRemainToken()){
			value = getRemainToken();
		}
		token.transfer(_receiver, value);
		totalWedu -= value;
	}
	function addIssueForOwner(uint _amount, address _receiver) public onlyOwner {
		// Already the amount of allowed token exist
		token.transferFrom(_receiver, address(this), _amount);
		totalWedu += _amount;
	}

	// WhiteList Control
	function addWhiteList(address _user) public onlyOwner {
		whiteList[_user] = true;

	}
	function delWhiteList(address _user) public onlyOwner {
		whiteList[_user] = false;
	}

	// Timing Control
	function deadlineExpanding(uint _days) public onlyOwner{
		deadline += (_days * (1 days));
	}
}