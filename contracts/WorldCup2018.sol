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
}

contract WorldCup2018Of0702 is owned {
    using SafeMath for uint256;
	struct GameInfo {
		uint gameid;
		string team1;
		string team2;
		string matchtime;
		uint256 betDeadline;
		uint256 totalInPool;
		uint256 team1winbet;
		uint256 team2winbet;
		uint256 drawbet;
		string extra;
	}
	
	struct BetInfo {
		address player;
		uint game2Bet;//id
		uint256 multiple;
		uint betcontent;//  0 : team1 win, 1 : team2 win, 2 : draw
	}
	uint256 DECIMAL = 18;
	ERC20 ZGTToken;
	ZolaXEntry ZolaXEntryImpl;
	address ZolaXEntryAddress;
	address ZGTTokenAddress;
	
	GameInfo[] public AllGames;
	BetInfo[] public AllBetInfo;
	address[] public admins;

	uint public profitRate = 20;//x%
	uint public donationRate = 10;//x%

	
	function WorldCup2018Of0702() public{
	    ZGTTokenAddress = 0x064f9fdb746fc4a58cbde8c3f1f3979b2c43e748;
		ZGTToken = ERC20(ZGTTokenAddress);
		
		ZolaXEntryAddress = 0xDab38F8CF73964a52E4d94731aa7F872c6E5824e;
		ZolaXEntryImpl = ZolaXEntry(ZolaXEntryAddress);
		initGameInfo();
	}

	
	function initGameInfo() pure internal{
		//add game info
	}
	
	
	function addGame(uint gameid, string matchtime, uint256 deadline, string team1, string team2, string extra) public {
		require(isAdmin(msg.sender));
		GameInfo memory newgame = GameInfo(gameid, team1, team2, matchtime, deadline, 0, 0, 0, 0, extra);
		AllGames.push(newgame);
	}
	
	function getAllGameLen() view public returns (uint) {
		return AllGames.length;
	}
	
	function setGameTeamName(uint gid, string t1, string t2) public {
		require(isAdmin(msg.sender));
		
		uint index = findGame(gid);
		
		if(index != INVALID_GAMEID){
			AllGames[index].team1 = t1;
			AllGames[index].team2 = t2;
		}
	}
	
	function deleteGame(uint gid) public {
		require(isAdmin(msg.sender));
		
		uint index = findGame(gid);
		
		if(index != INVALID_GAMEID){
			delete	AllGames[index];
		}
	}
	
	function setGameDeadline(uint gid, uint256 deadline) public {
		require(isAdmin(msg.sender));
		
		uint index = findGame(gid);
		
		if(index != INVALID_GAMEID){
			AllGames[index].betDeadline = deadline;
		}
	}
	
	function getGameExtra(uint index) view public returns (string) {
		require(index>=0);
		require(index<AllGames.length);

		return AllGames[index].extra;
	}
	
	function getGameMatchTime(uint index) view public returns(string) {
		require(index>=0);
		require(index<AllGames.length);

		return AllGames[index].matchtime;
	}
	
	function getGameTeam1Name(uint index) view public returns (string) {
		require(index>=0);
		require(index<AllGames.length);

		return AllGames[index].team1;
	}
	

		
	function getGameTeam2Name(uint index) view public returns (string) {
		require(index>=0);
		require(index<AllGames.length);

		return AllGames[index].team2;
	}

	function getGameDeadline(uint index) view public returns (uint256) {
		require(index>=0);
		require(index<AllGames.length);

		return AllGames[index].betDeadline;
	}
	
	function getGameIDInGameList(uint index) view public returns (uint256) {
		require(index>=0);
		require(index<AllGames.length);

		return AllGames[index].gameid;
	}

	//1 : expired, 0: not expired
	function isGameDeadlinePassed(uint index) view public returns (uint) {
		require(index>=0);
		require(index<AllGames.length);
		
		if (now >= AllGames[index].betDeadline) {
			return 1;
		} else {
			return 0;
		}
	}
	
	uint INVALID_GAMEID = 999;
	
	function findGame(uint gid) view internal returns (uint){
		for(uint i=0;i<AllGames.length;i++) {
			if(AllGames[i].gameid == gid) {
				return i;
			}
		}
		return INVALID_GAMEID;
	}
	
	function changeZGTAddress(address newzgt) public onlyOwner {
		ZGTTokenAddress = newzgt;
		ZGTToken = ERC20(newzgt);
	}
	
	
	function destroy(address admin) public {
		require(isAdmin(msg.sender));
		//move all remain zgt to admin
		uint256 mybalance = ZGTToken.balanceOf(this);
		if (mybalance > 0) {
			if(ZGTToken.approve(admin, mybalance)){
				ZGTToken.transfer(admin, mybalance);
			}
		}
		selfdestruct (admin);
	}
	
	function setZolaXEntry(address newaddress) public {
		require(isAdmin(msg.sender));
		ZolaXEntryImpl = ZolaXEntry(newaddress);
		ZolaXEntryAddress = newaddress;
	}
	
	function forwardToken(uint256 amount) internal returns (bool) {
		if(ZGTToken.approve(ZolaXEntryAddress, amount)){
			if (ZGTToken.transfer(ZolaXEntryAddress, amount)) {
				return true;
			}
		}
		return false;
	}
	
	bytes tmpbyte;
			
	uint256 sumProfit;
	uint256 sumDonation;
	uint currentHandle = 0;//0 : game id, 1 : bet content, 2 : multiple
	
	uint game2bet;
	uint256 multiple;
	uint betcontent;
	uint256 totalBetThisTime;

	function executeOnTokenTransfered(address player, uint256 token2Transfer, string str1, string str2, uint256 data1, uint256 data2) public returns (bool) {
		require(msg.sender == ZGTTokenAddress);
	
		//forward token to zolax
		if (!forwardToken(token2Transfer)) {
			return false;
		}
		//parse str1
		//game id|bet|multiple
		data1=0;data2=0;str2="";
		
		return parseBetContent(player, token2Transfer, str1);

	}

	//convert byte array to int
	function bytes2Int(bytes _bytesValue) pure internal returns (uint _ret) {
        uint j = 1;
        for(uint i = _bytesValue.length-1; i >= 0 && i < _bytesValue.length; i--) {
            assert(_bytesValue[i] >= 48 && _bytesValue[i] <= 57);
            _ret += (uint(_bytesValue[i]) - 48)*j;
            j*=10;
        }
    }
	
	function parseBetContent(address player, uint256 tokenused, string content) internal returns (bool) {
		uint tempi = 0;
		
		delete tmpbyte;
	
	    sumProfit = 0;
		sumDonation = 0;
		
		totalBetThisTime = 0;

		bytes memory betinfos = bytes(content);

		
		while (tempi<betinfos.length) {
			if( betinfos[tempi] != 124) {//for |
				tmpbyte.push(betinfos[tempi++]);
			} else {
				tempi++;
				
				if (currentHandle == 0) {
					currentHandle = 1;
					game2bet = bytes2Int(tmpbyte);
				} else if (currentHandle == 1) {
					currentHandle = 2;
					betcontent = bytes2Int(tmpbyte);
				} else if (currentHandle == 2) {
					currentHandle = 0;
					multiple = bytes2Int(tmpbyte);
					uint index = findGame(game2bet);
					if (index<AllGames.length && index>=0 && multiple>0 && betcontent >= 0 && now < AllGames[index].betDeadline) {
						if (!betInfoMerged(player, game2bet, betcontent, multiple)) {
							BetInfo memory newBetInfo =  BetInfo(player, game2bet, multiple, betcontent);
							AllBetInfo.push(newBetInfo);
						}
						uint256 betAmount = multiple * 10 ** uint256(DECIMAL);
						uint256 profit = betAmount.mul(profitRate).div(100);
						uint256 donation = betAmount.mul(donationRate).div(100);
						totalBetThisTime += betAmount;
						sumProfit += profit;
						sumDonation += donation;
						if (!addGamePoolInfo(game2bet, betAmount - profit - donation, betcontent, multiple)) {
							revert();
						}
					} else {
						revert();
					}
				}
				
				delete tmpbyte;
			}
		}
		
		if (totalBetThisTime != tokenused) {
			revert();
			return false;
		}
		
		if (sumProfit > 0) {
			ZolaXEntryImpl.addProfit(sumProfit);
		}
		if (sumDonation > 0) {
			ZolaXEntryImpl.addDonation(sumDonation);
		}
		return true;
	}

	//check if can merge bet info
	function betInfoMerged(address player, uint gameid, uint bet, uint256 mul) internal returns (bool) {
		for (uint i=0;i<AllBetInfo.length;i++) {
			if (AllBetInfo[i].player == player && AllBetInfo[i].game2Bet == gameid && AllBetInfo[i].betcontent == bet) {
				AllBetInfo[i].multiple += mul;
				return true;
			}
		}
		return false;
	}

	//bet using user's deposit, only owner can do this
	function BetUsingDeposit(address player, uint256 zgtcost, string bet) public{
		require(isAdmin(msg.sender));
		uint256 costWithDecimal = zgtcost.mul(10 ** uint256(DECIMAL));
		if(ZolaXEntryImpl.getDepositBalance(player)>= costWithDecimal) {
			if (parseBetContent(player, costWithDecimal, bet)) {
				ZolaXEntryImpl.decreaseDeposit(player, costWithDecimal);
				return;
			}
		}
		revert();
	}

	function addGamePoolInfo(uint gameid, uint256 amount, uint betc, uint256 mul) internal returns(bool){
		require(amount > 0);

		uint index = findGame(gameid);
		if(index == INVALID_GAMEID){
			return false;
		}
	
		AllGames[index].totalInPool += amount;//total in pool
		//  0 : team1 win, 1 : team2 win, 2 : draw
		if (betc == 0) {
			AllGames[index].team1winbet += mul;
		} else if (betc == 1) {
			AllGames[index].team2winbet += mul;
		} else if (betc == 2) {
			AllGames[index].drawbet += mul;
		} else {
			return false;
		}
		return true;
	}
	
	function getGamePoolAmount(uint gameid) view public returns(uint256) {
		uint index = findGame(gameid);
		if (index != INVALID_GAMEID) {
			return AllGames[index].totalInPool;
		}
		return 0;
	}
	
	//get how many players on all games
	function getPlayerLengthOnAllGames() view public returns (uint256) {
		return AllBetInfo.length;
	}
	//get player on bet list at 
	function getPlayerAtBetInfo(uint256 index) view public returns (address) {
		require(index>=0 && index<AllBetInfo.length);
		return AllBetInfo[index].player;
	}
	//get gameid on bet list at
	function getGameidAtBetInfo(uint256 index) view public returns (uint) {
		require(index>=0 && index<AllBetInfo.length);
		return AllBetInfo[index].game2Bet;
	}
	//get betcontent on bet list at
	function getBetContentAtBetInfo(uint256 index) view public returns (uint) {
		require(index>=0 && index<AllBetInfo.length);
		return AllBetInfo[index].betcontent;
	}
	//get multiple on bet list at
	function getMultipleAtBetInfo(uint256 index) view public returns (uint) {
		require(index>=0 && index<AllBetInfo.length);
		return AllBetInfo[index].multiple;
	}
	

	//get how many players made bet on the game
	function getPlayerLengthOnGame(uint gameid) view public returns (uint256) {
		uint len = 0;
		for (uint i=0;i<AllBetInfo.length;i++) {
			if (AllBetInfo[i].game2Bet == gameid) {
				len ++;
			}
		}
		return len;
	}
	
	//get the player of gameid at index ?
	function getPlayerOfGameAt(uint gameid, uint256 index) view public returns (address) {
		uint len = 0;
		for (uint i=0;i<AllBetInfo.length;i++) {
			if (AllBetInfo[i].game2Bet == gameid) {
				if (len == index) {
					return AllBetInfo[i].player;
				}
				len ++;
			}
		}
		return 0x0;
	}
	
	//get the multiple of gameid at index ?
	function getMultipleMadeOnGameAt(uint gameid, uint256 index) view public returns (uint256) {
		uint len = 0;
		for (uint i=0;i<AllBetInfo.length;i++) {
			if (AllBetInfo[i].game2Bet == gameid) {
				if (len == index) {
					return AllBetInfo[i].multiple;
				}
				len ++;
			}
		}
		return 0;
	}
	
	//get the bet content of gameid at index ?
	function getBetContentMadeOnGameAt(uint gameid, uint256 index) view public returns (uint) {
		uint len = 0;
		for (uint i=0;i<AllBetInfo.length;i++) {
			if (AllBetInfo[i].game2Bet == gameid) {
				if (len == index) {
					return AllBetInfo[i].betcontent;
				}
				len ++;
			}
		}
		return 3;//unknown
	}
	
	//get how many different bets made on game
	function getBetDetailsOnGame(uint gameid, uint bet) view public returns (uint256) {
		//bet => 0 : team1 win, 1 : team2 win, 2 : draw 
		require(bet>=0 && bet<=2);

		uint index = findGame(gameid);
		
		if (index == INVALID_GAMEID) return 0;
		
		if (bet == 0) {
			return AllGames[index].team1winbet;
		} else if(bet == 1) {
			return AllGames[index].team2winbet;
		} else if(bet == 2) {
			return AllGames[index].drawbet;
		} 
		return 0;
	}

	
	//get token may win based on the gameid , bet type and multiple
	function getTokenMayWin(uint gameid, uint bettype, uint256 multi) view public returns (uint256) {
		require(bettype>=0 && bettype<=2);
	
		uint index = findGame(gameid);
		
		if (index == INVALID_GAMEID) return 0;
		
		uint256 sameBet = getBetDetailsOnGame(gameid, bettype);
		uint256 tokenInPool = AllGames[index].totalInPool;
		
		uint256 betAmount = multi.mul(10 ** uint256(DECIMAL));
		uint256 profit = betAmount.mul(profitRate).div(100);
		uint256 donation = betAmount.mul(donationRate).div(100);
		
		tokenInPool = tokenInPool + betAmount - profit - donation;
		
		uint256 winToken = tokenInPool.mul(multi).div(sameBet + multi);
		return winToken;
	}
	
	BetInfo[] tempBetInfoList;
	//draw the lucky winner for game
	function draw(uint gameid, uint result) public {
		require(isAdmin(msg.sender));
		
		uint index = findGame(gameid);
		if (index == INVALID_GAMEID) revert();
		
		
		uint256 totalCorrectBet = 0;
		uint256 winPerBet = 0;
		
		
		delete tempBetInfoList;

		
		for (uint i=0;i<AllBetInfo.length;i++) {
			if (AllBetInfo[i].game2Bet == gameid) {
				if (AllBetInfo[i].betcontent == result) {
					totalCorrectBet += AllBetInfo[i].multiple;
					tempBetInfoList.push(AllBetInfo[i]);
				}			
				delete AllBetInfo[i];
			}
		}

		winPerBet = AllGames[index].totalInPool/totalCorrectBet;
		
		for(i=0;i<tempBetInfoList.length;i++) {
			ZolaXEntryImpl.addWinnerInfo(tempBetInfoList[i].player, winPerBet.mul(tempBetInfoList[i].multiple));
		}
	}

	
	function changeProfitRate(uint newrate) public {
		require(isAdmin(msg.sender));
		profitRate = newrate;
	}
	
	function changeDonationRate(uint newrate) public {
		require(isAdmin(msg.sender));
		donationRate = newrate;
	}

	function addAdmin(address player) public onlyOwner {
		require(player != 0x0);
		for(uint i=0;i<admins.length;i++) {
			if (admins[i] == player) {
				return;
			}
		}
		admins.push(player);
	}
	
	function deleteAdmin(address player) public onlyOwner {
		require(player != 0x0);
		for(uint i=0;i<admins.length;i++) {
			if (admins[i] == player) {
				delete admins[i];
			}
		}
	}
	
	function isAdmin(address who) view public returns (bool){
		if (who == owner) {
			return true;
		}
		for(uint i=0;i<admins.length;i++) {
			if (admins[i] == who) {
				return true;
			}
		}
		return false;
	}
}