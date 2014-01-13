$(document).ready(function(){
	var $e = window.external;
	//bind onmousedown can move window
	$('*[move-on]').on('mousedown', function(){
		var $target = $(event.target);
		if($target.is('[move-off]') || $target.parents('*[move-off]').length > 0){
			return true;
		}else{
			$e.windowMove();
		}
	});
	//bind window button event
	$('.app-max').on('click', function(){
		$e.windowMax();
	});
	$('.app-min').on('click', function(){
		$e.windowMin();
	});
	$('.app-close').on('click', function(){
		$e.windowClose();
	});
	//dblclick can MAXIMIZE or RESTORE window
	$('.wrapper').on('dblclick', function(){
		$e.windowMax();
	});
	
	//window resize has 1px border to set color;
	$e.windowColor(0);
});