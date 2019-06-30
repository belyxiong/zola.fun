Date.prototype.getUnixTime = function()
{
	return Math.floor((this.getTime() / 1000) | 0);
};

function calcNextEpochTime(currentTime, start, length)
{
	return (start + Math.floor((currentTime - start + length) / length) * length);
}

var EPOCH_START_1 = new Date("February 13, 2018 20:00:00 UTC").getUnixTime();
var EPOCH_START_2 = new Date("February 13, 2018 20:00:00 UTC").getUnixTime();
var EPOCH_LENGTH_1 = 60 * 60 * 24; // 24h
var EPOCH_LENGTH_2 = 60 * 60 * 24 * 7; // 7 days

var currentTime = new Date().getUnixTime();
var roundTimer1 = calcNextEpochTime(currentTime, EPOCH_START_1, EPOCH_LENGTH_1);
var roundTimer2 = calcNextEpochTime(currentTime, EPOCH_START_2, EPOCH_LENGTH_2);
$('#roundtimer1').countdown({until: new Date(roundTimer1 * 1000), timeSeparator: ':', padZeroes: true});
$('#roundtimer2').countdown({until: new Date(roundTimer2 * 1000), timeSeparator: ':', padZeroes: true});
