class window.WebGL
	
	@gl = 0
	@shaderProgram = 0
	@mvMatrix = 0
	@mvMatrixStack = null
	@pMatrix = 0
	
	constructor: (options) ->
	
		@canvas = if options.canvas? then options.canvas else null
		
		this.initGL()
		this.initShaders()
		
		@gl.clearColor(0.0, 0.0, 0.0, 1.0);
		@gl.enable(@gl.DEPTH_TEST);
		
		@mvMatrix = mat4.create()
		@pMatrix = mat4.create()
		@mvMatrixStack = []
		
		return
				
	### initialize the webgl context in the canvas ###
	
	initGL: () =>
		
		try
			@gl = @canvas.getContext("experimental-webgl")
			@gl.viewportWidth = @canvas.width
			@gl.viewportHeight = @canvas.height
		catch e
			if not @gl
				alert "Could not initialize WebGL, sorry :-("
	
	### initialize shaders programs ###

	getShader:(id)=> 
	
		source = null
		shader = null
		
		if(id is "vertex")
			$.ajax
				async: false,
				url: './src/shader.vs',
				success: (data)=>
					source = $(data).html()
					shader = @gl.createShader(@gl.VERTEX_SHADER)
					return
				,
			    dataType: 'html'
		else
			$.ajax
				async: false,
				url: './src/shader.fs',
				success: (data)=>
					source = $(data).html()
					shader = @gl.createShader(@gl.FRAGMENT_SHADER)
					return
				,
				dataType: 'html'

	
		@gl.shaderSource(shader, source)
		@gl.compileShader(shader)

		if not @gl.getShaderParameter(shader, @gl.COMPILE_STATUS)
			alert @gl.getShaderInfoLog(shader)
			return null

		return shader

	initShaders: ()=>
		
		fragmentShader = this.getShader("fragment")
		vertexShader = this.getShader("vertex")

		@shaderProgram = @gl.createProgram()
		@gl.attachShader(@shaderProgram, vertexShader)
		@gl.attachShader(@shaderProgram, fragmentShader)
		@gl.linkProgram(@shaderProgram)

		if not @gl.getProgramParameter(@shaderProgram, @gl.LINK_STATUS) 
			alert "Could not initialise shaders"

		@gl.useProgram(@shaderProgram)

		@shaderProgram.vertexPositionAttribute = @gl.getAttribLocation(@shaderProgram, "aVertexPosition")
		@gl.enableVertexAttribArray(@shaderProgram.vertexPositionAttribute)
		
		@shaderProgram.vertexColorAttribute = @gl.getAttribLocation(@shaderProgram, "aVertexColor")
		@gl.enableVertexAttribArray(@shaderProgram.vertexColorAttribute)
		
		@shaderProgram.pMatrixUniform = @gl.getUniformLocation(@shaderProgram, "uPMatrix")
		@shaderProgram.mvMatrixUniform = @gl.getUniformLocation(@shaderProgram, "uMVMatrix")
		return
	
	getMatrices: ()=>
		[@mvMatrix, @pMatrix, [0,0,@gl.viewportWidth, @gl.viewportHeight] ]
		
	mvPushMatrix: ()=> 
		copy = mat4.create()
		mat4.set(@mvMatrix, copy)
		@mvMatrixStack.push(copy)
		return

	mvPopMatrix: ()=> 
		if @mvMatrixStack.length is 0 
			throw "Invalid popMatrix!"
		@mvMatrix = @mvMatrixStack.pop()
		return
    
	setMatrixUniforms: () => 
		@gl.uniformMatrix4fv(@shaderProgram.pMatrixUniform, false, @pMatrix)
		@gl.uniformMatrix4fv(@shaderProgram.mvMatrixUniform, false, @mvMatrix)
		return

	degToRad: (deg)=>
		deg * Math.PI / 180.0

	preRender: () =>
		
		@gl.viewport(0, 0, @gl.viewportWidth, @gl.viewportHeight)
		@gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)

		mat4.perspective(45, @gl.viewportWidth / @gl.viewportHeight, 0.0001, 100.0, @pMatrix)
		mat4.identity(@mvMatrix)
		
		return
			
	postRender: (rotation, translation) =>
				
#		this.mvPushMatrix()
		
		mat4.translate(@mvMatrix, translation);
		mat4.rotate(@mvMatrix, this.degToRad(rotation[0]), [1,0,0])
		mat4.rotate(@mvMatrix, this.degToRad(rotation[1]), [0,1,0])
		mat4.rotate(@mvMatrix, this.degToRad(rotation[2]), [0,0,1])
		
		this.setMatrixUniforms()
		
#		this.mvPopMatrix()
		
		return
