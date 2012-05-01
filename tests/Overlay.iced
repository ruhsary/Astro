class ImageProxy
	constructor:(imgURL, placeholder)->
		@currentImage = placeholder
		@realImage = new Image()
		@realImage.onload = ()=>
			@currentImage = @realImage
		@realImage.src = imgURL
	display:()->
		return @currentImage

class Overlay
	constructor: (options, placeholder)->
		@buffer= {};
		@placeholder = placeholder;
		@type = if options.type? then options.type else "SDSS"
		@view = if options.view? then options.view else null
		if @type == "SDSS"
			@requestImage = @requestSDSS 
		else
			@requestImage = @requestFIRST
		if(@view)
			@view.attach(this); #Creating view requires an attach to observer
	notify:(type, info)->
		switch type
			when "display"
				@display(info)
			when "request"
				@request(info)
			else
				break;
	request:(req)=>
		[x,y] = [req.x*.512, req.y*.512]
		if(@buffer[x]? and @buffer[x][y]?)
			return;
		else
			await @requestImage x, y, defer imgProxy
			if(@buffer[x]?)
				@buffer[x][y] = imgProxy
			else
				@buffer[x] = {}
				@buffer[x][y] = imgProxy
	display:(info)->
		if(@buffer[info.x] and @buffer[info.x][info.y])
			info.ctx.save()
			info.ctx.translate(info.x*1024, info.y*1024);
			info.ctx.drawImage(@buffer[info.x][info.y].display(), 0, 0)
			info.ctx.restore()
	requestSDSS:(degX, degY)->
		# TODO: Take requests from SDSS image database, add to imageproxy of some sort
	requestFIRST: (degX,degY, cb)->
		decMin = degY - .256;
		decMax = degY + .256
		raMax = degX - .256 #It is minus because right ascension goes right to left
		raMin = degX + .256
		await $.post "request.php", defer(data), 'text'
		imgProxy = new ImageProxy("00000+00000E.fits.jpg", @placeholder)
		cb imgProxy