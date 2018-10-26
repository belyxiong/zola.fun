pragma solidity ^0.4.18;

contract ERC20Basic {
  uint256 public totalSupply;
  string public name;
  string public symbol;


  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event PlayGame(address player,  string str1, string str2, uint256 data1, uint256 data2);
  event TransferAndCall(address player, address spender, uint256 tokentransfered, string str1, string str2, uint256 data1, uint256 data2);
  event TransferAndCall2(address player, address spender, uint256 tokentransfered, string[] str1, string str2, uint256[] data1, uint256 data2);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

interface tokenReceiver { function executeOnTokenTransfered(address player, uint256 token2Transfer, string str1, string str2, uint256 data1, uint256 data2) external returns (bool); }

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
  

    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}
contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}


contract ZOLAGameTokenOf1001 is StandardToken, owned {
    
    string public constant name = "ZOLA Game Token";
    
    string public constant symbol = "ZGT";
    
    uint32 public constant decimals = 18;
	
	string public version = "15";
    
	
    constructor(uint256 initialSupply) public{
		totalSupply = initialSupply * 10 ** uint256(decimals);
		balances[msg.sender] = totalSupply;
    }
    
	function destroy() public onlyOwner {
        selfdestruct (owner);
    }
	
	
	//general api to run different request
	//spender : the contract to call after token transfered
    function transferAndCall(address _spender, uint256 token2Transfer, string str1, string str2, uint256 data1, uint256 data2) public {
		require (_spender != 0x0);

		uint256 tokens2Trans = token2Transfer * 10 ** uint256(decimals);
		require(balances[msg.sender] >= tokens2Trans);
        tokenReceiver spender = tokenReceiver(_spender);
        if (approve(_spender, tokens2Trans)) {
			if (transfer(_spender, tokens2Trans)) {
				if (spender.executeOnTokenTransfered(msg.sender, tokens2Trans, str1, str2, data1, data2)) {
					emit TransferAndCall(msg.sender,_spender, tokens2Trans, str1, str2, data1, data2);
					return;
				}
			}
        }
		revert();
    }
	

}

