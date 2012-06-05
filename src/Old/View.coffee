class View
	constructor:(container)->
		@handlers = {'translate': null, 'scale':null, 'box':null}
		@mouseStateUp = @panUp
		@state = 0
		@mouseStateDown = @panDown
		@mouseStateMove = @panMove
		@mouseCoords = {x:0, y:0}
		@canvas = document.createElement("canvas")
		@canvas.width = container.clientWidth
		@canvas.height = container.clientHeight;
		@canvas.style.backgroundColor = "rgb(0,0,0)";
		@map = {};
		@mouseHandler(@canvas)
		@ctx = @canvas.getContext('2d')
		@ctx.globalCompositeOperation = "lighter";
		container.appendChild(@canvas)
		@observers = []
		@position =  {x:0.0, y:0.0} #Position in degree plane
		@pixelTranslation = {x: @canvas.width/2, y:@canvas.height/2}
		@scale = 1.8
		@range = {lowX: 0, lowY:0, highX: 0, highY:0};
		@register('translate', @imageRequestManager)
		@register('box', @cleanBox)
		@imageRequestManager()
		@box = new BoxOverlay(@canvas, this)
		click = ()=>
			@display();
			setTimeout(click, 1000);
		click();
	###
	translate
	Translates X degrees, Y Degrees.
	Not pixels! Degrees! Going translate(0,1) is a full degree, which is 2 images.
	Compounds each translate
	Triggers: 'translate' event
	###
	translate:(x,y)=>
		@position.x += x
		@position.y -= y
		@notify('translate', @position)
	jump:(x,y)=>
		@position.x = x
		@position.y = y
		@notify('translate', @position)
	addScale:(addScale)=>
		@scale += addScale
		@notify('scale', @scale)
		@display()
	setScale:(newScale)=>
		@scale = newScale
		@notify('scale', @scale)
		@display()
	setState:(newState)=>
		@state = newState
		@unhookEvent(@canvas, "mousedown", @mouseStateDown)
		@unhookEvent(@canvas, "mouseup", @mouseStateUp)
		@unhookEvent(@canvas, "mousemove", @mouseStateMove)
		@unhookEvent(@canvas, "mousewheel", @mousewheel)
		if(newState == 1)
			@box.setEvents()
		else
			@mouseStateUp = @panUp
			@mouseStateDown = @panDown
			@mouseStateMove = @panMove
			@hookEvent(@canvas, "mousedown", @mouseStateDown)
			@hookEvent(@canvas, "mouseup", @mouseStateUp)
			@hookEvent(@canvas, "mousemove", @mouseStateMove)
			@hookEvent(@canvas, "mousewheel", @mousewheel)
	display:()=>
		@ctx.save()
		@ctx.clearRect(0,0,@canvas.width,@canvas.height);
		@ctx.translate(@pixelTranslation.x, @pixelTranslation.y)
		zoom = 1.8/@scale;
		@ctx.translate(-512*zoom, -512*zoom)
		@ctx.translate(@position.x / .512*1024*zoom, @position.y / .512*1024*zoom)
		@ctx.scale(zoom, zoom)
		i = @range.lowX
		while(i <= @range.highX)
			j = @range.lowY
			while(j < @range.highY)
				for overlay in @observers
					overlay.update("display", {x:i,y:j, ctx:@ctx})			
				j++
			i++
		@ctx.restore();
		if(@state == 1)
			@box.display()
	attach:(observer)->
		@observers.push(observer)
		@updateState(observer)
	detach:(observer)->
		for overlay in @observers
			if(overlay == observer)
				overlay.setAlpha(0)
				overlay = null
				break
	register:(type, callback)=>
		oldLoaded = @handlers[type]
		if(@handlers[type])
			@handlers[type] = (view)->
				if(oldLoaded)
					oldLoaded(view)
				callback(view)
		else
			@handlers[type] = callback
	notify:(type, info)=>
		if(@handlers[type])
			@handlers[type](info);
	getCoordinate:(x,y)->
		#Assertion: Stuff must be in there!
		if(!(@pixelTranslation.x? and @pixelTranslation.y? and @position.x? and @position.y?))
		    return null
		pixelWidth = x - @pixelTranslation.x
		pixelHeight = @pixelTranslation.y - y
		###Pixels*arcsec/pixel = arcsec per difference. 1 degree = 3600 arcseconds###
		degreeWidth = pixelWidth*@scale/3600.0
		degreeHeight = pixelHeight*@scale/3600.0
		degreePoint = {'x':(@position.x - degreeWidth), 'y':(@position.y + degreeHeight)}
		return degreePoint
	getBoundingBox:()=>
		rangeX = @canvas.width*@scale/3600.0 #3600 arcsecs per degree and half the width  = 7200
		rangeY = @canvas.height*@scale/3600.0
		@range.maxRA = Math.ceil((@position.x + rangeX)/.512)
		@range.minRA = Math.floor((@position.x - rangeX)/.512)
		@range.maxDec = Math.ceil((@position.y + rangeY)/.512)
		@range.minDec = Math.floor((@position.y - rangeY)/.512)
		console.log @range
		return range
	###
	Function: imageRequestManager
	Use: Private function to manage translation and requesting images.
	Hooked on construction to the translate event handler
	###
	imageRequestManager:()=>
		# TODO: Push update of scale into another function so it doesn't recalculate so much
		rangeX = @canvas.width*@scale/3600.0*2 #3600 arcsecs per degree and half the width  = 7200
		rangeY = @canvas.height*@scale/3600.0*2
		@range.highX = Math.ceil((@position.x + rangeX)/.512)
		@range.lowX = Math.floor((@position.x - rangeX)/.512)
		@range.highY = Math.ceil((@position.y + rangeY)/.512)
		@range.lowY = Math.floor((@position.y - rangeY)/.512)
		
		if @range.lowX < 0 then @range.lowX = 0
		j = @range.highY		
		while(j >= @range.lowY)
			i = @range.lowX
			Mx = 0
			while(i <= @range.highX)
				if(@map[i]? and @map[i][j])
					i++
					continue
				else
					if(Mx == 0)
						yp = j*0.512
						
						spacing = 0.512/Math.cos(yp*Math.PI/180.0)
						Mx = Math.round(i*0.512/spacing)
						
						xp = Mx * spacing
												
					else
						Mx++
						xp = Mx * spacing
						
					for overlay in @observers
						overlay.update('request', {x:i , y:j, RA:xp, Dec:yp})
					if @map[i]?
						@map[i][j] = true
					else
						@map[i] = {}
						@map[i][j] = true 
				i++
			j--
		@display()
	cleanBox: ()=>
		@box.enabled = true
		@setState(0)
	updateState:(observer)->
		for i of @map
			Mx = 0
			for j of @map[i]
				
				if(Mx == 0)
					yp = j*0.512
					
					spacing = 0.512/Math.cos(yp*Math.PI/180.0)
					Mx = Math.ceil(i*0.512/spacing)
					
					xp = Mx * spacing
										
				else
					Mx++
					xp = Mx * spacing
			
				observer.update('request', {x:i, y:j, RA:xp, Dec:yp})
				
	mouseHandler:(canvas)->
		@hookEvent(canvas, "mousedown", @panDown)
		@hookEvent(canvas, "mouseup", @panUp)
		@hookEvent(canvas, "mousewheel", @panScroll)
		@hookEvent(canvas, "mousemove", @panMove)
		@mouseStateUp = @panUp
		@mouseStateDown = @panDown
		@mouseStateMove = @panMove
	panDown:(event)=>
		@mouseState = 1
		@mouseCoords.x = event.clientX
		@mouseCoords.y = event.clientY
	panMove: (event)=>
		if(@mouseState == 1)
			@translate((event.clientX-@mouseCoords.x)/ 1000 * 1.8 / @scale, (-event.clientY+@mouseCoords.y)/ 1000 * 1.8 / @scale)
			@mouseCoords.x = event.clientX
			@mouseCoords.y = event.clientY
	panUp: (event)=>
		@mouseState = 0
		@imageRequestManager()
	panScroll: (event)=>
		delta = 0;
		if (!event) 
			event = window.event;
		#normalize the delta
		if (event.wheelDelta)
			#IE and Opera
			delta = event.wheelDelta / 60;
		else if (event.detail) 
			delta = -event.detail / 2;
		if(delta > 0 and @scale >= 1.8)
			@addScale(-.3)
		else if(delta <= 0)
			@addScale(.3)
		@imageRequestManager()
	hookEvent:(element, eventName, callback)->
		if(typeof(element) == "string")
			element = document.getElementById(element);
		if(element == null)
			return;
		if(element.addEventListener)
			if(eventName == 'mousewheel')
				element.addEventListener('DOMMouseScroll', callback, false);  
			element.addEventListener(eventName, callback, false);
		else if(element.attachEvent)
			element.attachEvent("on" + eventName, callback);
	unhookEvent:(element, eventName, callback)->
		if(typeof(element) == "string")
			element = document.getElementById(element);
		if(element == null)
			return;
		if(element.removeEventListener)
			if(eventName == 'mousewheel')
				element.removeEventListener('DOMMouseScroll', callback, false);  
			element.removeEventListener(eventName, callback, false);
		else if(element.detachEvent)
			element.detachEvent("on" + eventName, callback);
class BoxOverlay
	constructor: (canvas, view)->
		@canvas = canvas
		@ctx = @canvas.getContext('2d')
		@ctx.fillStyle = "rgba(0,0,200,.5)"
		@start = 0
		@draw = false
		@enabled = true
		@end = 0
		@view= view
		@onBox = null
		@canvas.relMouseCoords = (event)->
			totalOffsetX = 0
			totalOffsetY = 0
			canvasX = 0
			canvasY = 0
			currentElement = this
			while currentElement = currentElement.offsetParent
				totalOffsetX += currentElement.offsetLeft
				totalOffsetY += currentElement.offsetTop
			canvasX = event.pageX - totalOffsetX
			canvasY = event.pageY - totalOffsetY
			return {x:canvasX, y:canvasY}
		@boxdown =(event)=>
			if(!@enabled)
				return
			@start = @canvas.relMouseCoords(event)
			@draw = true
		@boxmove =(event)=>
			if(@draw and @enabled)
				@end = @canvas.relMouseCoords(event)
				@view.display()
		@boxup = (event)=>
			if(!@enabled)
				return
			@end = @canvas.relMouseCoords(event)
			@view.notify('box', {start: @view.getCoordinate(@start.x, @start.y), end:@view.getCoordinate(@end.x, @end.y)})
			@enabled = false
			drawEnd = ()-> @draw = false; 
			setTimeout(drawEnd, 1000)
	setEvents:()->
		@view.mouseStateUp = @boxup
		@view.mouseStateDown = @boxdown
		@view.mouseStateMove = @boxmove
		View::hookEvent(@canvas, "mousedown", @boxdown)
		View::hookEvent(@canvas, "mouseup", @boxup)
		View::hookEvent(@canvas, "mousemove", @boxmove)
	display:()->
		if @draw
			@ctx.fillRect(@start.x, @start.y, @end.x-@start.x, @end.y-@start.y);
