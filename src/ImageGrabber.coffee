class ImageGrabber
	constructor: ->
	
	getImages: (ra,dec,radius,zoom) =>
		
		images = "../lib/SDSSFieldQuery.php?ra=#{ra}&dec=#{dec}&radius=#{radius}&zoom=#{zoom}"
		
	