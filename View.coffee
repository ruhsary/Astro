class View
	constructor: (canvas3dctx, canvas2dctx)->
		@overlays = []
		@canvas2d = canvas2dctx
		@gl = canvas3dctx
		@camera = {"x": 0.0, "y":0.0, "z":2.414213562}
		@displayColor = {"R": 0, "G": 0, "B":0, "A":1}
	requestSDSS: ()->
		@overlays.push(new SDSSOverlay(@gl))
	requestFIRST: ()->
		@overlays.push(new Overlay(@gl))
	display:()->
		for overlay in @overlays
			overlay.display()