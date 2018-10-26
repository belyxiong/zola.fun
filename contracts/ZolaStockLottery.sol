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

interface MyReplacement {

function saveTotalBetOfToday(uint256) external returns (bool);
function savePreviousZGTInPool(uint256) external returns (bool);
function saveProfitZGT(uint256) external returns (bool);
function saveWinsPerBet(uint256) external returns (bool);
function savePermWinner(address player, uint256 balance) external returns (bool);
function saveTempWinner(address player, string number, uint256 balance) external returns (bool);
function saveBetInfo(address player, string number, uint256 balance) external returns (bool);
function resetGameInfo() external returns (bool);
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

contract ZolaLotteryGame is owned {
	  event Withdraw(address indexed player, uint256 amount);

	uint256 public minimalTokenToBet = 1000000000000000000;//1 zgt
	using SafeMath for uint256;
	address ZGTTokenAddress;
	address PredecessorAddress;
	ERC20 ZGTToken ;
	ZolaXEntry ZolaXEntryImpl;
	address ZolaXEntryAddress;
	
	string public version = "0";
	uint public backToPoolRate = 80;//rate send back to pool, means, x/100
	
	uint256 nextGameTime = 0;
	
	struct WinnerInfo {
		address player;
		uint256 winBalance;
	}
	struct BetInfo {
		address player;
		string number;
		uint256 multiple;
	}
	
	
	BetInfo[] public allBetNumbers;
	
	BetInfo[] tempWinnerList;
	uint256 public todayWinsPerBet;
	address[] admins;
	
	uint public profitRate = 20;//x%
	uint256 public totalBetZGTToday;//zgt bet today
	uint256 public previousZGTInPool;//previous zgt in pool
	uint GAMETYPE = 9;//invalid in parent class

	
	bool public gameStarted = true;//todo:set to false by default
	
	uint32 public constant decimals = 18;
	
	string public todayWinningNumber;

	function setProfitRate(uint newRate) public onlyOwner {
		profitRate = newRate;
	}
	
	function addAdmin(address newAdmin) public onlyOwner {
		for (uint i=0;i<admins.length;i++) {
			if (admins[i] == newAdmin) {
				return;
			}
		}
		admins.push(newAdmin);
	}
	
	function removeAdmin(address ad) public onlyOwner {
		for (uint i=0;i<admins.length;i++) {
			if (admins[i] == ad) {
				delete admins[i];
				return;
			}
		}
	}
	
	function checkAdmin() view public returns (bool) {
		for (uint i=0;i<admins.length;i++) {
			if (admins[i] == msg.sender) {
				return true;
			}
		}
		return false;
	}
	
	function getAdminLen() view public returns (uint) {
		return admins.length;
	}
	
	function getAdminAt(uint index) view public returns (address){
		if(admins.length > index) {
			return admins[index];
		}
		return 0x0;
	}

	function setZGTTokenAddress(address newAddress) public onlyOwner {
		ZGTTokenAddress = newAddress;
		ZGTToken = ERC20(newAddress);
	}
	
	function setMyPredecessor(address predecessor) public onlyOwner {
		PredecessorAddress = predecessor;
	}
	
	function setBackToPoolRate(uint rate) public onlyOwner {
		backToPoolRate = rate;
	}
	
	function setGameStarted(bool started) public {
		require(msg.sender == owner || checkAdmin());
		gameStarted = started;
		if (started) {
			//a new start, remove all previous bet/winner
			delete allBetNumbers;
			allBetNumbers.length = 0;
			delete tempWinnerList;
			tempWinnerList.length = 0;
			todayWinsPerBet = 0;
		}
	}


	function saveTotalBetOfToday(uint256 betToday) public returns (bool) {
		require(msg.sender == PredecessorAddress);
		totalBetZGTToday = betToday;
	}
	function savePreviousZGTInPool(uint256 previousZGT) public returns (bool) {
		require(msg.sender == PredecessorAddress);
		previousZGTInPool = previousZGT;
	}

	function saveWinsPerBet(uint256 wpb) public returns (bool){
		require(msg.sender == PredecessorAddress);
		todayWinsPerBet = wpb;
	}

	function saveTempWinner(address player, string number, uint256 betCount) public returns (bool){
		require(msg.sender == PredecessorAddress);
		BetInfo memory bi = BetInfo(player, number, betCount);
		tempWinnerList.push(bi);
	}
	function saveBetInfo(address player, string number, uint256 betCount) public returns (bool) {
		require(msg.sender == PredecessorAddress);
		BetInfo memory bi = BetInfo(player, number, betCount);
		allBetNumbers.push(bi);
	}
	
	function resetGameInfo() public returns (bool) {
		require(msg.sender == PredecessorAddress);
		delete allBetNumbers;
		delete tempWinnerList;
		todayWinsPerBet = 0;
		previousZGTInPool = 0;
		totalBetZGTToday = 0;
		
		return true;
	}

	function forwardToken(uint256 amount) internal returns (bool) {
		if(ZGTToken.approve(ZolaXEntryAddress, amount)){
			if (ZGTToken.transfer(ZolaXEntryAddress, amount)) {
				return true;
			}
		}
		return false;
	}

	//use won zgt or user's zgt dividend to bet
	function betUsingWonOrEarntZGT(uint256 amount, string str1, string str2, uint256 data1, uint256 data2) public {
		require(amount>0);
		
		uint256 wonZGTBalance = ZolaXEntryImpl.getWinBalance(msg.sender);
		uint256 dividendZGT = ZolaXEntryImpl.getDividendBalance(msg.sender);
		
		if ((wonZGTBalance + dividendZGT) >= amount) {
			if (!parseDataAndRecord(msg.sender, amount, str1, str2, data1, data2)) {
				revert();
			}
			//decrease balance from zolax
			if (amount <= wonZGTBalance) {
				ZolaXEntryImpl.decreaseWonZGTBalance(msg.sender, amount);
			} else {
				ZolaXEntryImpl.decreaseWonZGTBalance(msg.sender, wonZGTBalance);
				ZolaXEntryImpl.decreaseDividendZGTBalance(msg.sender, amount-wonZGTBalance);
			}
		} else {
			revert();
		}
	}
	
	//general api to execute command
	//if user bet more than one number , call this one
	//token2Transfer : total token transfered, when data2 ==1, it is same as data1*decimals, when data2>1, it is the total of str * decimals
	//str1 : when data2 ==1, it is the number, when data2 >1 , it is the number list
	//str2 : when data2 ==1, it is not used, when data2 > 1 , it is the multiple list
	//data2 : how many numbers bet ( to make sure data is correct)
	//data1 : when data2 == 1, means only one number, data1 is the multiple for the number
	//		   when data2 > 1, data1 is not used
	bytes tmpbyte;//used to hold multiples
	uint tempi;
	uint tempj;
	uint tempk;
	uint256 multipleWith18;
	string[] tempnumber;
	function executeOnTokenTransfered(address player, uint256 token2Transfer, string str1, string str2, uint256 data1, uint256 data2) public returns (bool) {
		require(msg.sender == ZGTTokenAddress);
		data1 = 0;
		//let's start
		//first, make sure number list matches with number count
		require(data2 >= 1);
		
		if (!forwardToken(token2Transfer)) {
			return false;
		}
		return parseDataAndRecord(player, token2Transfer, str1, str2, data1, data2);
		
	}
	
	function parseDataAndRecord(address player, uint256 token2Transfer, string str1, string str2, uint256 data1, uint256 data2) internal returns (bool) {
		require((now - nextGameTime) >= 1800);//stock close at 3:30,  game enrollment closes at 3:00, draw time  can be any time after 3:30
	
		if (data2 == 1) {//only one number
			return recordGameData(player, str1, str2, token2Transfer, data2);
		} else {//more than 1 number
			bytes memory numArr = bytes(str1);
			require(numArr.length/GAMETYPE == data2);//for guess 3 numbers, 123456, GAMETYPE is 3, data2 will be 2
			
			//string[] memory numbrList = new string[](data2);//to hold the number list
			uint256[] memory multipleList = new uint256[](data2);//to hold the multiple info of each number
			
			//split numbers
			delete tempnumber;
			
			bytes memory tmp = new bytes(GAMETYPE);
			tempj=0;
			tempi=0;
			tempk=0;
			while (tempi<numArr.length) {
				while (tempj<GAMETYPE) {
					tmp[tempj++] = numArr[tempi++];
				}
				string memory s = string(tmp);
				//numbrList[tempk++] = s;
				tempnumber.push(s);
				tempj=0;
			}
			
			//split multiples
			bytes memory multipleArr = bytes(str2);

			tempi=0;
			tempk=0;
			delete tmpbyte;
			while (tempi<multipleArr.length) {
				if( multipleArr[tempi] != 124) {//for |
					tmpbyte.push(multipleArr[tempi++]);
				} else {
					tempi++;
					multipleList[tempk++] = bytes2Int(tmpbyte);
					delete tmpbyte;
				}
			}
			

			
			for (tempi=0;tempi<multipleList.length;tempi++) {
				multipleWith18 = multipleList[tempi].mul(minimalTokenToBet);
				if (!recordGameData(player, tempnumber[tempi], "", multipleWith18, 0)) {
					return false;
				}
			}
			
			return true;
		}
	
	}

	
	function recordGameData(address player, string number, string str2, uint256 data1, uint256 data2) internal returns (bool) {
		str2= "";
        data2=0;
		uint256 multipleInInteger = data1.div(minimalTokenToBet);
		BetInfo memory newBetInfo =  BetInfo(player, number, multipleInInteger);
		allBetNumbers.push(newBetInfo);
		
		uint256 profit = data1.mul(profitRate).div(100);
		totalBetZGTToday += (data1 - profit);

		
		ZolaXEntryImpl.addProfit(profit);

		return true;
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
		
		uint256 total = 0;
		uint len = allBetNumbers.length;

		for (uint i=0;i<len;i++) {
			if (equal(allBetNumbers[i].number ,  number)) {
				total += allBetNumbers[i].multiple;
			}
		}

		return total;
	}
	

	//draw the lucky number
	function drawLucky(string winnumber, uint256 nextGameDrawTime) public {
		require(msg.sender == owner || checkAdmin());
		require(strlen(winnumber) == GAMETYPE);
		require(totalBetZGTToday > 0);
		
		todayWinningNumber = winnumber;
		
		uint256 backToPool = totalBetZGTToday;

		
		bool somebodyWin = false;
		
		delete tempWinnerList;
		
		uint len = allBetNumbers.length;

		for (uint i=0;i<len;i++) {
			if (equal(allBetNumbers[i].number ,  winnumber)) {
				tempWinnerList.push(allBetNumbers[i]);
			}
		}
		
		if (tempWinnerList.length > 0) {
			//has winner
			uint totalbet = 0;
			len = tempWinnerList.length;
			for (i=0;i<len;i++) {
				totalbet += tempWinnerList[i].multiple;
			}
			uint256 winsPerBet = ((backToPool + previousZGTInPool) / totalbet);
			todayWinsPerBet = winsPerBet;
			for (i=0;i<len;i++) {
				uint256 winCount = tempWinnerList[i].multiple * winsPerBet;
				//save winner info
				ZolaXEntryImpl.addWinnerInfo(tempWinnerList[i].player, winCount);
			}
			somebodyWin = true;
		} else {
			//no winner
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
		//distribute profit to zst holders
		ZolaXEntryImpl.distributeProfitOnDraw();
		nextGameTime = nextGameDrawTime;
	}
	
	//reset all bet info after the draw
	function resetBetInfo() internal {
		gameStarted = false;//todo:uncomment it when publish
	}
	

	
	function strlen(string str) pure internal returns (uint) {
		return bytes(str).length;
	}
	
	//get how many number bet
	function getTotalBetNumberCount() view public returns (uint) {
		return allBetNumbers.length;
	}
	
	//get the number bet on given index
	function getTodayBetNumberOf(uint index) view public returns (string) {
		if (index >=0 && index < allBetNumbers.length) {
			return allBetNumbers[index].number;
		}
		return "null";
	}
	
	//get the player on given index
	function getTodayPlayerOf(uint index) view public returns (address) {
		if (index >=0 && index < allBetNumbers.length) {
			return allBetNumbers[index].player;
		}
		return 0x0;
	}
	
	//get the multiple on given index
	function getTodayPlayerMultipleOf(uint index) view public returns (uint) {
		if (index >=0 && index < allBetNumbers.length) {
			return allBetNumbers[index].multiple;
		}
		return 0;
	}
	
	//get today's winner length
	function getTodayWinnerLength() view public returns (uint) {
		return tempWinnerList.length;
	}
	
	//get today's winner on given index
	function getTodayWinnerOf(uint index) view public returns (address) {
		if (index >=0 && index < tempWinnerList.length) {
			return tempWinnerList[index].player;
		}
		return 0x0;
	}
	
	//get today's winner on given index
	function getTodayWinnerMultipleOf(uint index) view public returns (uint) {
		if (index >=0 && index < tempWinnerList.length) {
			return tempWinnerList[index].multiple;
		}
		return 0;
	}
	

	function getTodayWinnersLen() view public returns (uint256) {
		return tempWinnerList.length;
	}
	
	//get the token count may win if bet on the given number and the number is the winning number
	function getTokenMayWinsByThisNumber(string number, uint256 count) view public returns(uint256){
		require(gameStarted);
		require(strlen(number) == GAMETYPE);
		require(count > 0);

		
		uint256 totalBetMade = getTotalBetOnThisNumber(number);
		uint256 gonaBet = count * 10 ** uint256(decimals);
		
		uint256 totalPool = (totalBetZGTToday + gonaBet).mul(backToPoolRate).div(100);
		
		return count.mul(totalPool).div(totalBetMade + count);
	}
	
	//get all number the player bet, return number list and how many times bets on
	function getAllMyBetNumberLength() view public returns(uint256) {
		uint256 AllNumbrLen = 0;
		uint256 len = allBetNumbers.length;
		for (uint256 i=0;i<len;i++) {
			if (allBetNumbers[i].player == msg.sender) {
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
			if (allBetNumbers[i].player == msg.sender) {
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
			if (allBetNumbers[i].player == msg.sender) {
				if (pos == index) {
					return allBetNumbers[i].multiple;
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
				if (!transferGameInfo(newGameAddress)) {
					revert();
				}
			} else {
				revert();
			}
		}

	}
	
	function transferGameInfo(address replacement) internal returns (bool) {
		MyReplacement newReplacement = MyReplacement(replacement);
		
		if (!newReplacement.resetGameInfo()) {
			return false;
		}
		
		if (!newReplacement.saveTotalBetOfToday(totalBetZGTToday)) {
			return false;
		}
		if (!newReplacement.savePreviousZGTInPool(previousZGTInPool)) {
			return false;
		}
		if (!newReplacement.saveWinsPerBet(todayWinsPerBet)) {
			return false;
		}
		uint i=0;

		
		
		for (i=0;i<tempWinnerList.length;i++) {
			if (!newReplacement.saveTempWinner(tempWinnerList[i].player, tempWinnerList[i].number, tempWinnerList[i].multiple)) {
				return false;
			}
		}

		for (i=0;i<allBetNumbers.length;i++) {
			if (!newReplacement.saveBetInfo(allBetNumbers[i].player, allBetNumbers[i].number, allBetNumbers[i].multiple)) {
				return false;
			}
		}
		return true;
	}
	

	
	function destroy() public onlyOwner {
		//move all remain zgt to owner
		uint256 mybalance = ZGTToken.balanceOf(this);
		if(ZGTToken.approve(owner, mybalance)){
			if (ZGTToken.transfer(owner, mybalance)) {
				selfdestruct (owner);
			}
		}
		revert();
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
	
	//convert byte array to int
	function bytes2Int(bytes _bytesValue) pure public returns (uint _ret) {
        uint j = 1;
        for(uint i = _bytesValue.length-1; i >= 0 && i < _bytesValue.length; i--) {
            assert(_bytesValue[i] >= 48 && _bytesValue[i] <= 57);
            _ret += (uint(_bytesValue[i]) - 48)*j;
            j*=10;
        }
    }
}
//////////////////////////final class
contract ZolaLotteryGameType3V0822 is ZolaLotteryGame {
	function ZolaLotteryGameType3V0822() public{
		ZGTTokenAddress = 0xBAeB8ED7c695A31774fce2F9ef619d39d0C3a995;
		ZGTToken = ERC20(ZGTTokenAddress);
		ZolaXEntryAddress = 0x2ea01B09f540E6DdfB0733D9dF30259Df2805bf0;
		ZolaXEntryImpl = ZolaXEntry(ZolaXEntryAddress);
		GAMETYPE = 3;
		version = "9";
		nextGameTime = 1535142600;//set the time for next game
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