class Util
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
	pixelSpaceToDegreeSpace: (pixelPoint, degreeCenterPoint, pixelCenter, scale)->
		#Assertion: Stuff must be in there!
		if(!(pixelPoint.x? and pixelPoint.y? and degreeCenterPoint.x? and degreeCenterPoint.y?))
		    return null
		pixelWidth = pixelPoint.x - pixelCenter.x
		pixelHeight = pixelHeight.y - pixelHeight.y
		###Pixels*arcsec/pixel = arcsec per difference. 1 degree = 3600 arcseconds###
		degreeWidth = pixelWidth*scale/3600.0
		degreeHeight = pixelHeight*scale/3600.0