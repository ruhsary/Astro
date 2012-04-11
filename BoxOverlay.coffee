
class BoxOverlay
    constructor: (canvasid)->
        @canvas = document.getElementById(canvasid)
        @ctx = @canvas.getContext('2d')
        @ctx.fillStyle = "rgba(0,0,200,.5)"
        @start = 0
        @draw = false
        @enabled = true
        @end = 0
        @canvas.relMouseCoords = (event)->
            totalOffsetX = 0
            totalOffsetY = 0
            canvasX = 0
            canvasY = 0
            currentElement = this
            while currentElement = currentElement.offsetParent
                totalOffsetX += currentElement.offsetLeft
                totalOffsetY += currentElement.offsetTop
            canvasX = event.pageX - totalOffsetX
            canvasY = event.pageY - totalOffsetY
            return {x:canvasX, y:canvasY}
        @onBox = null
        $('#'+ canvasid).mousedown((event)=>
            if(!@enabled)
                return
            @start = @canvas.relMouseCoords(event)
            @draw = true)
        $('#'+ canvasid).mousemove((event)=>
            if(@draw and @enabled)
                @end = @canvas.relMouseCoords(event)
                @ctx.clearRect(0,0, @canvas.width, @canvas.height);
                @ctx.fillRect(@start.x, @start.y, @end.x-@start.x, @end.y-@start.y);
        )
        $('#'+ canvasid).mouseup((event)=>
            if(!@enabled)
                return
            @end = @canvas.relMouseCoords(event)
            @ctx.clearRect(0,0, @canvas.width, @canvas.height);
            if(@onBox)
                @onBox({start: @start, end:@end})
            @draw = false
        )
        pixelSpaceToDegreeSpace: (pixelPoint, degreeCenterPoint, pixelCenter, scale)->
            #Assertion: Stuff must be in there!
            if(!(pixelPoint.x? and pixelPoint.y? and degreeCenterPoint.x? and degreeCenterPoint.y?))
                return null
            pixelWidth = pixelPoint.x - pixelCenter.x
            pixelHeight = pixelHeight.y - pixelHeight.y
            ###Pixels*arcsec/pixel = arcsec per difference. 1 degree = 3600 arcseconds###
            degreeWidth = pixelWidth*scale/3600.0
            degreeHeight = pixelHeight*scale/3600.0
            