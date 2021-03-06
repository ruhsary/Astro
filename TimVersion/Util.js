// Generated by CoffeeScript 1.3.1
var Util;

Util = (function() {

  Util.name = 'Util';

  function Util() {}

  /*
  	FUNCTION: calculateRADEC(point)
  	Param: point--A single string formatted in FITS file format.
  	Return: [RA, DEC] in degree format
  */


  Util.prototype.calculateRADEC = function(point) {
    var DEC, RA, degrees, fitPatt, hours, matches, minutes, seconds;
    fitPatt = /([0-9][0-9])([0-9][0-9])([0-9])([+-])([0-9][0-9])([0-9][0-9])([0-9])E.fits/gi;
    matches = fitPatt.exec(point);
    hours = parseInt(matches[1], 10);
    minutes = parseInt(matches[2], 10);
    seconds = parseInt(matches[3], 10);
    seconds /= 10.0;
    minutes += seconds;
    minutes /= 60.0;
    hours += minutes;
    hours *= 15;
    RA = hours;
    /*
    		Now calculate DEC
    */

    degrees = parseInt(matches[5], 10);
    minutes = parseInt(matches[6], 10);
    seconds = parseInt(matches[7], 10);
    DEC = degrees;
    minutes = minutes + seconds / 10.0;
    DEC = DEC + minutes / 60.0;
    if (matches[4] === '-') {
      DEC = 0 - DEC;
    }
    return [RA, DEC];
  };

  /*
  	FUNCTION: pixelSpaceToDegreeSpace(pixelPoint, degreeCenterPoint, pixelCenter, scale)
  	Param:  pixelPoint--An {x,y} point in pixel space 
  			degreeCenterPoint-- in Degree space point
  			pixelCenter -- center point in pixel space used to convert to degreecenterpoint
  			scale -- need this as well to get arcsec/pixel and then calculate pixel width and stuff
  	Return: {x,y} in degree space of pixelPoint
  */


  Util.prototype.pixelSpaceToDegreeSpace = function(pixelPoint, degreeCenterPoint, pixelCenter, scale) {
    var checkTest, degreeHeight, degreePoint, degreeWidth, pixelHeight, pixelWidth;
    if (!((pixelPoint.x != null) && (pixelPoint.y != null) && (degreeCenterPoint.x != null) && (degreeCenterPoint.y != null))) {
      return null;
    }
    pixelWidth = pixelPoint.x - pixelCenter.x;
    pixelHeight = pixelPoint.y - pixelCenter.y;
    checkTest = 1024 / 512;
    /*Pixels*arcsec/pixel = arcsec per difference. 1 degree = 3600 arcseconds
    */

    degreeWidth = pixelWidth * scale / 3600.0 * checkTest;
    degreeHeight = pixelHeight * scale / 3600.0 * checkTest;
    degreePoint = {
      'x': degreeCenterPoint.x - degreeWidth,
      'y': degreeCenterPoint.y + degreeHeight
    };
    return degreePoint;
  };

  Util.prototype.hookEvent = function(element, eventName, callback) {
    if (typeof element === "string") {
      element = document.getElementById(element);
    }
    if (element === null) {
      return;
    }
    if (element.addEventListener) {
      if (eventName === 'mousewheel') {
        element.addEventListener('DOMMouseScroll', callback, false);
      }
      return element.addEventListener(eventName, callback, false);
    } else if (element.attachEvent) {
      return element.attachEvent("on" + eventName, callback);
    }
  };

  Util.prototype.unhookEvent = function(element, eventName, callback) {
    if (typeof element === "string") {
      element = document.getElementById(element);
    }
    if (element === null) {
      return;
    }
    if (element.removeEventListener) {
      if (eventName === 'mousewheel') {
        element.removeEventListener('DOMMouseScroll', callback, false);
      }
      return element.removeEventListener(eventName, callback, false);
    } else if (element.detachEvent) {
      return element.detachEvent("on" + eventName, callback);
    }
  };

  return Util;

})();
