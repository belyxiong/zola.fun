

var NETWORK2USE = "4";//1 : main, 4 : rinkeby
var DECIMAL = 1000000000000000000;
var toFixedPrecisis = 2;

var myEthBalance = 0;
var myZSTBalance = 0;
var myZGTBalance = 0;
var myWonZGTBalance = 0;
var mywonbalance = 0;
var soldZSTAmount = 0;
var curaddress;

init = function () {
  if (typeof web3 !== 'undefined') {
    console.log('Web3 found');
    web3 = new Web3(web3.currentProvider);
	detectNetwork();
  } else {
     console.error('web3 was undefined');
	 alert("Please install metamask and unlock account.");
  }
}




function detectNetwork() {
web3.version.getNetwork((err, netId) => {
	if (netId != NETWORK2USE) {
	  //alert(msg);
	  onNetworkError();
	} else {
		getCurrentAccount();
	}

});
}


function getCurrentAccount() {
	web3.eth.getAccounts(function(error, result) {
    if(error != null) {
        console.log("Couldn't get accounts");
		alert("WOW, some unknown errors happens.");
	} else {
		curaddress = result[0];
		console.log("curaddress->"+curaddress);
		web3.eth.defaultAccount = curaddress;
		if (curaddress != 'undefined') {
			var strAddress = new String(curaddress);
			console.log("strAddress->"+strAddress);
			if ((strAddress.indexOf("0x") >=0 || strAddress.indexOf("0X") >=0) &&(strAddress.length>20)) {
				console.log("strAddress-2>"+strAddress);
				getAccountBalances(curaddress);
			} else {
				alert("Please unlock account.");
				curaddress = "<b style='color:red'>please unlock account.</b>";
				showBalances();
			}
		} else {
			alert("Did you unlock your account?");
		}
	}
   });
}



function setETHBalance(eth_balance) {
	myEthBalance = eth_balance;
	showBalances();
}
	
function setZSTBalance(zst_balance) {
	myZSTBalance = zst_balance;
	showBalances();
}

function setZGTBalance(zgt_balance) {
	myZGTBalance = zgt_balance;
	showBalances();
}

function setWonZGT(zgt_won) {
	myWonZGTBalance = zgt_won;
	showBalances();
}



function setSoldZSTAmount(amount) {
	soldZSTAmount = amount;
	showBalances();
}

function showBalances() {
	var ethstr = "<b>Your address:"+curaddress+"</b><br>ETH:"+myEthBalance;
	var zststr = "<br>ZST:"+myZSTBalance;
	if (parseFloat(soldZSTAmount) > 0) {
		propotion = (parseFloat(myZSTBalance) * 100)/(parseFloat(soldZSTAmount));
		propotion = propotion.toFixed(toFixedPrecisis);
		zststr += "&nbsp;&nbsp;&nbsp;("+propotion+"% of sold ZST("+soldZSTAmount+") )";
	}
	var zgtstr = "<br>ZGT:"+myZGTBalance + "&nbsp;&nbsp;<a href='buysalezgt.html'><u>Sale/Buy</u></a>";

	var zgtwonstr = "<br>ZGT Won:"+myWonZGTBalance;
	if (myWonZGTBalance>0) {
		zgtwonstr += "&nbsp;&nbsp;<a href='javascript:withdraw();'>Withdraw</a>&nbsp;&nbsp;<a href='javascript:withdraw();'>WithdrawETH</a>&nbsp;&nbsp;<a href='javascript:withdraw();'>Deposit</a>";
	}


	var content = ethstr + zststr + zgtstr + zgtwonstr;
	//alert(content);
	$("#balances").html(content);
	$("#ethaddress").val(curaddress);
}

function getAccountBalances(address) {
	initContracts();
	console.log("getBalances->"+address);
	
	web3.eth.getBalance(address, function (error, result){
		console.log("result->"+result);
		if (error == null) {
			var eth = web3.fromWei(result);
			console.log("eth->"+eth);
			setETHBalance(eth);
		} else {
			console.log(error);
		}
	});

	
	zgtToken.balanceOf(address, function (error, result) {
		console.log("zgt->"+result);
		if (error == null) {
			console.log("zgtToken.balanceOf.result="+result);
			console.log(result/DECIMAL);
			var balance = result/DECIMAL;
			myzgtbalance = balance.toFixed(toFixedPrecisis);
			setZGTBalance(myzgtbalance);
		} else {
			console.log(error);
		}
	});

	zstToken.balanceOf(address, function (error, result) {
		console.log("zst->"+result);
		if (error == null) {
			console.log("zstToken.balanceOf.result="+result);
			console.log(result/DECIMAL);
			var balance = result/DECIMAL;
			setZSTBalance(balance.toFixed(toFixedPrecisis));//+'   <a href="invest.html">Buy More</a>');
		} else {
			console.log(error);
		}
	});
	
	zolax.getWinBalance(address, function (error, result) {
		console.log("error->"+error);
		if (error == null) {
			console.log("getWinBalance.result="+result);
			console.log(result/DECIMAL);
			var balance = result/DECIMAL;
			mywonbalance = balance;
			var msg = balance.toFixed(toFixedPrecisis);
			setWonZGT(msg);
		} else {
			console.log(error);
		}
    });



	zstsaleimpl.getSoldTokenAmount(function (error, result) {
		console.log("error->"+error);
		if (error == null) {
			console.log("getSoldTokenAmount.result="+result);
			console.log(result/DECIMAL);
			var balance = result/DECIMAL;
			soldZSTAmount = balance;
			var msg = soldZSTAmount.toFixed(toFixedPrecisis);
			setSoldZSTAmount(msg);
		} else {
			console.log(error);
		}
    });
}