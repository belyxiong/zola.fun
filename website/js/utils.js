
var nextDrawTime;// = "Apr 16, 2018 14:30:00";
var CLOSETIME = "14:30:00";
var DRAWTIME = "15:30:00";
var STOCKOPENTIME = "08:30:00";
var drawtime;
var zone;
var gameclosed;


function setNextDrawTime(time) {
	nextDrawTime = time;
}

function prepareDate() {
	var myDate = new Date();
	
	var dayafter=1;
	//skip Saturyday or Sunday
	while (myDate.getDay() == 0 || myDate.getDay() == 6) {
		myDate = GetNextDay(dayafter);
		dayafter++;
	}
	if (myDate.getHours() >=20) {
		myDate = GetNextDay(1);
	}
	
	dayafter=1;
	//skip Saturyday or Sunday
	while (myDate.getDay() == 0 || myDate.getDay() == 6) {
		myDate = GetNextDay(dayafter);
		dayafter++;
	}
	
	var datestr = "";
	datestr += getMonth(myDate.getMonth());
	
	datestr += myDate.getDate() +", "+myDate.getFullYear();
	return datestr;
}

function getMonth(month) {
	var datestr="";
	switch(month) {
		case 0: datestr = "Jan ";
		break;
		case 1: datestr = "Feb ";
		break;
		case 2: datestr = "Mar ";
		break;
		case 3: datestr = "Apr ";
		break;
		case 4: datestr = "May ";
		break;
		case 5: datestr = "Jun ";
		break;
		case 6: datestr = "Jul ";
		break;
		case 7: datestr = "Aug ";
		break;
		case 8: datestr = "Sep ";
		break;
		case 9: datestr = "Oct ";
		break;
		case 10: datestr = "Nov ";
		break;
		case 11: datestr = "Dec ";
		break;
	}
	return datestr;
}

function GetNextDay(dayafter) {
    var dd = new Date();
    dd.setDate(dd.getDate()+dayafter);//获取AddDayCount天后的日期
    var y = dd.getFullYear();
    var m = dd.getMonth()+1;//获取当前月份的日期
    var d = dd.getDate();
    return dd;
}

function startCounter(nextTime) {
	zone = new Date().getTimezoneOffset()/60;
	var offsetseconds = (5- zone ) * 60*60*1000;
	var closetime = nextTime + " " + CLOSETIME;
	drawtime =  nextTime + " " + DRAWTIME;
	var countDownDate = new Date(closetime).getTime();
	var now = new Date().getTime() ;

	var realzone ="+0";
	if (zone >0) {
		realzone = "-"+zone;
	} else if (zone<0) {
		realzone = "+"+Math.abs(zone);
	} else {
		realzone = "+0"
	}

// Update the count down every 1 second
    var x = setInterval(function () {

        // Get todays date and time
		todaydate = new Date();
        now = todaydate.getTime() ;

		
		var yourtime = "Your time : "+getMonth(todaydate.getMonth())+" " + todaydate.getDate() + ", "+todaydate.getFullYear() + " "+todaydate.getHours()+":"+todaydate.getMinutes()+":"+todaydate.getSeconds()+" (UTC"+realzone+")";


        // Find the distance between now an the count down date
        var distance = countDownDate - now + offsetseconds;
		
		if (distance >= 0) {
			// Time calculations for days, hours, minutes and seconds
			var days = Math.floor(distance / (1000 * 60 * 60 * 24));
			var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
			var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
			var seconds = Math.floor((distance % (1000 * 60)) / 1000);

			// Output the result in an element with id="demo"
			$("#countdown_days").text(days);
			$("#countdown_hours").text(hours);
			$("#countdown_minutes").text(minutes);
			$("#countdown_seconds").text(seconds);



			$("#closetime").html("Game Close time :"+closetime+" (UTC-5)");
			$("#drawtime").html("Game Draw time :"+drawtime + " (UTC-5)<br><br>"+yourtime);
			gameclosed = false;

        // If the count down is over, write some text
        } else {
			gameclosed = true;
            clearInterval(x);
			$("#countdown_days").text("-");
			$("#countdown_hours").text("-");
			$("#countdown_minutes").text("-");
			$("#countdown_seconds").text("-");
			
			countDownDate = new Date(drawtime).getTime();
			
			now = new Date().getTime() ;
			
			distance = countDownDate - now + offsetseconds;
			if (distance >= 0) {//between 14:30-15:30
				$("#gamerunning").text("Today game closed");

				$("#closetime").html("Waiting for the winning number to draw.");
				$("#drawtime").html("Draw time :"+drawtime + " (UTC-5)");
				
				document.getElementById("todaywinner").innerHTML ="<b>Coming soon.</b>";
				
			} else { //after 15:30
				$("#gamerunning").text("Today game closed");
				$("#closetime").html("");
				$("#drawtime").html("Next game will be opened after 20:00 (UTC-5)");
			}

        }
    }, 1000);
	
}

function showCountDown() {
//	$.get("./php/date.php?method=getdate", function(data){
//		console.log("data="+data);
//		
//	});
	
	nextDrawTime = prepareDate();
	console.log("nextDrawTime="+nextDrawTime);
	startCounter(nextDrawTime);
	getStockIndexes();
}

var data_dowjones = "";
var data_nasdaq = "";
var data_sp500 ="";

var getstocktimer;
function getStockIndexes() {
	console.log("start timer.");
	zone = new Date().getTimezoneOffset()/60;
	getstocktimer = setInterval(function () {
		getData();
	}, 10000);
	getData();
}

function getData() {
	var offset = (5 - zone) * 60*60*1000;
	var now = new Date().getTime() + offset;
	
	var stockopentime = new Date(nextDrawTime + " " + STOCKOPENTIME).getTime() + offset;

	if (now<stockopentime) {//stock market not opened
		$("#data_dji").text("...");
		$("#data_nasdaq").text("...");
		$("#data_sp500").text("...");
		$("#possiblenumber").html('<b>Waiting for market open.</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="#history">History number</a>');
	} else {
	//dow jones
		$.get("./php/getdata.php?what=dji", function(data){
			console.log("dowjones.data="+data);
			data_dowjones = data;
			
			//nasdaq
			$.get("./php/getdata.php?what=nasdaq", function(data){
				console.log("nasdaq.data="+data);
				data_nasdaq = data;
				
				//s & p 500
				$.get("./php/getdata.php?what=sp500", function(data){
					console.log("sp500.data="+data);
					data_sp500 = data;
					handleIndexes();
				});	
			});
		});
	}
}


function handleIndexes() {
	var num1, num2, num3;
	var indexVal;

	
	if (data_dowjones != "") {
		var firstComma = data_dowjones.indexOf(",");
		console.log("firstComma="+firstComma);
		indexVal = data_dowjones.substring(firstComma+1, data_dowjones.indexOf(",", firstComma+1));
		$("#data_dji").text(indexVal);
		console.log("dj="+indexVal);
		var idx_point = indexVal.indexOf(".");
		num1 = indexVal.substring(idx_point+1, idx_point+2);
	}
	
	if (data_nasdaq != "") {
		var firstComma = data_nasdaq.indexOf(",");
		indexVal = data_nasdaq.substring(firstComma+1, data_nasdaq.indexOf(",", firstComma+1));
		$("#data_nasdaq").text(indexVal);
		console.log("nasdaq="+indexVal);
		var idx_point = indexVal.indexOf(".");
		num2 = indexVal.substring(idx_point+1, idx_point+2);
	}
	
	if (data_sp500 != "") {
		var firstComma = data_sp500.indexOf(",");
		indexVal = data_sp500.substring(firstComma+1, data_sp500.indexOf(",", firstComma+1));
		$("#data_sp500").text(indexVal);
		console.log("sp500="+indexVal);
		var idx_point = indexVal.indexOf(".");
		num3 = indexVal.substring(idx_point+1, idx_point+2);
	}
	
	var countDownDate = new Date(drawtime).getTime();
			
	var now = new Date().getTime();
	
	 
		if ((countDownDate - now + (5 - zone) * 60*60*1000) > 0) {
			$("#possiblenumber").html('<b>Possible winning number : &nbsp;&nbsp;&nbsp;'+num1+'&nbsp;&nbsp;'+num2+'&nbsp;&nbsp;'+num3+'</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="#history">History number</a>');
		} else {
			console.log("stop timer.");
			clearInterval(getstocktimer);
			$("#possiblenumber").html('<b>Today winning number : &nbsp;&nbsp;&nbsp;'+num1+'&nbsp;&nbsp;'+num2+'&nbsp;&nbsp;'+num3+'</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="#todaywinner">Today winner</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="#history">History number</a>');		
		}
	
}