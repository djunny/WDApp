$(document).ready(function(){
	//external object has all native method
	var $e = window.external;
	console.log($e);
	if(!$e.windowMin){
		//no in WDApp
		$e = {
			windowMin : function(){},
			windowMax : function(){},
			windowClose : function(){},
			windowMove : function(){},
			windowColor : function(htmlColor){},
			windowResize : function(width,height,inScreenCenter){}
		}
	}
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
	
	$('.caption').on('dblclick', function(){
		console.log('caption was dblclick', event);
		$e.windowMax();
	});
	
	var lastMouseDown = 0;
	$('.caption,.title').on('mousedown', function(event){
		if($(event.target).hasClass('caption')
			|| $(event.target).hasClass('title') ){
			var nowTime = (new Date()).getTime();
			//Move window
			if(nowTime - lastMouseDown > 400){
				console.log('caption was mousedown'+(nowTime - lastMouseDown), event);
				$e.windowMove();
			}else{
				//dblclick can MAXIMIZE or RESTORE window
				console.log('caption was dblclick'+(nowTime - lastMouseDown), event);
				$e.windowMax();
			}
			lastMouseDown = nowTime;
			event.stopPropagation();
			return false;
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
	
	//binding caption button action
	$('.caption *[data-act]').on('click', function(){
		var act = $(this).data('act');
		switch(act){
			case 'home':
			case 'demo':
				$('#content').load('include/'+act+'.htm');
			break;
			case 'toggleSkin':
				//toggle skin
				$('.window').toggleClass('flat');
				//reset border color
				$e.windowColor(colorToHex($('.window').css('borderLeftColor')));
			break;
		}
	}).eq(0).trigger('click');
});