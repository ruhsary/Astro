
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

    setEvents:(canvasid)->
        @canvas.onmousedown =(event)=>
            if(!@enabled)
                return
            @start = @canvas.relMouseCoords(event)
            @draw = true
        @canvas.onmousemove =(event)=>
            if(@draw and @enabled)
                @end = @canvas.relMouseCoords(event)
                
        @canvas.onmouseup = (event)=>
            if(!@enabled)
                return
            @end = @canvas.relMouseCoords(event)
            @ctx.clearRect(0,0, @canvas.width, @canvas.height);
            if(@onBox)
                @onBox({start: @start, end:@end})
            @draw = false
    display:(bound)->
        if @draw
            @ctx.clearRect(0,0, @canvas.width, @canvas.height);
            @ctx.fillRect(@start.x, @start.y, @end.x-@start.x, @end.y-@start.y);
  