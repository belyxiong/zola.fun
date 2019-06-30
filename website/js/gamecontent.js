
var AllGameInfo;
var extraList;
loadGameInfo = function() {
	Len_Gamelist = 0;
	var gamelen = 0;
	var index = 0;
	initContracts();
	worldcup.getAllGameLen( function (error, result) {
		console.log("error->"+error+",reseult="+result);
		if (error == null) {
			gamelen = parseInt(result);
			if (gamelen>0) {
				Len_Gamelist = gamelen;
				extraList = new Array();
				for (index=0;index<gamelen;index++){
					//game id
					worldcup.getGameExtra(index, function (error, result) {
						if (error == null) {
							extraList.push(result);
							if (index>=Len_Gamelist-1) {
								checkNcomposeGameList();
							}
						}
					});
				}
			}
		} else {
			console.log(error);
		}
    });
	$("#gameid").val("");
}

function checkNcomposeGameList() {

	if (Len_Gamelist > 0) {

		AllGameInfo = new Array();
		
		for(index=0;index<Len_Gamelist;index++) {
			extra = extraList[index];
			obj = JSON.parse(extra);
		
			item = new Object();
			item.gameid = obj.gameid;
			item.matchTime = obj.matchtime;
			item.deadline = obj.deadline;
			item.team1 = obj.team1;
			item.team2 = obj.team2;
			item.expired = 0;
			AllGameInfo.push(item);
		}
		showGameList();
	}
}

showGameList = function() {

	content = '<p style="color:white" >Select a game to bet</p><select id="gameselector" class="form-control col-lg-12" onchange="updateGameArea()">';
	for(i=0;i<AllGameInfo.length;i++) {
		content += '<option value="'+AllGameInfo[i].gameid+'"';
//		if (obj.gameinfo[i].expired == 1) {
//			content += '" disabled=disabled"';
//		}
		content += '>'+AllGameInfo[i].gameid+"&nbsp;&nbsp;&nbsp;&nbsp;"+AllGameInfo[i].matchTime+'&nbsp;&nbsp;&nbsp;&nbsp;'+AllGameInfo[i].team1+'&nbsp;&nbsp;--&nbsp;&nbsp;'+AllGameInfo[i].team2;
		if (AllGameInfo[i].expired == 1) {
			content += "&nbsp;&nbsp;--&nbsp;&nbsp;Expired"
		} else {
			content += '</option>';
		}
	}
												  
	content += '</select><br><br><br>';

	$("#gamelist").html(content);

}