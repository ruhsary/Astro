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
		@debug = if options.type? then options.type else false
		@type = if options.type? then options.type else "SDSS"
		@view = if options.view? then options.view else null
		@alpha = if options.alpha? then options.alpha else 1.0
		
		@imagePath = ''
		if @type == "SDSS"
			@requestImage = @requestSDSS 
		else if @type == "FIRST"
			@requestImage = @requestFIRST
			@imagePath = if options.imagepath? then options.imagepath else ''
		else if @type == "ANNO"
			@requestImage = @requestAnno
			@imagePath = if options.imagepath? then options.imagepath else ''
			@time = if options.time? then options.time else 0.0
			@query = if options.query? then options.query else null
			@color = if options.color? then options.color else null
			@source = if options.source? then options.source else null
			
		else if @type == "custom"
			@requestImage = options.imageRequest
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
			
		if(@buffer[req.x]? and @buffer[req.x][req.y]?)
			return;
		else
			cb = (imgURL)=>
				imgProxy = new ImageProxy(imgURL, @placeholder)
				if(@buffer[req.x]?)
					@buffer[req.x][req.y] = imgProxy
				else
					@buffer[req.x] = {}
					@buffer[req.x][req.y] = imgProxy
			@requestImage(req.RA, req.Dec, @scale, cb)
	display:(info)=>
		if(@buffer[info.x] and @buffer[info.x][info.y])
			info.ctx.save()
			info.ctx.globalAlpha = @alpha
			info.ctx.translate(-info.x*1024, info.y*1024);

			if(@buffer[info.x][info.y].display())
				info.ctx.drawImage(@buffer[info.x][info.y].display(), 0, 0)
			info.ctx.restore()
	requestSDSS:(degX, degY, scale, cb)=>
			
		# TODO: Take requests from SDSS image database, add to imageproxy of some sort
		decMin = degY - .256;
		decMax = degY + .256
		raMax = degX + .256 #It is minus because right ascension goes right to left
		raMin = degX - .256
			
		newurl ="./lib/db/remote/SDSS.php?scale=#{1.8}&ra=#{degX}&dec=#{degY}&width=1024&height=1024&opt=GL"
		if(@debug)
			newurl = "SDSS.jpg"
		imgURL = newurl
		cb imgURL
		@view.display();
	
	requestFIRST: (degX,degY, scale, cb)=> 
		
		decMin = degY - .256;
		decMax = degY + .256
		raMax = degX + .256 #It is minus because right ascension goes right to left
		raMin = degX - .256

		url = 'http://astro.cs.pitt.edu/panickos/lib/db/remote/SPATIALTREE.php'
		done = (data)=>
			imgURL = ""
			if(data[0])
				imgURL = (@imagePath + data[0])
			else
				imgURL = @placeholder
			cb imgURL				
		$.get url,{RAMin:raMin, RAMax:raMax, DecMin:decMin, DecMax:decMax}, done, 'json'
	
	requestAnno: (degX, degY, scale, cb)=>
		
		decMin = degY - .256;
		decMax = degY + .256
		raMax = degX + .256 #It is minus because right ascension goes right to left
		raMin = degX - .256
				
		imgURL = "./lib/createOverlay.php?width=1024&height=1024
			&RAMin=#{raMin}&RAMax=#{raMax}&DecMin=#{decMin}&DecMax=#{decMax}&scale=1.8&diam=2
			&ms=#{@time}&query=#{@query}&type=#{@source}&color=#{@color}"
						
		cb imgURL
		@view.display();
	deleteOverlay:()=>
		@view.detach(this)

	setAlpha:(newAlpha)=>
		@alpha = newAlpha
	setPlaceholder: (newPlaceholder)=>
		@placeholder = newPlaceholder
