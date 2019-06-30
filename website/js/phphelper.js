var zgtOnHold = 0;

insertRequest = function (player, gameid, betcontent, multiple, stat) {
	console.log("recording bet2...");
	$.post(
			"php/framework/api.php",
				 {action: "additem", player:player, gameid:gameid, betcontent:betcontent, multiple:multiple, stat:stat},
				 function (data) {

				 }
	);

}

//check how many zgt is hold for the player
checkDepositOnHold = function(player0) {
	$.post(
		"php/framework/api.php",
		{action:"checkHold", player:player0},
		function(data) {
			console.log("onhold="+data);
			zgtOnHold = parseInt(data);
//			alert(zgtOnHold);
			if (zgtOnHold > 0 && myDepositZGT >= zgtOnHold) {
				myDepositZGT -= zgtOnHold;
				showBalances();
			}
		}
	);
}

//after the bet is made thru deposit, change record as finished in db
deleteBetRequest = function(player, _id) {
	$.post(
			"php/framework/api.php",
			 {action: "removeBetRequest", id:_id},
			 function (data) {
				alert(data);
			 }
	);
}

//show all bet request
queryBetRequest = function (cb) {
	$.ajax({
		url: "php/framework/api.php?action=queryBetRequest",
		dataType: 'json',
		success: function(data) {
			var html = '';
			if (data && data.length > 0) {
				html = betTableRenderer(data);
			}
			$("#betrequestcontent").html(html);
			cb && cb();
		}
	});
}

betTableRenderer = function(data) {
	var table = "<table class='betinfo-table table table-bordered number-table' border='1'>"
		+"<tr><th>Player</th>"
		+"<th>Total Cost</th>"
		+"<th>Betinfo</th>"
		+"<th>Status</th>"
		+"<th>TX</th>"
		+"<th>Deposit balance</th>"
		+"<th>Action</th></tr>";
	var nd, gameinfo;
	for(var i in data) {
		nd = data[i];
		gameinfo = [];
		for(var k in nd.game) {
			gameinfo.push(nd.game[k].team1
				+' vs '
				+nd.game[k].team2
				+'<br>team1 win'
				+'<br>'+nd.game[k].multiple
				+'X<br>'
				+nd.game[k].time
				+"<br>");
		}
		table += "<tr><td>"+nd.player+"</td>"
			+"<td>"+nd.total_cost+"</td>"
			+"<td>"+gameinfo.join('<br>')+"</td>"
			+"<td>Not handled</td>"
			+"<td>NA</td>"
			+"<td><input value='"+nd.player+"' readonly disabled=\"disabled\"><Button class='check' onclick='checkbet(this);'>Check</Button></td>"
			+"<td><Button onclick=\"placeBet('"+nd.gameinfo+"');\">PlaceBet</Button></td></tr>";
	}
	table += "</table>";
	return table;
}
