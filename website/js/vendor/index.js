$(document).ready(function (){
	$('#switch-numbers a').click(function (){
		var btnTarget = $(this).attr('data-target');
		$(this).addClass('active-btn').siblings('a').removeClass('active-btn');
		$("."+btnTarget).show().siblings('.game-park').hide();
	})
})