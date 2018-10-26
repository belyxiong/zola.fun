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

interface ZSTToken{
	function balanceOf(address who) view external  returns (uint256);
	function getZSTHolderLength() view external returns (uint256);
	function getZSTHolderAt(uint256 index) view external returns (address);
}

interface ZSTSaleContract {
	function getSoldTokenAmount() external view returns(uint256);
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


contract ZolaXEntryOf1023 is owned {
	using SafeMath for uint256;
	ERC20 ZGTToken;
	ZSTToken zstToken;
	ZSTSaleContract zstSale;

	address[] public gamelist;
	address[] public hugeAmountWithdrawAuthrizedPlayer;
	mapping(address => uint256) public Winbalances;
	mapping(address => uint256) public ZGTDepositBalance;
	mapping(address => uint256) public DividendShareList;
	
	
	
	uint256 public totalProfit;
	uint256 public totalDonation;
	
	uint256 DECIMAL = 18;
	uint256 RATEOFZOLAX = 1000;
	
	uint TEAMPORTIONOFPROFIT = 15;
	
	address ZGTTokenAddress;
	address ZSTSaleImplAddress;
	address teamProfitReceiver;
	uint256 totalTeamProfit;
	
	uint256 public outsideZGT = 0;//amount of zgt outside
	
	bool exchangeEnabled = true;
	bool withdrawEnabled = true;
	
	constructor() public{
		ZGTTokenAddress  = 0xb630EBC7647cB239E5b877c4DC0B218346260D60;
		ZGTToken = ERC20(ZGTTokenAddress);
		
		ZSTSaleImplAddress = 0x08D93eACa46B32385A0f4e9080B6C36422c1C7d0;//sale impl
		zstSale = ZSTSaleContract(ZSTSaleImplAddress);
		
		zstToken = ZSTToken(0x0839bD51140D7a55A05A4676EeB255b1ABC85F6a);
		

	}
	
	function changeZGTAddress(address newzgt) public onlyOwner {
		ZGTTokenAddress  = newzgt;
		ZGTToken = ERC20(newzgt);
	}
	
	function changeZSTSaleAddress(address newzstsaleaddr) public onlyOwner {
		ZSTSaleImplAddress = newzstsaleaddr;
		zstSale = ZSTSaleContract(ZSTSaleImplAddress);
	}
	
	function enableExchange(bool enable) public onlyOwner {
		exchangeEnabled = enable;
	}
	
	function enableWithdraw(bool enable) public onlyOwner {
		withdrawEnabled = enable;
	}
	
	function changeTeamPortionOfProfit(uint newValue) public onlyOwner {
		TEAMPORTIONOFPROFIT = newValue;
	}
	
	function getTeamProtionOfProfit() public view returns (uint) {
		return TEAMPORTIONOFPROFIT;
	}
	
	//withdraw team profit in ETH
	function withdrawTeamProfit() public onlyOwner {
		uint256 teamZGT2ETH = totalTeamProfit.div(RATEOFZOLAX);
		if (teamZGT2ETH > 0) {
			owner.transfer(teamZGT2ETH);
		}
		totalTeamProfit = 0;
	}

	function getDividendBalance(address player) public view returns (uint256) {
		require(player != 0x0);
		return DividendShareList[player];
	}
	
	function() external payable {
		if (msg.sender == owner || msg.sender == ZSTSaleImplAddress) {
			//do nothing if get ETH from owner or zst sale address, they just put ETH on
		} else {//normal buy zgt
			if (!exchangeEnabled) {
				revert();
			}
			uint256 zgtAmount = msg.value.mul(RATEOFZOLAX);
			if (ZGTToken.approve(msg.sender, zgtAmount)) {
				if (ZGTToken.transfer(msg.sender, zgtAmount)) {
					outsideZGT += zgtAmount;
					return;
				}
			}
			revert();
		}
    }
	
	function getOutsideZGTAmount() view public returns (uint256) {
		return outsideZGT;
	}
	
	function setRateOfZolaX(uint256 newRate) public onlyOwner {
		RATEOFZOLAX = newRate;
	}
	
	//////replace methods
	function destroy() public onlyOwner {
		getEth();
		transferZGTBalance(owner);
		if (ZGTToken.balanceOf(this) <= 0) {
			selfdestruct (owner);
		}
	}
	
	function getZGTBalance() view public returns (uint256) {
		return ZGTToken.balanceOf(this);
	}
	
	//get all eth on zolax
	function getEth() public onlyOwner {
        owner.transfer(address(this).balance);
    }
	
	
	function transferZGTBalance(address where) public onlyOwner {
		require(where != 0x0);
		uint256 restZGTToken = ZGTToken.balanceOf(this);
		if(ZGTToken.approve(where, restZGTToken)){
			if (ZGTToken.transfer(where, restZGTToken)) {

			} else {
				revert();
			}
		}
	}
	//////replace methods end

	
	/////profit and donation management
	function transferProfit(address where) public onlyOwner {
		require(where != 0x0);
		if(ZGTToken.approve(where, totalProfit)){
			if (ZGTToken.transfer(where, totalProfit)) {

			} else {
				revert();
			}
		}
	}
	
	function transferDonation(address where) public onlyOwner {
		require(where != 0x0);
		if(ZGTToken.approve(where, totalDonation)){
			if (ZGTToken.transfer(where, totalDonation)) {

			} else {
				revert();
			}
		}
	}
	
	//called every time a game is ended.
	function distributeProfitOnDraw() public {
		if (!isValidSender(msg.sender)) {
			revert();
		}
		
		//
		uint256 soldAmount = zstSale.getSoldTokenAmount();
		if (soldAmount <= 0) {
			return;
		}
		uint256 soldTokenInInteger = soldAmount.div((10 ** uint256(DECIMAL)));
		if(soldTokenInInteger <= 0){
			return;
		}
		
		uint256 teamProfit = totalProfit.mul(TEAMPORTIONOFPROFIT).div(100);
		totalTeamProfit += teamProfit;
		
		uint256 profitPerZSTShare = (totalProfit-totalTeamProfit).div(soldTokenInInteger);
		
		
		uint256 zstHolderLen = zstToken.getZSTHolderLength();
		for (uint256 i=0;i<zstHolderLen;i++) {
			address holder = zstToken.getZSTHolderAt(i);
			if (holder != ZSTSaleImplAddress && holder != owner) {
				uint256 holdAMount = zstToken.balanceOf(holder).div((10 ** uint256(DECIMAL)));
				
				if (holdAMount >=1) {
					uint256 totalShareForHolder = holdAMount.mul(profitPerZSTShare);
					DividendShareList[holder] = DividendShareList[holder].add(totalShareForHolder);
				}
			}
		}
		totalProfit = 0;
	}
	/////profit and donation management end
	
	//move won zgt balance as deposit balance by user
	function depositWonZGTByUser(uint256 amount) public {
		require(amount > 0);
		uint256 amountWithDecimal = amount.mul(10 ** uint256(DECIMAL));
		require(Winbalances[msg.sender] >= amountWithDecimal);
		
		moveWinZGT2DepotZGT(msg.sender, amountWithDecimal);
	}
	
	//move won zgt balance to deposit by owner upon user's request
	function depositWonZGTByOwner(address player, uint256 amount) public onlyOwner {
		require(player != 0x0);
		require(amount > 0);
		uint256 amountWithDecimal = amount.mul(10 ** uint256(DECIMAL));
		require(Winbalances[player] >= amountWithDecimal);
		
		moveWinZGT2DepotZGT(player, amountWithDecimal);
	}
	
	function moveWinZGT2DepotZGT(address player, uint256 amount) internal {
		Winbalances[player] = Winbalances[player].sub(amount);
		ZGTDepositBalance[player] = ZGTDepositBalance[player].add(amount);
		if (Winbalances[player] == 0) {
			delete Winbalances[player];
		}
	}
	
	//winner withdraw won zgt
	function withdrawWonZGT(uint256 withdrawAmount) public {
		require(withdrawAmount>0);
		require(withdrawEnabled);
		
		if (withdrawAmount >= 10000) {
			if (!isAllowHugeWithdraw(msg.sender)) {
				revert();
				return;
			}
		}
		
		withdrawAmount = withdrawAmount.mul(10 ** uint256(DECIMAL));
		
		if (Winbalances[msg.sender]>=withdrawAmount) {
			if(ZGTToken.approve(msg.sender, withdrawAmount)){
				if (ZGTToken.transfer(msg.sender, withdrawAmount)) {
					//remove player if all balance is withdrawn
					if (withdrawAmount == Winbalances[msg.sender]) {
						delete 	Winbalances[msg.sender];
					} else {
						//some balance remains
						Winbalances[msg.sender] = Winbalances[msg.sender].sub(withdrawAmount);
					}
					return;
				}
			}

		}
		
		revert();
	}
	
	//user withdraw equal ETH of won ZGT
	function withdrawWonZGTInETH(uint256 withdrawAmount) public {
		require(withdrawAmount>0);
		require(withdrawEnabled);
		
		if (withdrawAmount >= 1) {
			if (!isAllowHugeWithdraw(msg.sender)) {
				revert();
				return;
			}
		}
		
		uint256 zgt2eth = Winbalances[msg.sender].div(RATEOFZOLAX);
		uint256 ethWithDecimal = withdrawAmount.mul(10 ** uint256(DECIMAL));
		if (zgt2eth >= ethWithDecimal) {
			    msg.sender.transfer(ethWithDecimal);
				uint256 restETHValue = zgt2eth.sub(ethWithDecimal);
				uint256 eth2zgt = restETHValue.mul(RATEOFZOLAX);
				if (eth2zgt > 0) {
					Winbalances[msg.sender] = eth2zgt;
				} else {
					delete Winbalances[msg.sender];
				}
			
		}
		revert();
	}


	
	//winner withdraw dividend of zgt
	function withdrawDividendZGT(uint256 withdrawAmount) public {
		require(withdrawAmount>0);
		require(withdrawEnabled);
		
		if (withdrawAmount >= 10000) {
			if (!isAllowHugeWithdraw(msg.sender)) {
				revert();
				return;
			}
		}
		
		withdrawAmount = withdrawAmount.mul(10 ** uint256(DECIMAL));
		
		if (DividendShareList[msg.sender]>=withdrawAmount) {
			if(ZGTToken.approve(msg.sender, withdrawAmount)){
				if (ZGTToken.transfer(msg.sender, withdrawAmount)) {
					//remove player if all balance is withdrawn
					if (withdrawAmount == DividendShareList[msg.sender]) {
						delete 	DividendShareList[msg.sender];
					} else {
						//some balance remains
						DividendShareList[msg.sender] = DividendShareList[msg.sender].sub(withdrawAmount);
					}
					return;
				}
			}

		}
		
		revert();
	}
	
	//user withdraw equal ETH of Dividend ZGT
	function withdrawDividendZGTInETH(uint256 withdrawAmount) public {
		require(withdrawAmount>0);
		require(withdrawEnabled);
		
		if (withdrawAmount >= 1) {
			if (!isAllowHugeWithdraw(msg.sender)) {
				revert();
				return;
			}
		}
		
		uint256 zgt2eth = DividendShareList[msg.sender].div(RATEOFZOLAX);
		uint256 ethWithDecimal = withdrawAmount.mul(10 ** uint256(DECIMAL));
		if (zgt2eth >= ethWithDecimal) {
			    msg.sender.transfer(ethWithDecimal);
				uint256 restETHValue = zgt2eth.sub(ethWithDecimal);
				uint256 eth2zgt = restETHValue.mul(RATEOFZOLAX);
				if (eth2zgt > 0) {
					DividendShareList[msg.sender] = eth2zgt;
				} else {
					delete DividendShareList[msg.sender];
				}
			
		}
		revert();
	}


	
	//deposit or sale zgt to zolax
	function executeOnTokenTransfered(address player, uint256 token2Transfer, string str1, string str2, uint256 data1, uint256 data2) public returns (bool) {
		require(msg.sender == ZGTTokenAddress);
		require(token2Transfer > 0);

		str1 = "";
		str2 = "";
		data1 = 0;

		if (data2 == 1) {//deposit
			ZGTDepositBalance[msg.sender] += token2Transfer;
			return true;
		} else if (data2 == 2) {//sale
			return saleZGT(player, token2Transfer);
		} else {
			revert();
		}
		return false;
	}

	//sale zgt back
	function saleZGT(address player, uint256 token2Sale) internal returns (bool) {
		require(player != 0x0);
		require(token2Sale > 0);
		require(exchangeEnabled);
		
		uint256 ethValue = token2Sale.div(RATEOFZOLAX);
		if (address(this).balance >= ethValue) {
			player.transfer(ethValue);
			outsideZGT -= token2Sale;
			return true;
		}
		return false;
	}
	
	//owner add deposit info of the player
	function addDepositZGTManually(uint256 amount, address player) public onlyOwner {
		require(amount > 0);
		require(player != 0x0);
		ZGTDepositBalance[player] = ZGTDepositBalance[player].add(amount.mul(10 ** uint256(DECIMAL)));
	}
	
	//get deposit of player
	function getDepositBalance(address player) view public returns (uint256) {
		return ZGTDepositBalance[player];
	}
	
	//decrease deposit after deposit is used
	function decreaseDeposit(address player, uint256 amount) public {
		require(amount > 0);
		require(ZGTDepositBalance[player] >= amount);
		
		if (!isValidSender(msg.sender)) {
			revert();
		}
		
		ZGTDepositBalance[player] = ZGTDepositBalance[player].sub(amount);
		if (ZGTDepositBalance[player] == 0) {
			delete ZGTDepositBalance[player];
		}
	}

	//decrease won zgt after it is used
	function decreaseWonZGTBalance(address player, uint256 amount) public {
		require(amount > 0);
		require(Winbalances[player] >= amount);
		
		if (!isValidSender(msg.sender)) {
			revert();
		}
		
		Winbalances[player] = Winbalances[player].sub(amount);
		if (Winbalances[player] == 0) {
			delete Winbalances[player];
		}
	}
	
	//decrease dividend zgt balance after it is used
	function decreaseDividendZGTBalance(address player, uint256 amount) public {
		require(amount > 0);
		require(DividendShareList[player] >= amount);
		
		if (!isValidSender(msg.sender)) {
			revert();
		}
		
		DividendShareList[player] = DividendShareList[player].sub(amount);
		if (DividendShareList[player] == 0) {
			delete DividendShareList[player];
		}
	}
	
	function getWinBalance(address player) view public returns (uint256) {
		require(player != 0x0);
		return Winbalances[player];
	}
	
	//called by game contract
	function addProfit(uint256 amount)  public {
		require(amount > 0);
		if (!isValidSender(msg.sender)) {
			revert();
		}
		totalProfit = totalProfit.add(amount);
	}
	
	function addDonation(uint256 amount)  public {
		require(amount > 0);
		if (!isValidSender(msg.sender)) {
			revert();
		}
		totalDonation = totalDonation.add(amount);
	}
	
	//validate game sender
	function isValidSender(address sender)view internal returns (bool){
		require(sender != 0x0);
		for(uint i=0;i<gamelist.length;i++) {
			if(gamelist[i] == sender) {
				return true;
			}
		}
		return false;
	}
	
	function addWinnerInfo(address player, uint256 amount) public {
		require(player != 0x0);
		require(amount > 0);
		if (!isValidSender(msg.sender)) {
			revert();
		}
		Winbalances[player] = Winbalances[player].add(amount);
	}
	
	function addGame(address gameaddress) public onlyOwner {
		require(gameaddress != 0x0);
		for(uint i=0;i<gamelist.length;i++) {
			if(gamelist[i] == gameaddress) {
				return;
			}
		}
		gamelist.push(gameaddress);
	}
	
	function removeGame(address gameaddress) public onlyOwner {
		require(gameaddress != 0x0);
		for(uint i=0;i<gamelist.length;i++) {
			if(gamelist[i] == gameaddress) {
				delete gamelist[i];
				return;
			}
		}
	}
	
	//authroze huge amount withdraw
	function addHugeAmountWithdrawUser(address player) public onlyOwner {
		require(player != 0x0);
		for(uint256 i=0;i<hugeAmountWithdrawAuthrizedPlayer.length;i++) {
			if (hugeAmountWithdrawAuthrizedPlayer[i] == player) {
				return;
			}
		}
		hugeAmountWithdrawAuthrizedPlayer.push(player);
	}
	
	//remove huge withdraw player
	function removeHugeAmountWithdrawUser(address player) public onlyOwner {
		require(player != 0x0);
		for(uint256 i=0;i<hugeAmountWithdrawAuthrizedPlayer.length;i++) {
			if (hugeAmountWithdrawAuthrizedPlayer[i] == player) {
				delete hugeAmountWithdrawAuthrizedPlayer[i];
			}
		}
	}
	
	//check huge amount withdraw user
	function isAllowHugeWithdraw(address player) view public returns (bool){
		for(uint256 i=0;i<hugeAmountWithdrawAuthrizedPlayer.length;i++) {
			if (hugeAmountWithdrawAuthrizedPlayer[i] == player) {
				return true;
			}
		}
		return false;
	}
}