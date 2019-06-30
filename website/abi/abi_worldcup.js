var abi_worldcup = [
	{
		"constant": false,
		"inputs": [
			{
				"name": "admin",
				"type": "address"
			}
		],
		"name": "destroy",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "getGameTeam1Name",
		"outputs": [
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "getPlayerAtBetInfo",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "donationRate",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "player",
				"type": "address"
			},
			{
				"name": "token2Transfer",
				"type": "uint256"
			},
			{
				"name": "str1",
				"type": "string"
			},
			{
				"name": "str2",
				"type": "string"
			},
			{
				"name": "data1",
				"type": "uint256"
			},
			{
				"name": "data2",
				"type": "uint256"
			}
		],
		"name": "executeOnTokenTransfered",
		"outputs": [
			{
				"name": "",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "gid",
				"type": "uint256"
			},
			{
				"name": "t1",
				"type": "string"
			},
			{
				"name": "t2",
				"type": "string"
			}
		],
		"name": "setGameTeamName",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "gameid",
				"type": "uint256"
			},
			{
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "getMultipleMadeOnGameAt",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"name": "admins",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"name": "AllBetInfo",
		"outputs": [
			{
				"name": "player",
				"type": "address"
			},
			{
				"name": "game2Bet",
				"type": "uint256"
			},
			{
				"name": "multiple",
				"type": "uint256"
			},
			{
				"name": "betcontent",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "gameid",
				"type": "uint256"
			},
			{
				"name": "matchtime",
				"type": "string"
			},
			{
				"name": "deadline",
				"type": "uint256"
			},
			{
				"name": "team1",
				"type": "string"
			},
			{
				"name": "team2",
				"type": "string"
			},
			{
				"name": "extra",
				"type": "string"
			}
		],
		"name": "addGame",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "gid",
				"type": "uint256"
			}
		],
		"name": "deleteGame",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "who",
				"type": "address"
			}
		],
		"name": "isAdmin",
		"outputs": [
			{
				"name": "",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "player",
				"type": "address"
			}
		],
		"name": "deleteAdmin",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "getGameidAtBetInfo",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "newaddress",
				"type": "address"
			}
		],
		"name": "setZolaXEntry",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "gameid",
				"type": "uint256"
			}
		],
		"name": "getGamePoolAmount",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "getPlayerLengthOnAllGames",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"name": "AllGames",
		"outputs": [
			{
				"name": "gameid",
				"type": "uint256"
			},
			{
				"name": "team1",
				"type": "string"
			},
			{
				"name": "team2",
				"type": "string"
			},
			{
				"name": "matchtime",
				"type": "string"
			},
			{
				"name": "betDeadline",
				"type": "uint256"
			},
			{
				"name": "totalInPool",
				"type": "uint256"
			},
			{
				"name": "team1winbet",
				"type": "uint256"
			},
			{
				"name": "team2winbet",
				"type": "uint256"
			},
			{
				"name": "drawbet",
				"type": "uint256"
			},
			{
				"name": "extra",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "getMultipleAtBetInfo",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "getGameDeadline",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "getGameMatchTime",
		"outputs": [
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "getGameIDInGameList",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "newzgt",
				"type": "address"
			}
		],
		"name": "changeZGTAddress",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "profitRate",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "getBetContentAtBetInfo",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "player",
				"type": "address"
			}
		],
		"name": "addAdmin",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "getGameTeam2Name",
		"outputs": [
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "gameid",
				"type": "uint256"
			},
			{
				"name": "bet",
				"type": "uint256"
			}
		],
		"name": "getBetDetailsOnGame",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "gid",
				"type": "uint256"
			},
			{
				"name": "deadline",
				"type": "uint256"
			}
		],
		"name": "setGameDeadline",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "gameid",
				"type": "uint256"
			},
			{
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "getPlayerOfGameAt",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "getAllGameLen",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "gameid",
				"type": "uint256"
			}
		],
		"name": "getPlayerLengthOnGame",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "gameid",
				"type": "uint256"
			},
			{
				"name": "bettype",
				"type": "uint256"
			},
			{
				"name": "multi",
				"type": "uint256"
			}
		],
		"name": "getTokenMayWin",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "gameid",
				"type": "uint256"
			},
			{
				"name": "result",
				"type": "uint256"
			}
		],
		"name": "draw",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "player",
				"type": "address"
			},
			{
				"name": "zgtcost",
				"type": "uint256"
			},
			{
				"name": "bet",
				"type": "string"
			}
		],
		"name": "BetUsingDeposit",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "newrate",
				"type": "uint256"
			}
		],
		"name": "changeDonationRate",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "gameid",
				"type": "uint256"
			},
			{
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "getBetContentMadeOnGameAt",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "getGameExtra",
		"outputs": [
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "transferOwnership",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "newrate",
				"type": "uint256"
			}
		],
		"name": "changeProfitRate",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "isGameDeadlinePassed",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	}
];