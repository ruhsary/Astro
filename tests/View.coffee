class View
	constructor:(container)->
		@handlers = {'translate': null}
		@mouseState = 0; #0 = none, 1 = down  2 = up
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
		@imageRequestManager()
		click = ()=>
			@display();
			setTimeout(click, 1000);
		click();
	###
	translate
	Translates X degrees, Y Degrees.
	Not pixels! Degrees! Going translate(0,1) is a full degree, which is 2 images.
	
	Triggers: 'translate' event
	###
	translate:(x,y)=>
		@position.x += x
		@position.y += y
		@notify('translate', @position)
	###
	display:
		will send requests to all obvservers asking them to draw their
		images if they have any.
	###
	display:()=>
		@ctx.save()
		@ctx.clearRect(0,0,@canvas.width,@canvas.height);
		@ctx.translate(@position.x / .512*1024, -@position.y / .512*1024)
		i = @range.lowX
		while(i <= @range.highX)
			j = @range.lowY
			while(j < @range.highY)
				for overlay in @observers
					overlay.update("display", {x:i,y:j, ctx:@ctx})			
				j++
			i++
		@ctx.restore();
	attach:(observer)->
		@observers.push(observer)
		@updateState(observer)
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
		console.log("rangeX: #{rangeX}  X-range:{#{@range.lowX}-#{@range.highX}} Y-range:{#{@range.lowY}-#{@range.highY}} Position: (#{@position.x}, #{@position.y})")

		if @range.lowX < 0 then @range.lowX = 0
		i = @range.lowX
		while(i <= @range.highX)
			j = @range.lowY
			while(j <= @range.highY)
				if(@map[i]? and @map[i][j])
					j++
					continue
				else
					for overlay in @observers
						overlay.update('request', {x:i , y:j})
					if @map[i]?
						@map[i][j] = true
					else
						@map[i] = {}
						@map[i][j] = true 
				j++
			i++
		@display()
	updateState:(observer)->
		for i of @map
			for j of @map[i]
				observer.update('request', {x:i, y:j})
	mouseHandler:(canvas)->
		$(canvas).mousedown(@panDown)
		$(canvas).mouseup(@panUp)
		$(canvas).mousemove(@panMove)
	panDown:(event)=>
		@mouseState = 1
		@mouseCoords.x = event.clientX
		@mouseCoords.y = event.clientY
	panMove: (event)=>
		if(@mouseState == 1)
			@translate((event.clientX-@mouseCoords.x)/1000, (-event.clientY+@mouseCoords.y)/1000)
			@mouseCoords.x = event.clientX
			@mouseCoords.y = event.clientY
	panUp: (event)=>
		@mouseState = 0