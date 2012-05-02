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
	constructor: (options)->
		@buffer= {};
		@placeholder = options.placeholder;
		@type = if options.type? then options.type else "SDSS"
		@view = if options.view? then options.view else null
		@alpha = if options.alpha? then options.alpha else 1.0
		if @type == "SDSS"
			@requestImage = @requestSDSS 
		else
			@requestImage = @requestFIRST
		if(@view)
			@view.attach(this); #Creating view requires an attach to observer
	update:(type, info)->
		switch type
			when "display"
				@display(info)
			when "request"
				@request(info)
			when "static"
				break;
			else
				break;
	request:(req)=>
		[x,y] = [req.x*.512, req.y*.512]
		if(@buffer[req.x]? and @buffer[req.x][req.y]?)
			return;
		else
			await @requestImage x, y, defer imgProxy
			if(@buffer[req.x]?)
				@buffer[req.x][req.y] = imgProxy
			else
				@buffer[req.x] = {}
				@buffer[req.x][req.y] = imgProxy
	display:(info)=>
		if(@buffer[info.x] and @buffer[info.x][info.y])
			info.ctx.save()
			info.ctx.globalAlpha = @alpha
			info.ctx.translate(-info.x*1024, info.y*1024);
			if(@buffer[info.x][info.y].display())
				info.ctx.drawImage(@buffer[info.x][info.y].display(), 0, 0)
			info.ctx.restore()
	requestSDSS:(degX, degY, cb)->
		# TODO: Take requests from SDSS image database, add to imageproxy of some sort
		decMin = degY - .256;
		decMax = degY + .256
		raMax = degX - .256 #It is minus because right ascension goes right to left
		raMin = degX + .256
		newurl ="http://astro.cs.pitt.edu/astroshelfTIM/db/remote/SDSS.php?scale=#{1.8}&ra=#{degX}&dec=#{degY}&width=1024&height=1024"
		newurl = "SDSS.jpg"
		imgProxy = new ImageProxy(newurl, @placeholder)
		cb imgProxy
		@view.display();
	requestFIRST: (degX,degY, cb)->
		decMin = degY - .256;
		decMax = degY + .256
		raMax = degX - .256 #It is minus because right ascension goes right to left
		raMin = degX + .256
		await $.post "request.php",{RAMin:raMin, RAMax:raMax, DecMin:decMin, DecMax:decMax}, defer(data), 'json'
		if(data[0])
			imgProxy = new ImageProxy(data[0], @placeholder)
		else
			imgProxy = new ImageProxy(@placeholder, @placeholder)
		cb imgProxy
		@view.display() #refresh
	setAlpha:(newAlpha)=>
		@alpha = newAlpha
