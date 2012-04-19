class ImageLoader
  ###
  Image loader is used to load multiple images at once, then call a function when they are all loaded.
  TODO:Needs to be a singleton.
  TODO: Needs to cache, as in an object
  ###
  constructor:()->
    @imageHolder = {}
    @loadStack = 0
    @count = 0
    @start = false
    @loadedFunc = ()-> @start = false
      
  ###
  Parameter: image url (DO NOT PUT AN ACTUAL IMAGE ELEMENT IN, Only the URL)
            action: a function that will be called when the image is done loading.  
  returns: Nothing
  Push an image to the image stack.
  
  ###
  pushImage:(imgUrl, action)->
    if(@imageHolder[imgUrl]?)
    else
      newImg = document.createElement("img")
      @loadStack += 1
      @count +=1
      newImg.src = imgUrl
      newImg.onload = ()=>
        @loadStack-=1
        action(newImg)
      @imageHolder[imgUrl] = newImg
    
  ###
  Will set a flag that allows the loading to 'begin'. Technically, it starts when you push an image onto the stack
  but this will make it so that the onFullLoaded will be called, since it knows all pushing is done.
  ###
  startLoad: ()->
    @start = true
    if(@loadedStack == 0 and @start)
      @loadedFunc()
      
  ###
  returns: BOOLEAN
  will check if all the images are loaded.
  ###
  imagesLoaded: ()->
    return @loadStack==0
  ###
  Returns: float
  will be between 1 and 100 of percent of images loaded.
  ###
  percentLoaded: ()->
    return 100.0*(@count-@loadStack)/(float)(@count)
  ###
  Attach a function onto onFullLoad and it will run whenever the imageloader is all loaded and
  has started (must use startLoad since there is the possibility that while pushing images, the load counter
  reaches 0 and sends signal to onFullLoad before all is pushed)
  
  CAN ATTACH MULTIPLE FUNCTIONS,
  IF YOU WANT TO ERASE ALL FUNCTIONS ATTACHED SAY VARIABLE_NAME.loadedFunc = EMPTY_FUNCTION
  
  ###
  onFullLoad:(updateFunc)=>
    oldLoaded = @loadedFunc
    if(@loadedFunc)
      @loadedFunc = ()->
        if(oldLoaded)
          oldLoaded()
        updateFunc()
    else
      @loadedFunc = updateFunc
      
  clear: ()->
    @imageHolder = []
################################################################################
#Pane:
# Interface:
#   constructor(imageElement)-- Will set the image element in the pane
#   createTexture(glContext) -- Will bind the inner image to a gltexture
#   weightedPoint(point)-- Makes the pane into a weightedPane which has RA / DEC values
################################################################################
class Pane
  constructor:(img)->
      @image = img
  createTexture:(gl)->
      @texture = gl.createTexture();
      @texture.image = @image
      doLoadImageTexture(gl, @texture.image, @texture)
      handleLoadedTexture(gl, @texture)

  weightedPoint:(point)->
      fitPatt =/([0-9][0-9])([0-9][0-9])([0-9])([+-])([0-9][0-9])([0-9][0-9])([0-9])E.fits/gi;
      matches = fitPatt.exec(point)
      hours = parseInt(matches[1], 10)
      minutes = parseInt(matches[2], 10)
      seconds = parseInt(matches[3], 10)
      seconds /= 10.0
      minutes += seconds
      minutes /= 60.0
      hours += minutes
      hours *= 15
      @RA = hours
      ###
      Now calculate DEC
      ###
      degrees= parseInt(matches[5], 10)
      minutes = parseInt(matches[6], 10)
      seconds = parseInt(matches[7], 10)
      @DEC = degrees
      minutes = minutes + seconds/10.0
      @DEC = @DEC + minutes/60.0
      if(matches[4] == '-')
        @DEC = 0 - @DEC

################################################################################
#Overlay:
# constructor: Takes a gl object to put textures into.
#
# interface:
#   draw() ---- will take the default gl and draw all the textures from TEXTURE_0, no return value
#   getImageArray(fitsFileArray)----will fill up the Overlay by communicating with the server backend with the bounding box.
#   clear()---Clears out the Panes, indeces, and textures. Useful for jumping locations
################################################################################
class Overlay
  constructor:(gl)->
    @gl = gl
    @index = 0
    @indices = []
    @textureCoords = []
    @vertices = []
    @opacity = 1.0
    @preLoader = new ImageLoader()
    @panes = []
  constructPane:(image)=>
    newPane = new Pane(image)
    newPane.weightedPoint(image.src)
    if(image.height != 1024 or image.width != 1024)
      return
    newPane.createTexture(@gl)
    @pushTexture(newPane) #Pushes texture onto the indices / vertices stack to be called later.
    @panes.push(newPane) #Panes to be displayed, at this point this image is ready to be displayed.
  requestImages:(span)->
    #$.get('http://astro.cs.pitt.edu/astroshelfTIM/db/remote/SPATIALTREE.php', span, @insertImages, 'json')
    #TODO: SEND THIS TO OUTER CLASS
    @insertImages(['00000+00000E.fits.jpg']) 
  insertImages:(arr)=>
    for url in arr
      @preLoader.pushImage(url, @constructPane)
  pushTexture:(pane)->
    right = 1.0 - Math.round(pane.RA/.512)*2
    left = -1.0 - Math.round(pane.RA/.512)*2
    top = 1.0 + Math.round(pane.DEC/.512)*2
    bottom = -1.0 + Math.round(pane.DEC/.512)*2
    #console.log("{#{pane.RA}, #{pane.DEC}}: #{right}, #{left}, tb #{top}, #{bottom} ");
    @vertices.push(left); @vertices.push(bottom); @vertices.push(0);
    @vertices.push(right); @vertices.push(bottom); @vertices.push(0);
    @vertices.push(right); @vertices.push(top); @vertices.push(0);
    @vertices.push(left); @vertices.push(top); @vertices.push(0);
    @indices.push(@index);
    @indices.push(@index + 1);
    @indices.push(@index + 2);
    @indices.push(@index);
    @indices.push(@index + 2);
    @indices.push(@index + 3);
    @index += 4
    @textureCoords.push(0.0); @textureCoords.push(0.0);
    @textureCoords.push(1.0); @textureCoords.push(0.0);
    @textureCoords.push(1.0); @textureCoords.push(1.0);
    @textureCoords.push(0.0); @textureCoords.push(1.0);
  clear:()->
    @opacity = 1.0
   # @preLoader.clear()
    @panes = []
  display:(view)->
    texCoordObject = @gl.createBuffer();
    @gl.bindBuffer(@gl.ARRAY_BUFFER, texCoordObject);
    @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(@textureCoords), @gl.STATIC_DRAW);
    @gl.bindBuffer(@gl.ARRAY_BUFFER, null);
    vertexObject = @gl.createBuffer();
    @gl.bindBuffer(@gl.ARRAY_BUFFER, vertexObject);
    @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(@vertices), @gl.STATIC_DRAW);
    @gl.bindBuffer(@gl.ARRAY_BUFFER, null);
    
    indexObject = @gl.createBuffer();
    @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, indexObject);
    @gl.bufferData(@gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(@indices), @gl.STATIC_DRAW);
    @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, null);
    
    @gl.bindBuffer(@gl.ARRAY_BUFFER, vertexObject);
    @gl.vertexAttribPointer(@gl.vertexPosition, 3, @gl.FLOAT, false, 0, 0);    
   
    @gl.bindBuffer(@gl.ARRAY_BUFFER, texCoordObject);
    @gl.vertexAttribPointer(@gl.texturePosition, 2, @gl.FLOAT, false, 0, 0);
    @gl.mvMatrix.setUniform(@gl, @gl.u_modelViewMatrix, false);
    @gl.perspectiveMatrix.setUniform(@gl, @gl.u_projectionMatrix, false);
    @gl.activeTexture(@gl.TEXTURE0);
    @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, indexObject);

    i = 0
    for pane in @panes
      if(pane.texture and @withinView(view,pane))
        @gl.bindTexture(@gl.TEXTURE_2D, pane.texture);
        @gl.drawElements(@gl.TRIANGLES, 6, @gl.UNSIGNED_SHORT, i);  
      else if(@withinView(view,pane))
        pane.createTexture(@gl)
        @gl.bindTexture(@gl.TEXTURE_2D, pane.texture);
        @gl.drawElements(@gl.TRIANGLES, 6, @gl.UNSIGNED_SHORT, i);  
      else if(!(pane.texture == null))
        console.log("Removed pane from field")
        @gl.deleteTexture(pane.texture);
        pane.texture = null;
      i+=12
   # @gl.flush();
   # @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, null);
  withinView:(view,pane)->
    return ((view.RAMax > (pane.RA-.512) and view.RAMin < (pane.RA+.512)) and (view.DecMax > (pane.DEC-.512) and view.DecMin < (pane.DEC+.512)))
  withinSpan:(bound)->
    #console.log("RA:{#{bound.RAMin}, #{bound.RAMax}} Dec: {#{bound.DecMin}, #{bound.DecMax}}~~~~Span: RA:{#{@span.RAMin}, #{@span.RAMax}} Dec: {#{@span.DecMin}, #{@span.DecMax}}")
    return (bound.RAMax < @span.RAMax) and (bound.RAMin > @span.RAMin) and (bound.DecMax < @span.DecMax) and (bound.DecMin > @span.DecMin)
  setEvents: (canvasid, view)->
    canvas = document.getElementById(canvasid)
    view = view
    canvas.onmousedown = (event)=>
      @md = true;
      @cx = event.clientX;
      @cy = event.clientY;

    canvas.onmousemove = (event)=>
      if(@md)
        view.translate((@cx - event.clientX)/200.0,0,0);
        view.translate(0,(-@cy + event.clientY)/200.0, 0);
        @cx = event.clientX;
        @cy = event.clientY;

    canvas.onmouseup = (event)=>
      @md = false;
  #Returns viewBound
 ###

 ### 
class SDSSOverlay extends Overlay    
  constructPane:(image)=>
    newPane = new Pane(image)
    newPane.RA = arguments[1]
    newPane.DEC = arguments[2]
    newPane.createTexture(@gl)
    @pushBounds(newPane)
    @pushTexture(newPane) #Pushes texture onto the indices / vertices stack to be called later.
    @panes.push(newPane)
  insertImages:(arr)=>
    for url in arr
      point = Util::calculateRADEC(url)
      ra = point[0]
      dec = point[1]
      newurl ="http://astro.cs.pitt.edu/astroshelfTIM/db/remote/SDSS.php?scale=#{1.8}&ra=#{ra}&dec=#{dec}&width=1024&height=1024"
      @preLoader.pushImage(newurl, ((ra,dec)=>(
        raf = ra
        decf = dec
        fun = @constructPane
        return (image)->(fun(image, raf,decf))
        ))(ra,dec))
requestImages:(span)->
    $.get('http://astro.cs.pitt.edu/astroshelfTIM/db/remote/SPATIALTREE.php', span, @insertImages, 'json')
    #TODO: SEND THIS TO OUTER CLASS
    @insertImages(['00000+00000E.fits.jpg']) 
   # @gl.flush();
################################################################################
#TESTING STUFF BELOW
#rawr = document.getElementById("testCanvas");
#ctx = rawr.getContext("2d");

#overlay = new Overlay()
#overlay.onReady = ()->
#  overlay.display(ctx)
#ctx.drawImage(imgur.imageHolder[1], 100,100)
#overlay.insertImages(['13473+12479E.fits.jpeg','13494+12479E.fits.jpeg','13473+13187E.fits.jpeg','13494+13187E.fits.jpeg'])
