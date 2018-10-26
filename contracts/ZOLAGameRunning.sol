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

contract ZolaLotteryGame is owned {
	  event Withdraw(address indexed player, uint256 amount);

	uint256 public minimalTokenToBet = 1000000000000000000;//1 zgt
	using SafeMath for uint256;
	address ZGTTokenAddress;
	ERC20 ZGTToken ;
	
	uint public backToPoolRate = 80;//rate send back to pool, means, x/100
	
	struct BetNumberInfo {
		string number;
		uint256  totalBet;//total bet on this number
		address[]  players;//players bet on this number
		uint256[]  times;//how many time for each player, must match with players
	}
	
	BetNumberInfo[] public allBetNumbers;
	uint256 public totalBetZGTToday;//zgt bet today
	uint256 public previousZGTInPool;//previous zgt in pool
	uint256 public profitZGT;//all tokens other than back to pool, onlyOwner can move it
	uint GAMETYPE = 9;//
	
	address[] public AllWinners;//address of all winners
	uint256[] public BalanceOfWinners;//balanceOf of all winners
	
	bool public gameStarted = true;//todo:set to false by default
	
	uint32 public constant decimals = 18;
	
	//debug flag
	uint public debug1 = 0;
	uint public debug2 = 0;
	uint public debug3 = 0;
	uint public debug4 = 0;
	uint public debug5 = 0;
	uint public debug6 = 0;
	uint public debug7 = 0;
	uint public debug8 = 0;
	uint public debug9 = 0;
	uint public debug10 = 0;
	

	
	function setBackToPoolRate(uint rate) public onlyOwner {
		backToPoolRate = rate;
	}
	
	function setGameStarted(bool started) public onlyOwner {
		gameStarted = started;
	}

	function indexOfAddress(address _addr, address[] addresslist) pure  internal returns (int) {
		uint len = addresslist.length;
		if (len == 0) {
			return -1;
		}
		for (uint i = 0 ; i < len ;i++) {
			if (addresslist[i] == _addr) {
				return int(i);
			}
		}
		return -1;
	}

	function addressContained(address _addr, address[] addresslist) pure  internal returns (bool) {
		if (addresslist.length == 0) {
			return false;
		}
		uint len = addresslist.length;
		for (uint i = 0 ; i < len ; i++) {
			if (addresslist[i] == _addr) {
				return true;
			}
		}
		return false;
	}
	
	//general api to execute command, currently same as playgame
	function executeOnTokenTransfered(address player, uint256 token2Transfer, string str1, string str2, uint256 data1, uint256 data2) public returns (bool) {
		//
		token2Transfer = 0;
		return playGame(player, str1, str2, data1, data2);
	}
	
	function playGame(address player, string str1, string str2, uint256 data1, uint256 data2) public returns (bool){
		require(msg.sender == ZGTTokenAddress);//todo:must open this when publish
		require(gameStarted);
		require(strlen(str1) == GAMETYPE);
		require(data1 >= minimalTokenToBet);
		
		
		debug1 = 0;
		debug2 = 0;
		debug3 = 0;
		debug4 = 0;
		debug5 = 0;
		debug6 = 0;
		debug7 = 0;
		debug8 = 0;
		debug9 = 0;
		debug10 = 0;
		
		return recordGameData(player, str1, str2, data1, data2);
	}
	
	function recordGameData(address player, string str1, string str2, uint256 data1, uint256 data2) internal returns (bool) {
	    //str1 -> number
		//data1 ->times( tokens to transfer)
        
        str2= "";
        data2=0;
		uint256 multipleInInteger = data1.div(minimalTokenToBet);
		debug1 = 1;
		bool found = false;
		uint256 len = allBetNumbers.length;
		debug2 = 1;
		if (len > 0) {
			debug3 = 1;
			for (uint i=0;i<len;i++) {
				if (equal(allBetNumbers[i].number, str1)) {
					//the same number was bet
					debug4 = 1;
					int indexOfPlayer = indexOfAddress(player, allBetNumbers[i].players);
					if (indexOfPlayer != -1) {
						debug5 = 1;
						//found the same player
						uint iidex = uint(indexOfPlayer);
						allBetNumbers[i].times[iidex] += multipleInInteger;
						allBetNumbers[i].totalBet += multipleInInteger;
						//
						totalBetZGTToday += data1;
					} else {
						debug6 = 1;
						//the player didn't bet this number before, do following
						
						//1. push the player to the address list
						allBetNumbers[i].players.push(player);
						//2. push the times of the player bet for this number to the times list
						allBetNumbers[i].times.push(multipleInInteger);
						allBetNumbers[i].totalBet += multipleInInteger;
						totalBetZGTToday += data1;
					}
					found = true;
					debug9 = 1;
					return true;
				}
			}
		}
		if (!found) {
			//no one bet this number before, create a new node
			debug7 = 1;
			BetNumberInfo memory newPlayNumber =  BetNumberInfo(str1,multipleInInteger, new address[](0) , new uint256[](0));
			allBetNumbers.push(newPlayNumber);
			allBetNumbers[allBetNumbers.length-1].players.push(player);
			allBetNumbers[allBetNumbers.length-1].times.push(multipleInInteger);
			totalBetZGTToday += data1;
			debug8 = 1;
			return true;
		}
		debug10 = 1;
		return false;
	}
	
	//get total zgt bet today
	function gettotalBetZGTToday() constant public returns (uint) {
		return totalBetZGTToday;
	}
	
	//get the index of the given number in all bet number list
	function indexOfBetNumber(string number) view internal returns (int) {
		require(strlen(number) == GAMETYPE);
		
		if (allBetNumbers.length <= 0) {
			return -1;
		}
		
		uint len = allBetNumbers.length;

		for (uint i=0;i<len;i++) {
			if (equal(allBetNumbers[i].number ,  number)) {
				return int(i);
			}
		}
		
		return -1;
	}
	
	//get total bet on this number
	function getTotalBetOnThisNumber(string number) view public returns (uint) {
		require(strlen(number) == GAMETYPE);
		
		int index = indexOfBetNumber(number);
		
		if (index >= 0) {
			return allBetNumbers[uint256(index)].totalBet;
		}
		
		return 0;
	}
	
	//draw the lucky number
	function drawLucky(string winnumber) public onlyOwner {
		require(strlen(winnumber) == GAMETYPE);
		require(totalBetZGTToday > 0);
		
		uint256 backToPool = totalBetZGTToday.mul(backToPoolRate).div(100);

		profitZGT += (totalBetZGTToday - backToPool);

		
		bool somebodyWin = false;

		int index = indexOfBetNumber(winnumber);
		
		if (index >= 0) {
			//somebody bet this number
			
			uint256 totalBet = allBetNumbers[i].totalBet;
			
			if (totalBet > 0) {
				//somebody win, distribute all zgt
				somebodyWin = true;
				//how many zgt every count to win

				uint256 winsPerBet = ((backToPool + previousZGTInPool) / totalBet);
				
				address[] memory winners = allBetNumbers[uint256(index)].players;
				uint[] memory times = allBetNumbers[uint256(index)].times;
				
				uint256 winCount = 0;
				uint len = winners.length;
				for (uint i=0;i<len;i++) {
					winCount = times[i] * winsPerBet;
					
					int index2 = indexInAllWinners(winners[i]);
					if (index2 >= 0) {
						//find the winner the winners pool
						BalanceOfWinners[uint256(index2)] += winCount;
					} else {
						//this is a new winner, add to the end
						AllWinners.push(winners[i]);
						BalanceOfWinners.push(winCount);
					}
				}
			}
			
		}
		
		//done with distribute winning,  reset and move all rest tokens to pool
		resetBetInfo();
		if (!somebodyWin) {
			//if nobody wins, move today's bet token to pool
			previousZGTInPool += backToPool;
			totalBetZGTToday = 0;
		} else {
			//somebody wins, all previous and today token are distributed
			totalBetZGTToday = 0;
			previousZGTInPool = 0;
		}
	}
	
	//reset all bet info after the draw
	function resetBetInfo() internal {
		delete allBetNumbers;
		allBetNumbers.length = 0;
		//gameStarted = false;//todo:uncomment it when publish
	}
	
	//winner withdraw
	function withdraw(uint256 amount) public {
		require(amount>0);
		
		int index = indexInAllWinners(msg.sender);
		
		if (index >= 0) {
			uint256 withdrawAmount = amount;// * 10 ** uint256(decimals);
			uint256 balance = BalanceOfWinners[uint256(index)];
			if (balance>=withdrawAmount) {
				if(ZGTToken.approve(msg.sender, withdrawAmount)){
					if (ZGTToken.transfer(msg.sender, withdrawAmount)) {
						emit Withdraw(msg.sender, withdrawAmount);
						
						//remove player if all balance is withdrawn
						if (withdrawAmount == balance) {
						
							if (AllWinners.length <= 1) {
								delete AllWinners;
								AllWinners.length = 0;
								delete BalanceOfWinners;
								BalanceOfWinners.length = 0;
							} else {
								removeWinnerInfo(uint256(index));
							}
							
						} else {
							//some balance remains
							BalanceOfWinners[uint256(index)] = balance - withdrawAmount;
						}
						return;
					}
				}

			}
		}
		
		revert();
	}
	
	//remove winner info from the winner list if all winning token was withdrawn
	function removeWinnerInfo(uint index) internal {
        if (index >= AllWinners.length) return;
		uint i = 0;

        for (i = index; i<AllWinners.length-1; i++){
            AllWinners[i] = AllWinners[i+1];
        }
        AllWinners.length--;

		for (i = index; i<BalanceOfWinners.length-1; i++){
            BalanceOfWinners[i] = BalanceOfWinners[i+1];
        }
        BalanceOfWinners.length--;
    }
	
	function indexInAllWinners(address player)  view internal returns (int) {
		uint len = AllWinners.length;
		for (uint i=0;i<len;i++) {
			if (AllWinners[i] == player) {
				return int(i);
			}
		}
		return -1;
	}
	
	//get the winning balance for the user
	function getWinningBalance(address player) view public returns (uint256) {
		int indexOfPlayer = indexInAllWinners(player);
		if (indexOfPlayer >= 0) {
			return BalanceOfWinners[uint256(indexOfPlayer)];
		}
		return 0;
	}
	
	function strlen(string str) pure internal returns (uint) {
		return bytes(str).length;
	}
	
	//get how many number bet
	function getTotalBetNumberCount() view public returns (uint) {
		return allBetNumbers.length;
	}
	
	//get the number bet on given index
	function getBetNumberOf(uint index) view public returns (string) {
		if (index >=0 && index < allBetNumbers.length) {
			return allBetNumbers[index].number;
		}
		return "null";
	}
	
	//get players count on given index
	function getTotalPlayerLengthOf(uint index) view public returns (uint) {
		if (index >=0 && index < allBetNumbers.length) {
			return allBetNumbers[index].players.length;
		}
		return 0;
	}
	
	//get player address of given indexes
	//indexOfAllNumber : index in the all bet numbers
	//indexOfPlayer : index in the player list
	function getPlayerAddressOf(uint indexOfAllNumber, uint indexOfPlayer) view public returns (address) {
		if (indexOfAllNumber >=0 && indexOfAllNumber < allBetNumbers.length) {
			address[] memory players = allBetNumbers[indexOfAllNumber].players;
			
			if (indexOfPlayer >=0 && indexOfPlayer < players.length) {
				return players[indexOfPlayer];
			}
		}
		
		return 0;
	}
	
	function getTotalWinnersLen() view public returns (uint256) {
		return AllWinners.length;
	}
	
	//get the token count may win if bet on the given number and the number is the winning number
	function getTokenMayWinsByThisNumber(string number, uint256 count) view public returns(uint256){
		require(gameStarted);
		require(strlen(number) == GAMETYPE);
		require(count >= minimalTokenToBet);

		int indexOfNumber = indexOfBetNumber(number);
		uint256 betOnTheNumber = 0;
		uint256 allOfPlayerBet = count * 10 ** uint256(decimals);

		if (indexOfNumber >= 0) {
			//found the number
			betOnTheNumber = allBetNumbers[uint256(indexOfNumber)].totalBet;
			int indexOfPlayer = indexOfAddress(msg.sender, allBetNumbers[uint256(indexOfNumber)].players);
			if (indexOfPlayer >= 0) {
				//the player already made a bet on this number
				allOfPlayerBet += allBetNumbers[uint256(indexOfNumber)].times[uint256(indexOfPlayer)];
			}

		}
					
		betOnTheNumber += count;
		uint256 allBetToday = (totalBetZGTToday + count).mul(backToPoolRate).div(100);
		return allOfPlayerBet.mul(allBetToday).div(betOnTheNumber);
	}
	
	//get all number the player bet, return number list and how many times bets on
	function getAllMyBetNumberLength() view public returns(uint256) {
		uint256 AllNumbrLen = 0;
		uint256 len = allBetNumbers.length;
		for (uint256 i=0;i<len;i++) {
			int indexOfPlayer = indexOfAddress(msg.sender, allBetNumbers[i].players);
			if (indexOfPlayer >= 0) {
				AllNumbrLen ++;
			}
		}
		return AllNumbrLen;
	}
	
	function getMyBetNumsOf(uint256 index) view public returns(string) {
		require(index >=0);

		uint256 pos = 0;
	
		uint256 len = allBetNumbers.length;
		for (uint256 i=0;i<len;i++) {
			int indexOfPlayer = indexOfAddress(msg.sender, allBetNumbers[i].players);
			if (indexOfPlayer >= 0) {
				if (pos == index) {
					return allBetNumbers[i].number;
				}
				pos ++;
			}
		}

		return "0";
	}
	
	function getMyMultiplesOfBetNumsAt(uint256 index) view public returns(uint256) {
		require(index >=0);
		
		uint256 pos = 0;
	
		uint256 len = allBetNumbers.length;
		for (uint256 i=0;i<len;i++) {
			int indexOfPlayer = indexOfAddress(msg.sender, allBetNumbers[i].players);
			if (indexOfPlayer >= 0) {
				if (pos == index) {
					return allBetNumbers[i].times[uint256(indexOfPlayer)];
				}
				pos ++;
			}
		}
		return 0;
	}
	
////////////////////////////////////////////////////////////////////////	
	
	//replace a implementation
	function replaceMe(address newGameAddress) public onlyOwner{

		//transfer zgt to new contract
		uint256 restZGTToken = ZGTToken.balanceOf(this);
		if(ZGTToken.approve(newGameAddress, restZGTToken)){
			if (ZGTToken.transfer(newGameAddress, restZGTToken)) {
			} else {
				revert();
			}
		}

	}
	
	//move profit to distribution contract
	function moveProfit(address addr) public onlyOwner {
		require(addr != 0x0);
		require(profitZGT > 0);
		
		if(ZGTToken.approve(addr, profitZGT)){
			if (ZGTToken.transfer(addr, profitZGT)) {
				profitZGT = 0;
				return;
			}
		}
		revert();
	}
	
	function destroy() public onlyOwner {
		//move all remain zgt to owner
		uint256 mybalance = ZGTToken.balanceOf(this);
		if(ZGTToken.approve(owner, mybalance)){
			if (ZGTToken.transfer(owner, mybalance)) {

			}
		}
        selfdestruct (owner);
    }
    
    function compare(string stra, string strb) pure internal returns (int) {
        bytes memory a = bytes(stra);
        bytes memory b = bytes(strb);
        uint minLength = a.length;
        if (b.length != minLength) {
            return -1;
        }
        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons
        for (uint i = 0; i < minLength; i ++) {
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        }

        return 0;
    }
    /// @dev Compares two strings and returns true iff they are equal.
    function equal(string _a, string _b) pure public returns (bool) {
        return compare(_a, _b) == 0;
    }
	
}
//////////////////////////final class
contract ZolaLotteryGameType3 is ZolaLotteryGame {
		
	function ZolaLotteryGameType3(address zgtTokenAddress) public{
		ZGTTokenAddress = zgtTokenAddress;
		ZGTToken = ERC20(zgtTokenAddress);
		GAMETYPE = 3;
	}
}

contract ZolaLotteryGameType4 is ZolaLotteryGame {
		
	function ZolaLotteryGameType4(address zgtTokenAddress) public{
		ZGTTokenAddress = zgtTokenAddress;
		ZGTToken = ERC20(zgtTokenAddress);
		GAMETYPE = 4;
	}
}

contract ZolaLotteryGameType6 is ZolaLotteryGame {
		
	function ZolaLotteryGameType6(address zgtTokenAddress) public{
		ZGTTokenAddress = zgtTokenAddress;
		ZGTToken = ERC20(zgtTokenAddress);
		GAMETYPE = 6;
	}
}