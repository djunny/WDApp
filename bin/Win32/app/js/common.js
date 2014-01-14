$(document).ready(function(){
	//external object has all native method
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
	$('.btn-max').on('click', function(){
		$e.windowMax();
	});
	$('.btn-min').on('click', function(){
		$e.windowMin();
	});
	$('.btn-close').on('click', function(){
		$e.windowClose();
	});
	//dblclick can MAXIMIZE or RESTORE window
	$('.caption').on('dblclick', function(){
		$e.windowMax();
	});
	
	//caption can move
	$('.caption,.title').on('mousedown', function(event){
		if($(event.target).hasClass('caption')
			|| $(event.target).hasClass('title') ){
			$e.windowMove();
			return true;
		}
	});
	
	//onmousedown border can move window
	$('.container').on('mousedown', function(event){
		var borderLeftWidth = parseInt($('.window').css('borderLeftWidth'), 10),
		borderTopWidth = parseInt($('.window').css('borderTopWidth'), 10),
		captionHeight = parseInt($('.caption').css('height'), 10)+borderTopWidth,
		containerWidth = parseInt($('.content').outerWidth(), 10)+borderLeftWidth,
		containerHeight = parseInt($('.content').outerHeight(), 10) + captionHeight,
		canMove = false;
		if(event.pageY > containerHeight){
			//bottom
			canMove = true;
		}else if(event.pageY >= captionHeight ){
			if(event.pageX < borderLeftWidth ){
				//left
				canMove = true;
			}else if (event.pageX > containerWidth){
				//right
				canMove = true;
			}
		}
		if(canMove){
			$e.windowMove();
			return true;
		}
		return false;
	});
	
	function colorToHex(color) {
		if (color.substr(0, 1) === '#') {
			return color;
		}
		var digits = /(.*?)rgb\((\d+), (\d+), (\d+)\)/.exec(color);
	
		var red = parseInt(digits[2]);
		var green = parseInt(digits[3]);
		var blue = parseInt(digits[4]);
	
		var rgb = blue | (green << 8) | (red << 16);
		return digits[1] + '#' + rgb.toString(16);
	};
	
	//window has 1px border(resize) must set color;
	$e.windowColor(colorToHex($('.window').css('borderLeftColor')));
	//window resize and set in screen center
	$e.windowResize(760, 300, true);
	
	
	$("#wd-phrases > h2").lettering('words').children("span").lettering().children("span").lettering();
});