pragma solidity ^0.4.18;


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

interface ZSTSaleContract { 
function buyZST(address buyer, uint256 ethValue) external returns (bool);
function getZSTExchangeRate() external returns (uint256);
function getZGTBonusRate() external returns(uint256);
}

contract ZSTSaleEntry1023 is owned {

	ZSTSaleContract zstSaleImpl;
	address public ZSTSaleImplAddress=0x0;
	uint8 public registered = 0;
	uint256 ZGTEXchangeRate = 1000;
	
	constructor() public{
		ZSTSaleImplAddress = 0x08D93eACa46B32385A0f4e9080B6C36422c1C7d0;
		zstSaleImpl = ZSTSaleContract(ZSTSaleImplAddress);
	}
	
	function registerZSTSaleContract(address zstSaleAddress) public onlyOwner{
		require(zstSaleAddress != 0x0);
        zstSaleImpl = ZSTSaleContract(zstSaleAddress);
		ZSTSaleImplAddress = zstSaleAddress;
		registered = 1;
    }

	function() external payable {
		require(ZSTSaleImplAddress != 0x0);
		if (!buyZST(msg.value)) {
			revert();
		}
    }
	
	function buyZST(uint256 value) internal returns (bool){
		return zstSaleImpl.buyZST(msg.sender, value);
	}
	
	function getEth() public onlyOwner {
        owner.transfer(address(this).balance);
    }
	

	
	function destroy() public onlyOwner {
        selfdestruct (owner);
	}
}