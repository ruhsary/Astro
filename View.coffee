class View
	constructor: (canvas3dctx, canvas2dctx)->
		@span = {'RAMin':0 , 'RAMax':.256, 'DecMin':-.256, 'DecMax':.256 }
		@requestBounds = {'RAMin':0 , 'RAMax':0, 'DecMin':0, 'DecMax':0 }
		@overlays = []
		@canvas2d = canvas2dctx
		@gl = canvas3dctx
		@camera = {"x": 0.0, "y":0.0, "z":2.414213562}
		@displayColor = {"R": 0, "G": 0, "B":0, "A":1}
	requestSDSS: ()->
		@overlays.push(new SDSSOverlay(@gl))
	requestFIRST: ()->
		@overlays.push(new Overlay(@gl))
	requestBox:(cb)->
		@overlays.push(new BoxOverlay(@canvas2d))
	translate:(x,y,z)->
	    if(-@camera.x - x > 0)
	      @camera.x += x
	    if(@camera.y + y > -90 and @camera.y + y < 90)
	      @camera.y += y
	    @camera.z += z
	display:()->
		@gl.viewport(0, 0, width, height);
		@gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT); # clear color and depth
		@gl.clearColor(@displayColor.R,@displayColor.G,@displayColor.B,@displayColor.A);
		@gl.perspectiveMatrix.makeIdentity();
		@gl.perspectiveMatrix.perspective(45, 1, 0.01, 100);
		@gl.perspectiveMatrix.lookat(@camera.x, @camera.y, @camera.z,@camera.x, @camera.y, 0, 0, 1, 0);
		for overlay in @overlays
			overlay.display(@getBounds())
		@gl.flush();
	withinSpan:(bound)->return ((bound.RAMax < @span.RAMax) and (bound.RAMin > @span.RAMin) and (bound.DecMax < @span.DecMax) and (bound.DecMin > @span.DecMin));
	requestBoundExpansion:(side)->
		if(side == 1) 
			#Get current decMax, add .512 to span, send to requestFIRST
			@requestBounds.RAMin = @span.RAMin
			@requestBounds.RAMax = @span.RAMax
			@requestBounds.DecMin = @span.DecMax
			@requestBounds.DecMax = @span.DecMax = @span.DecMax + .512
		else if(side == 3) 
			@requestBounds.RAMin = @span.RAMin
			@requestBounds.RAMax = @span.RAMax
			@requestBounds.DecMax = @span.DecMin
			@requestBounds.DecMin = @span.DecMin = @span.DecMin -.512
		else if(side == 2) 
			@requestBounds.DecMax = @span.DecMax
			@requestBounds.DecMin = @span.DecMin
			@requestBounds.RAMax = @span.RAMin
			@requestBounds.RAMin = @span.RAMin = @span.RAMin - .512
		else if(side == 4)
			@requestBounds.DecMax = @span.DecMax
			@requestBounds.DecMin = @span.DecMin
			@requestBounds.RAMin = @span.RAMax
			@requestBounds.RAMax = @span.RAMax = @span.RAMax + .512
		else
			return
		for overlay in @overlays
			overlay.requestImages(@requestBounds)
	###
	FUNCTION: getBounds()

	returns: Will return the bounding box of the camera. This box is based on a 1024x1024 viewing pane. Any smaller / larger, and it will still
	assume this
	###
	getBounds:()->
		center = {'RA':-@camera.x*.256, 'DEC':-@camera.y*.256}
		height = width = @z/2.414213562*1.8*.512
		boundingBox = {'RAMin': center.RA-width/2,'RAMax': center.RA+width/2, 'DecMin': center.DEC-height/2, 'DecMax': center.DEC+height/2  }
		return boundingBox
    scrolling:(event)->
    	delta = 0;
	    if (!event) 
	    	event = window.event;
	    #normalize the delta
	    if (event.wheelDelta)
	    	#IE and Opera
	        delta = event.wheelDelta / 60;
	    else if (event.detail) 
	    	delta = -event.detail / 2;
	    if(delta > 0 && @camera.z >= 1.8)
	    	@translate(0,0,-.3)
	    else if(delta <= 0)
	    	@translate(0,0,.3)