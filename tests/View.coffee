class View
	constructor:(container)->
		@handlers = {'translate': null}
		@canvas = document.createElement("canvas")
		@canvas.width = container.width
		@canvas.height = container.height
		@ctx = canvas.getContext('2d')
		contrainer.appendChild(@canvas)
		@observers = []
		@position {x:0.0, y:0.0} #Position in degree plane
		@scale = 1.0
	translate:(x,y)=>
		@position.x += x
		@position.y += y
	display:()=>
		@ctx.save()
		@ctx.translate(x)
	attach:(observer)->
		@observers.push(observer)
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
			@handlers[type](this);
