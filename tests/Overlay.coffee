class Overlay
	constructor: (options)->
		@type = if options.type? then options.type else "SDSS"
		@view = if options.view? then options.view else null
		if @type == "SDSS"
			@requestImage = @requestSDSS 
		else
			@requestImage = @requestFIRST
		@view.attach(this); #Creating view requires an attach to observer
	notify:(type, info)->
		switch type
			when "display"
				display(info)
			when "request"
				request(info)
			else
				break;
	request:(req)=>
		[x,y] = [req.x*.512, req.y*.512]
		@requestImage(x,y)
	requestSDSS:(degX, degY)->
		# TODO: Take requests from SDSS image database, add to imageproxy of some sort