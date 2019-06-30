//main network
var zgtaddress_main = "";
var zstaddress_main = "";
var worldcupaddress_main = "";
var zolaxaddress_main = "";
var stocklotteryaddress_main = "";
var lastwinneraddress_main = "";
var zstsaleaddressimpl_main = "";


//rinkeby
var zgtaddress_test = "0xa99CCb1dCf167b05680e7B9Ac39EfE9a76Ed8158";
var zstaddress_test = "0x27d95406658120096768172621c4C6F3CF33861d";
var worldcupaddress_test = "0x1cfB9eEb61715944F58c377bC3083BfF138517E3";
var zolaxaddress_test = "0xff3d5cc0eB37aE238AA009A88415DDa621DD1Da5";
var stocklotteryaddress_test = "";
var lastwinneraddress_test = "0xB44548fA831362d1AB623a1D12dd3c3cdCFda1Cb";
var zstsaleaddressimpl_test = "0x2cC6f34B1500b36cBCe602B4b06CFA75119A64c1";




var USINGTEST = true;

var zgtaddress = USINGTEST ? zgtaddress_test : zgtaddress_main;
var zstaddress = USINGTEST ? zstaddress_test : zstaddress_main;
var worldcupaddress = USINGTEST ? worldcupaddress_test : worldcupaddress_main;
var zolaxaddress = USINGTEST ? zolaxaddress_test : zolaxaddress_main;
var stocklotteryaddress = USINGTEST ? stocklotteryaddress_test : stocklotteryaddress_main;
var lastwinneraddress = USINGTEST ? lastwinneraddress_test : lastwinneraddress_main;
var zstsaleaddressimpl = USINGTEST ? zstsaleaddressimpl_test : zstsaleaddressimpl_main;

var zgtToken;
var zstToken;
var worldcup;
var zolax;
var stocklottery;
var contract_lastwinner;
var zstsaleimpl;

initContracts = function () {
	zgtToken = web3.eth.contract(abi_zgt).at(zgtaddress);
	zstToken = web3.eth.contract(abi_zst).at(zstaddress);

	zolax = web3.eth.contract(abi_zolax).at(zolaxaddress);
	contract_lastwinner = web3.eth.contract(abi_lastwinner).at(lastwinneraddress);
	zstsaleimpl = web3.eth.contract(abi_zstsaleimpl).at(zstsaleaddressimpl);
}

getZolaXContract = function() {
	return web3.eth.contract(abi_zolax).at(zolaxaddress);
}

getZstSaleContract = function() {
	return web3.eth.contract(abi_zstsaleimpl).at(zstsaleaddressimpl);
}

getStayToLastContract = function() {
	return web3.eth.contract(abi_lastwinner).at(lastwinneraddress);
}

getZstSaleImplContract = function() {
	return web3.eth.contract(abi_zstsaleimpl).at(zstsaleaddressimpl);
}

getZSTContract = function() {
	return web3.eth.contract(abi_zst).at(zstaddress);
}

getZGTContract = function() {
	return web3.eth.contract(abi_zgt).at(zgtaddress);
}