$(document).ready ()->
	placeholder = new Image()
	await
		placeholder.onload = defer()
		placeholder.src = "placeholder.jpg"
	di = document.getElementById("container");
	view = new View(di);
	overlayFIRST = new Overlay({
		type: "FIRST",
		alpha: .8,
		"view": view
		placeholder:placeholder
		})
	click = ()->
		view.display()
		setTimeout(click, 15)
	click()