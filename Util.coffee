class Util
	###
	FUNCTION: calculateRADEC(point)
	Param: point--A single string formatted in FITS file format.
	Return: [RA, DEC] in degree format
	###
	calculateRADEC:(point)->
		fitPatt =/([0-9][0-9])([0-9][0-9])([0-9])([+-])([0-9][0-9])([0-9][0-9])([0-9])E.fits/gi
		matches = fitPatt.exec(point)
		hours = parseInt(matches[1], 10)
		minutes = parseInt(matches[2], 10)
		seconds = parseInt(matches[3], 10)
		seconds /= 10.0
		minutes += seconds
		minutes /= 60.0
		hours += minutes
		hours *= 15
		RA = hours
		###
		Now calculate DEC
		###
		degrees= parseInt(matches[5], 10)
		minutes = parseInt(matches[6], 10)
		seconds = parseInt(matches[7], 10)
		DEC = degrees
		minutes = minutes + seconds/10.0
		DEC = DEC + minutes/60.0
		if(matches[4] == '-')
			DEC = 0 - DEC
		return [RA, DEC]
	###
	FUNCTION: pixelSpaceToDegreeSpace(pixelPoint, degreeCenterPoint, pixelCenter, scale)
	Param:  pixelPoint--An {x,y} point in pixel space 
			degreeCenterPoint-- in Degree space point
			pixelCenter -- center point in pixel space used to convert to degreecenterpoint
			scale -- need this as well to get arcsec/pixel and then calculate pixel width and stuff
	Return: {x,y} in degree space of pixelPoint
	###
	pixelSpaceToDegreeSpace: (pixelPoint, degreeCenterPoint, pixelCenter, scale)->
		#Assertion: Stuff must be in there!
		if(!(pixelPoint.x? and pixelPoint.y? and degreeCenterPoint.x? and degreeCenterPoint.y?))
		    return null
		pixelWidth = pixelPoint.x - pixelCenter.x
		pixelHeight = pixelPoint.y - pixelCenter.y
		checkTest = 1024/512
		###Pixels*arcsec/pixel = arcsec per difference. 1 degree = 3600 arcseconds###
		degreeWidth = pixelWidth*scale/3600.0*checkTest
		degreeHeight = pixelHeight*scale/3600.0*checkTest
		degreePoint = {'x':(degreeCenterPoint.x - degreeWidth), 'y':(degreeCenterPoint.y + degreeHeight)}
		return degreePoint
	hookEvent:(element, eventName, callback)->
		if(typeof(element) == "string")
			element = document.getElementById(element);
		if(element == null)
			return;
		if(element.addEventListener)
			if(eventName == 'mousewheel')
				element.addEventListener('DOMMouseScroll', callback, false);  
			element.addEventListener(eventName, callback, false);
		else if(element.attachEvent)
			element.attachEvent("on" + eventName, callback);

	unhookEvent:(element, eventName, callback)->
		if(typeof(element) == "string")
			element = document.getElementById(element);
		if(element == null)
			return;
		if(element.removeEventListener)
			if(eventName == 'mousewheel')
				element.removeEventListener('DOMMouseScroll', callback, false);  
			element.removeEventListener(eventName, callback, false);
		else if(element.detachEvent)
			element.detachEvent("on" + eventName, callback);
