$(document).ready ()->
	placeholder = new Image()
	await
		placeholder.onload = defer()
		placeholder.src = "placeholder.jpg"

	overlay = new Overlay({type:"FIRST"}, placeholder)
	overlay.request {x:0,y:0}
	ctx = $("canvas").get(0).getContext("2d")
	info = {
		x:0,
		y:0,
		'ctx':ctx
	}
	click = ()->
		overlay.notify("display", info)
		setTimeout click, 15
	click();