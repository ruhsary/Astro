class ImageLoader
  ###
  Image loader is used to load multiple images at once, then call a function when they are all loaded.
  ###
  constructor:()->
    @imageHolder = []
    @loadStack = 0
    @count = 0
    @start = false
    @loadedFunc = ()-> @start = false
      
  ###
  Parameter: image url (DO NOT PUT AN ACTUAL IMAGE ELEMENT IN, Only the URL)
  returns: Nothing
  Push an image to the image stack.
  ###
  pushImage:(imgUrl)->
    newImg = document.createElement("img")
    @loadStack += 1
    @count +=1
    newImg.src = imgUrl
    newImg.onload = ()=>
      @loadStack-=1
      if(@loadStack == 0 and @start)
        @loadedFunc()
    @imageHolder.push(newImg)
    
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
#   -image
#   -Texture
#   -RA/DEC
################################################################################
class Pane
  constructor:(img, gl)->
      @image = img
      fitPatt =/([0-9][0-9])([0-9][0-9])([0-9])([+-])([0-9][0-9])([0-9][0-9])([0-9])E.fits/gi;
      matches = fitPatt.exec(img.src)
      hours = parseInt(matches[1])
      minutes = parseInt(matches[2])
      seconds = parseInt(matches[3])
      seconds /= 10.0
      minutes += seconds
      minutes /= 60.0
      hours += minutes
      hours *= 15
      @RA = hours
      ###
      Now calculate DEC
      ###
      degrees= parseInt(matches[5])
      minutes = parseInt(matches[6])
      seconds = parseInt(matches[7])
      @DEC = degrees
      minutes = minutes + seconds/10.0
      @DEC = @DEC + minutes/60.0
      @image.setAttribute('width', '1024px')
      @image.setAttribute('height', '1024px')
      @texture = gl.createTexture();
      @texture.image = img
      doLoadImageTexture(gl, @texture.image, @texture)
      handleLoadedTexture(gl, @texture)
      if(matches[4] == '-')
          @DEC = 0 - @DEC
    ###
    type: RA to compare RA, DEC to compare DEC
    ###
  compare:(otherPane, type)->
      myObj = @DEC
      otherObj = otherPane.DEC
      if type == 'RA'
          myObj = @RA
          otherObj = otherPane.RA
      if(myObj > otherObj)
          return 1
      else if(myObj < otherObj)
          return -1
      else
          return 0
  ###
  The layout is a bunch of panes placed based on their DEC and RA:
  
      0   1   2   3   4   5   6
  0  NUL R1  R2  R3  R4  R5  R6
  
  1  D1  P1  P2  UN  P3  P4  P5
  
  2  D2 .......................
  
  3  D3 .......................
  
  4  D4 .......................
  
  5  D5 ......................
  
  So we create a 2 dimensional array where each Panel can be placed
  within 1-N and the RA is in the 0th row, while the DEC is defined in the
  0th column.
  ###
################################################################################
#Overlay:
# constructor: Takes a gl object to put textures into.
#
# interface:
#   draw() ---- will take the default gl and draw all the textures from TEXTURE_0, no return value
#   getImageArray(boundingBox, url)----will fill up the Overlay by communicating with the server backend with the bounding box.
#       (boundingBox): Holds RAMin, RAMax, DecMin, DecMax most likely pulled from the canvas
#   clear()---Clears out the Panes, indeces, and textures. Useful for jumping locations
################################################################################
class Overlay
  constructor:(gl)->
    @gl = gl
    @x = @y = @z = 0
    @z = 1.8
    @index = 0
    @indices = []
    @textureCoords = []
    @vertices = []
    @opacity = 1.0
    @preLoader = new ImageLoader()
    @panes = []
    @layout = []
    @DECValues = []
    @RAValues = []
    @onReady = ()-> return null
    @ready = false
  constructPanes:()=>
    for singleImage in @preLoader.imageHolder #Go through every image in the preloader
      @panes.push(new Pane(singleImage, @gl))
    for pane in @panes
      @placePane(pane)
      @pushTexture(pane)
    @onReady()
    @ready = true
  placePane:(pane)->
    RAPosition = 0
    DECPosition = 0
    while true
      if(!@RAValues[RAPosition]?)
        @RAValues[RAPosition] = pane.RA
        @layout.splice(RAPosition,0,[])
        break
      else if(pane.RA == @RAValues[RAPosition])        
        break
      else if(pane.RA < @RAValues[RAPosition])
        @RAValues.splice(RAPosition, 0, pane.RA)
        @layout.splice(RAPosition, 0, [])
        break
      RAPosition++
    #Same for DEC
    while true
      if(!@DECValues[DECPosition]?)
        @DECValues[DECPosition] = pane.DEC
        for curr in @layout
            curr.splice(DECPosition, 0, undefined)
        break
      else if(pane.DEC == @DECValues[DECPosition])        
        break
      else if(pane.DEC > @DECValues[DECPosition])
        @DECValues.splice(DECPosition, 0, pane.DEC)
        for curr in @layout
          curr.splice(DECPosition, 0, undefined)
        break
      DECPosition++
    @layout[RAPosition][DECPosition] = pane
    #alert("Current one:{#{pane.RA},#{pane.DEC}} \nRA vals: #{@RAValues} \nDec vals: #{@DECValues}\n Pos: {#{RAPosition}, #{DECPosition} }\n #{@layout}")
  getImageArray:(boundingBox)->
    @clear()
    $.get('../../db/remote/SPATIALTREE.php', boundingBox, @insertImages, 'json')
  insertImages:(arr)=>
    if(!arr?)
      console.log("SOMETHING HAS HAPPENED!!!!")
    for url in arr
      @preLoader.pushImage(url)
    @preLoader.onFullLoad(@constructPanes)
    @preLoader.startLoad()
  createCanvas:()->
    canv = document.createElement('canvas')
    max = @RAValues.length
    if(max < @DECValues.length)
      max = @DECValues
    max *= 1024
    canvasSize = 1024
    while(canvasSize < max)
      canvasSize *=2
    canv.setAttribute('width', canvasSize)
    canv.setAttribute('height', canvasSize)
    return canv
  pushTexture:(pane)->
    right = 1.0 + Math.round(pane.RA/.512)*2
    left = -1.0 + Math.round(pane.RA/.512)*2
    top = 1.0 + Math.round(pane.DEC/.512)*2
    bottom = -1.0 + Math.round(pane.DEC/.512)*2
    alert(pane.DEC)
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
    @layout = []
    @DECValues = []
    @RAValues = []
  display:()->
    @gl.viewport(0, 0, 1024, 1024);
    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT); # clear color and depth
    @gl.clearColor(0.0,0.0,0.0,1.0);
    @gl.perspectiveMatrix.makeIdentity();
    @gl.perspectiveMatrix.perspective(45, 1, 0.01, 100);
    @gl.perspectiveMatrix.lookat(@x, @y, @z, @x, @y, 0, 0, 1, 0);

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
      @gl.bindTexture(@gl.TEXTURE_2D, pane.texture);
      @gl.drawElements(@gl.TRIANGLES, 6, @gl.UNSIGNED_SHORT, i);
      i+=12
    @gl.flush();
   # @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, null);


  returnBounds:()->
    ###
    boundingBox = []
    boundingBox[0] = [(@RAValues[0]-.256)/.512, (@DECValues[0]+.256)/.512]
    boundingBox[1] = [(@RAValues[0]-.256)/.512, (@DECValues[@DECValues.length-1]-.256)/.512]
    boundingBox[2] =  [(@RAValues[@RAValues.length-1]+.256)/.512, (@DECValues[@DECValues.length-1]-.256)/.512]
    boundingBox[3] = [(@RAValues[@RAValues.length-1]+.256)/.512, (@DECValues[0]+.256)/.512]
    ###
    boundingBox = []
    boundingBox[0]=(@RAValues[0]+ @RAValues[@RAValues.length-1])/2.0
    boundingBox[0] /= .512
    boundingBox[1] = (@DECValues[0] + @DECValues[@DECValues.length-1])/2.0
    boundingBox[1] /= .512
    return boundingBox
################################################################################
#TESTING STUFF BELOW
#rawr = document.getElementById("testCanvas");
#ctx = rawr.getContext("2d");

#overlay = new Overlay()
#overlay.onReady = ()->
#  overlay.display(ctx)
#ctx.drawImage(imgur.imageHolder[1], 100,100)
#overlay.insertImages(['13473+12479E.fits.jpeg','13494+12479E.fits.jpeg','13473+13187E.fits.jpeg','13494+13187E.fits.jpeg'])
