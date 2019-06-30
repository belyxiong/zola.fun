var gameareastr = '<table class="table table-bordered number-table" >' +
				'<thead>' +
					'<tr >' +
			'			<th style="color:white">Game Id</th>' +
			'			<th style="color:white">Time</th>' +
			'			<th style="color:white">Status</th>' +
			'			<th style="color:white">Team1</th>' +
			'			<th style="color:white">Team2</th>' +
			'			<th style="color:white">BetStatus</th>' +
			'			<th  style="color:white" colspan="4" align="center">Make Bet</th>' +
			'		</tr>' +
			'	</thead>' +
			'	<tbody>' +
			'		<tr>' +
			'			<td style="color:white" id="newgameid">GAME_ID</td>' +
			'			<td style="color:white">MATCH_TIME</td>' +
			'			<td style="color:white">GAMESTATUS</td>' +
			'			<td align="center" style="color:white"><img src="images/worldcup/TEAM1_NAME.png" width="50" height="50"><br>TEAM1_NAME</td>' +
			'			<td align="center" style="color:white"><img src="images/worldcup/TEAM2_NAME.png" width="50" height="50"><br>TEAM2_NAME</td>' +
			'			<td style="color:white">TEAM1_NAME Win(<b id="team1value">...</b>)<br>TEAM2_NAME Win(<b id="team2value">...</b>)<br>Draws(<b id="drawsvalue">...</b>)<br>' +
			'			Total In Pool&nbsp;&nbsp;:&nbsp;&nbsp;<b id="totalInPoolValue">...</b>&nbsp;&nbsp;ZGT&nbsp;&nbsp;(&nbsp;&nbsp;<a href="javascript:showpoolinfo();">?</a>&nbsp;&nbsp;)' +
			'			<br><Button class="btn number-check-btn" onclick="javascript:refreshGameStatus();">Refresh</Button></td>' +
			'			<td style="color:white">' +
			'			<input type="radio" name="radiogroup_game0" value="0" checked style="color:white">TEAM1_NAME Win</input><br>' +
			'			<input type="radio" name="radiogroup_game0" value="1" style="color:white">TEAM2_NAME Win</input><br>' +
			'			<input type="radio" name="radiogroup_game0" value="2" style="color:white">Draws</input></td>' +
						
			'			<td><table frame="void" ><tr><td style="color:white">Multiple</td></tr><tr><td>' +
						
			'									<select name="" id="multipleselect_game0" class="form-control col-lg-12" onchange="javascript:updateTokenMayWin();">' +
			'										<option value="valueNone" selected="selected">Please select</option>' +
			'										  <option value="value1">1</option>' +
			'										  <option value="value2">2</option>' +
			'										  <option value="value3">3</option>' +
			'										  <option value="value4">4</option>' +
			'										  <option value="value5">5</option>' +
			'										  <option value="value6">6</option>' +
			'										  <option value="value7">7</option>' +
			'										  <option value="value8">8</option>' +
			'										  <option value="value9">9</option>' +
			'										  <option value="value10">10</option>' +
			'									</select>' +
						
			'			</td></tr></table></td>' +
						
						
						
			'			<td><table frame="void" ><tr><td style="color:white">Token May Win(&nbsp;&nbsp;<a href="javascript:showpoolinfo();">?</a>&nbsp;&nbsp;)</td></tr><tr><td><input disabled="disabled" id="txt_tokenmaywin"></input></td></tr></table></td>' +
			'			<td><Button class="btn number-check-btn" id="btn_addcart" onclick="javascript:addcart();">Add To Cart</Button></td>' +
			'		</tr>' +

			'	</tbody>' +
			'</table>';


getGameString = function (gameid, team1, team2, matchtime, expired) {
	content = gameareastr.replace("GAME_ID", gameid).replace(/TEAM1_NAME/g, team1).replace(/TEAM2_NAME/g, team2).replace(/MATCH_TIME/g, matchtime);
	if (expired == 1) {
		content = content.replace("GAMESTATUS", "Closed");
	} else {
		content = content.replace("GAMESTATUS", "Open");
	}
	return content;
}