pragma solidity ^0.4.18;


contract ERC20Basic {
  uint256 public totalSupply;
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

interface ZolaXEntry {
function addWinnerInfo(address player, uint256 amount) external;
function addProfit(uint256 amount) external;
function addDonation(uint256 amount)  external;
function getDepositBalance(address player) external returns (uint256);
function decreaseDeposit(address player, uint256 amount) external;
function distributeProfitOnDraw() external;
function decreaseWonZGTBalance(address player, uint256 amount) external;
function decreaseDividendZGTBalance(address player, uint256 amount) external;
function getDividendBalance(address player) public returns (uint256);
function getWinBalance(address player) view public returns (uint256);
}

contract LastWinnerGame0930 is owned {
	using SafeMath for uint256;
	
	uint256 public INTERVAL = 30*60;//24*60*60;//interval 24 hours, after that the last player will win
	uint256 public TIME_INC_ON_BET = 60;//seconds increased on bet
	bool public GAME_IS_RUNNING = false;//switch to turn on/off
	
	uint256 public TimeToDraw;
	
	uint256 public totalInPool;
	
	ZolaXEntry ZolaXImpl;
	address ZolaXAddress;
	
	ERC20 ZGTToken ;
	
	uint256 DECIMAL = 1000000000000000000;
	uint256 MAX2BET = 1000;//1000zgt
	
	struct PlayerBetCount {
		address player;
		uint256 betCount;
	}
	
	PlayerBetCount[] public AllPlayers;
	PlayerBetCount[] public LastWinners;
	
	uint PORTION2POOL = 80;//x%
	
	function LastWinnerGame0930() public{
		TimeToDraw = now + INTERVAL;
		totalInPool = 0;
		ZolaXAddress = 0x2ea01B09f540E6DdfB0733D9dF30259Df2805bf0;
		ZolaXImpl = ZolaXEntry(ZolaXAddress);
		setZGTToken(0xBAeB8ED7c695A31774fce2F9ef619d39d0C3a995);
		GAME_IS_RUNNING = true;
	}
	
	function changePortion2Pool (uint newPortion) public onlyOwner {
		PORTION2POOL = newPortion;
	}
	
	function setInterval(uint256 newInterval) public onlyOwner {
		INTERVAL = newInterval;
	}
	
	function setIncreaseTimeOnBet(uint256 newIncTime) public onlyOwner {
		TIME_INC_ON_BET = newIncTime;
	}
	
	function turnOnOffGame(bool onoff) public onlyOwner {
		GAME_IS_RUNNING = onoff;
		if (GAME_IS_RUNNING) {
			TimeToDraw = now + INTERVAL;//restart game
		}
	}
	
	function startNewGame() public onlyOwner {
		GAME_IS_RUNNING = true;
		TimeToDraw = now + INTERVAL;//restart game
		delete LastWinners;
	}
	
	function setZGTToken(address zstTokenAddress) public onlyOwner{    
        ZGTToken = ERC20(zstTokenAddress);
    }
	
	function isLastPlayerPast() view public returns (bool) {
		if (now >= TimeToDraw) {
			return true;
		}
		return false;
	}
	
	function getTimeToDraw() view public returns (uint256) {
		return TimeToDraw;
	}
	
	function getTokenInPool() view public returns (uint256) {
		return totalInPool;
	}
	
	function drawLucky() public onlyOwner {
		//get a temp list with betcount > 0
		delete LastWinners;
		uint256 totalLastWinnerBets;
		for (uint256 index = 0 ; index < AllPlayers.length ; index++) {
			if (AllPlayers[index].betCount > 0) {
				LastWinners.push(AllPlayers[index]);
				totalLastWinnerBets += AllPlayers[index].betCount;
			}
		}
		uint256 dividendsPerZGT = totalInPool.div(totalLastWinnerBets);
		for (index = 0 ; index < LastWinners.length ; index++) {
			uint256 dividends = dividendsPerZGT.div(LastWinners[index].betCount);
			ZolaXImpl.addWinnerInfo(LastWinners[index].player, dividends);
		}
		
		totalInPool = 0;
		ZolaXImpl.distributeProfitOnDraw();
		delete AllPlayers;
		GAME_IS_RUNNING = false;
	}
	
	function forwardToken(uint256 amount) internal returns (bool) {
		if(ZGTToken.approve(ZolaXAddress, amount)){
			if (ZGTToken.transfer(ZolaXAddress, amount)) {
				return true;
			}
		}
		return false;
	}
	
	function executeOnTokenTransfered(address player, uint256 token2Transfer, string str1, string str2, uint256 data1, uint256 data2) public returns (bool) {
		require(token2Transfer >= DECIMAL && token2Transfer <= MAX2BET*DECIMAL);//1-1000
		if (!forwardToken(token2Transfer)) {
			return false;
		}
		if (data1 == 1) {//means owner init pool, do not record on player list
			totalInPool += token2Transfer;
			return true;
		} else {
			data2 = 0;
			str1 = "";
			str2 = "";
			data1 = 0;
			return placeBet(player, token2Transfer);
		}
	}
	
	function placeBet(address player, uint256 amount) internal returns (bool) {
		require(amount>=DECIMAL);
		if (isLastPlayerPast() || !GAME_IS_RUNNING) {
			revert();
		}

		TimeToDraw += TIME_INC_ON_BET;
		if ((TimeToDraw - now) > INTERVAL) {
			TimeToDraw = now + INTERVAL;//make sure not exceed INTERVAL
		}
		totalInPool += amount.mul(PORTION2POOL).div(100);
		ZolaXImpl.addProfit(amount.mul(100-PORTION2POOL).div(100));
		
		bool found = false;
		uint256 bet = amount.div(DECIMAL);
		for (uint256 index = 0 ; index < AllPlayers.length ; index++) {
			if (AllPlayers[index].player == player) {
				AllPlayers[index].betCount += bet;
				found = true;
			} else {
				//all other player reduce 1
				if (AllPlayers[index].betCount > 0) {
					AllPlayers[index].betCount --;
					if (AllPlayers[index].betCount <= 0) {
						delete AllPlayers[index];
					}
				}
			}
		}
		if (!found) {
			PlayerBetCount memory bi = PlayerBetCount(player, bet);
			AllPlayers.push(bi);
		}
		return true;
	}

	function betUsingWonZGTOrDividendZGT(address player, uint256 amount) public {
		require(amount>=DECIMAL);
		uint256 wonZGT = ZolaXImpl.getWinBalance(player);
		uint256 dividendZGT = ZolaXImpl.getDividendBalance(player);
		if ((wonZGT + dividendZGT) < amount) {
			revert();
		}
		placeBet(player, amount);
		ZolaXImpl.decreaseWonZGTBalance(player, amount);
		if (wonZGT < amount) {
			ZolaXImpl.decreaseDividendZGTBalance(player, amount-wonZGT);
		}
	}
		
	function getPlayerLenOfThisTime() public view returns (uint256) {
		return AllPlayers.length;
	}
	
	function getPlayerAtIndex(uint256 index) public view returns (address) {
		if (index < AllPlayers.length) {
			return AllPlayers[index].player;
		}
		return 0x0;
	}
	
	function getBetCountAtIndex(uint256 index) public view returns (uint256) {
		if (index < AllPlayers.length) {
			return AllPlayers[index].betCount;
		}
		return 0;
	}
	
	function getBetCountOfPlayer(address player) public view returns (uint256) {
		uint256 bet = 0;
		for (uint256 index = 0 ; index < AllPlayers.length ; index++) {
			if (AllPlayers[index].player == player) {
				return AllPlayers[index].betCount;
			}
		}
		return bet;
	}
	
	function getCountOfPlayersWithBetCountBiggerThanGivenPlayer(address player) public view returns (uint256) {
		uint256 count = 0;
		uint256 givenplayerbet = getBetCountOfPlayer(player);
		for (uint256 index = 0 ; index < AllPlayers.length ; index++) {
			if (AllPlayers[index].betCount > givenplayerbet) {
				count ++;
			}
		}
		return count;
	}
	
	function getMaxBetCount() public view returns (uint256) {
		uint256 maxBet = 0;
		for (uint256 index = 0 ; index < AllPlayers.length ; index++) {
			if (AllPlayers[index].betCount > maxBet) {
				maxBet = AllPlayers[index].betCount;
			}
		}
		return maxBet;
	}
	
	function getPlayerCountWithBetCountBiggerThanZero() public view returns (uint256) {
		uint256 biggerthanzerocount = 0;
		for (uint256 index = 0 ; index < AllPlayers.length ; index++) {
			if (AllPlayers[index].betCount > 0) {
				biggerthanzerocount++;
			}
		}
		return biggerthanzerocount;
	}

	function getWinnerLenOfThisTime() public view returns (uint256) {
		return LastWinners.length;
	}
	
	function getWinnerAtIndexOfLastGame(uint256 index) public view returns (address) {
		if (index < LastWinners.length) {
			return LastWinners[index].player;
		}
		return 0x0;
	}
	
	function getWinnerBetCountAtIndexOfLastGame(uint256 index) public view returns (uint256) {
		if (index < LastWinners.length) {
			return LastWinners[index].betCount;
		}
		return 0;
	}
	
	function destroy() public onlyOwner {
		selfdestruct (owner);
    }

}