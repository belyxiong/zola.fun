pragma solidity ^0.4.18;


contract ERC20Basic {
  uint256 public totalSupply;
  uint256 public soldToken;
  string public name;
  string public symbol;


  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event BuyZSTToken(address indexed buyer, uint256 paidETH, uint256 tokenBought);
  event SendZGTBonusToken(address indexed buyer, uint256 paidETH, uint256 zstBought, uint256 zgtSent);
}

contract owned {
    address public owner;

    function owned() public {
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


contract ZSTSaleImpl1029 is owned {
    address ZSTEntryContract = 0x0;
    using SafeMath for uint256;
    ERC20 ZSTToken ;
	ERC20 ZGTToken ;
    uint start =1515477600; //Jan09
    uint endDate =1546322399; //Dec31
	uint256 public risedUSD = 0;
	uint256 public soldToken = 0;
	uint256 public zgtBonusSent = 0;
	bool saleAlive = true;
	uint256 public ZSTExchangeRate = 10000;
	uint256 public ZSTBonusRate = 35;
	uint256 public minimumBuy=100000000000000;//minimum buy uint (by default 0.001ETH)
    uint256 public zstTokenToBuy;
	bool replaced = false;
	address[] admins;

	address public ZSTUsed;
	address public ZGTUsed;
	
    constructor() public{
        owner = msg.sender;
        setZSTToken(0x0839bD51140D7a55A05A4676EeB255b1ABC85F6a);
		setZGTToken(0xb630EBC7647cB239E5b877c4DC0B218346260D60);
    }

	function setZSTToken(address zstTokenAddress) public onlyOwner{    
        ZSTToken = ERC20(zstTokenAddress);
		ZSTUsed = zstTokenAddress;
    }
	
	function setZGTToken(address zgtTokenAddress) public onlyOwner{    
        ZGTToken = ERC20(zgtTokenAddress);
		ZGTUsed = zgtTokenAddress;
    }
	
	function getSoldTokenAmount() public view returns(uint256) {
		return soldToken;
	}
	
	function getBonusZGTTokenSent() public view returns(uint256) {
		return zgtBonusSent;
	}

	function setZSTEntryContract(address zstEntryAddress) public onlyOwner{
		ZSTEntryContract = zstEntryAddress;
	}

 
	//accept from ZST Entry,
    function buyZST(address buyer, uint256 ethValue) public returns (bool){
		require(msg.sender != 0x0);
		require(msg.sender == ZSTEntryContract);
        require(now > start && now < endDate && saleAlive);
		require(ethValue >= minimumBuy);

		bool result = false;

        zstTokenToBuy= ethValue.mul(ZSTExchangeRate);
		//with zst bonus
		zstTokenToBuy = zstTokenToBuy + zstTokenToBuy.mul(ZSTBonusRate).div(100);
        if(ZSTToken.balanceOf(this)  >= zstTokenToBuy) {
			if(ZSTToken.approve(buyer, zstTokenToBuy)){
				risedUSD += ethValue;
				soldToken += zstTokenToBuy;
				if (ZSTToken.transfer(buyer, zstTokenToBuy)) {
					BuyZSTToken(buyer, ethValue, zstTokenToBuy);
					result = true;
				}else{
					revert();
				}
			}else{
				revert();
			}
		} else {
			saleAlive = false;
			revert();
		}
		return result;
    }
	


    function destroy() public onlyOwner {
        selfdestruct (owner);
    }
    
    function getTotalSupply() public view returns (uint256) {
        return ZSTToken.totalSupply();
    }

	function changeEndTime(uint newEnd) public onlyOwner{
		endDate = newEnd;
	}
    //1 ETH=?ZST
	function changeZSTExchangeRate(uint256 newRate) public onlyOwner{
		ZSTExchangeRate = newRate;
	}
	
	function getZSTExchangeRate() view public returns (uint256) {
		return ZSTExchangeRate;
	}
	
	// bonus rate of x% ZST of ZST
	function changeZSTBonusRate(uint256 rate) public onlyOwner{
		ZSTBonusRate = rate;
	}
	
	function getZSTBonusRate() view public returns (uint256) {
		return ZSTBonusRate;
	}


	//in wei
	function changeMinimumBuy(uint256 minimum) public onlyOwner{
		minimumBuy = minimum;
	}
	
	//1:pause, 0: no
	function changePauseState(uint pause) public onlyOwner{
		if (pause == 1) {
			saleAlive = true;
		} else if (pause == 0) {
			saleAlive = false;
		}
	}
	
	function getZSTBalance() view public returns (uint256)  {
		return ZSTToken.balanceOf(this);
	}
	
	function getZGTBalance() view public returns (uint256)  {
		return ZGTToken.balanceOf(this);
	}
	

}