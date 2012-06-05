class webGL
	
	@gl = 0
	@shaderProgram = 0
	
	constructor: (canvas) ->
		
		initGL(canvas)
		initShaders()
		initBuffers()
		
	### initialize the webgl context in the canvas ###
	
	initGL: (canvas) =>
		
		try
			@gl = canvas.getContext("experimental-webgl")
			@gl.viewportWidth = canvas.width
			@gl.viewportHeight = canvas.height
		catch e
			if not @gl
				alert "Could not initialise WebGL, sorry :-("
	
	### initialize shaders programs ###
				
	initShaders: =>
		fragmentShader = getShader(gl, "shader-fs")
		vertexShader = getShader(gl, "shader-vs")

		shaderProgram = @gl.createProgram()
		@gl.attachShader(shaderProgram, vertexShader)
		@gl.attachShader(shaderProgram, fragmentShader)
		@gl.linkProgram(shaderProgram)

		if not @gl.getProgramParameter(shaderProgram, @gl.LINK_STATUS) 
			alert "Could not initialise shaders"

		@gl.useProgram(shaderProgram)

		shaderProgram.vertexPositionAttribute = @gl.getAttribLocation(shaderProgram, "aVertexPosition")
		@gl.enableVertexAttribArray(shaderProgram.vertexPositionAttribute)

		shaderProgram.vertexColorAttribute = @gl.getAttribLocation(shaderProgram, "aVertexColor")
		@gl.enableVertexAttribArray(shaderProgram.vertexColorAttribute)

		shaderProgram.pMatrixUniform = gl.getUniformLocation(shaderProgram, "uPMatrix")
		shaderProgram.mvMatrixUniform = gl.getUniformLocation(shaderProgram, "uMVMatrix")

	preRender: () =>
		
		@gl.viewport(0, 0, @gl.viewportWidth, @gl.viewportHeight)
		@gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

		mat4.perspective(45, @gl.viewportWidth / @gl.viewportHeight, 0.1, 100.0, pMatrix)

		mat4.identity(mvMatrix)
		
	render:() =>
		setMatrixUniforms()