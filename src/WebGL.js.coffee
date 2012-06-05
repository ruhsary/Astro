class window.WebGL
	
	@gl = 0
	@shaderProgram = 0
	@mvMatrix = mat4.create();
	@mvMatrixStack = [];
	@pMatrix = mat4.create();
	
	constructor: (options) ->
	
		@canvas = if options.canvas? then options.canvas else null
		
		initGL()
		initShaders()
		initBuffers()
		
	### initialize the webgl context in the canvas ###
	
	initGL: () =>
		
		try
			@gl = @canvas.getContext("experimental-webgl")
			@gl.viewportWidth = @canvas.width
			@gl.viewportHeight = @canvas.height
		catch e
			if not @gl
				alert "Could not initialise WebGL, sorry :-("
	
	### initialize shaders programs ###

	getShader:(id)=> 
	
		source = null
		
		if(id is "vertex")
		
			$.ajax
				async: false,
				url: './shader.vs',
				success: data :() ->
					source = $(data).html()
					shader = @gl.createShader(@gl.VERTEX_SHADER)
				,
			    dataType: 'html'
			
		else
			$.ajax
				async: false,
				url: './shader.fs',
				success: data:() ->
					source = $(data).html()
					shader = @gl.createShader(@gl.FRAGMENT_SHADER)
				,
				dataType: 'html'
			
		@gl.shaderSource(shader, source)
		@gl.compileShader(shader)

		if not @gl.getShaderParameter(shader, @gl.COMPILE_STATUS)
			alert @gl.getShaderInfoLog(shader)
			return null

		return shaders

	initShaders: ()=>
		
		fragmentShader = getShader(@gl, "shader-fs")
		vertexShader = getShader(@gl, "shader-vs")

		shaderProgram = @gl.createProgram()
		@gl.attachShader(@shaderProgram, vertexShader)
		@gl.attachShader(@shaderProgram, fragmentShader)
		@gl.linkProgram(@shaderProgram)

		if not @gl.getProgramParameter(@shaderProgram, @gl.LINK_STATUS) 
			alert "Could not initialise shaders"

		@gl.useProgram(shaderProgram)

		@shaderProgram.vertexPositionAttribute = @gl.getAttribLocation(@shaderProgram, "aVertexPosition")
		@gl.enableVertexAttribArray(@shaderProgram.vertexPositionAttribute)

		@shaderProgram.vertexColorAttribute = @gl.getAttribLocation(@shaderProgram, "aVertexColor")
		@gl.enableVertexAttribArray(@shaderProgram.vertexColorAttribute)

		@shaderProgram.pMatrixUniform = gl.getUniformLocation(@shaderProgram, "uPMatrix")
		@shaderProgram.mvMatrixUniform = gl.getUniformLocation(@shaderProgram, "uMVMatrix")
		
	mvPushMatrix: ()=> 
		copy = mat4.create()
		mat4.set(@mvMatrix, copy)
		@mvMatrixStack.push(copy)

	mvPopMatrix: ()=> 
		if mvMatrixStack.length is 0 
			throw "Invalid popMatrix!"
        
		mvMatrix = mvMatrixStack.pop()
    
	setMatrixUniforms: () => 
		@gl.uniformMatrix4fv(@shaderProgram.pMatrixUniform, false, @pMatrix)
		@gl.uniformMatrix4fv(@shaderProgram.mvMatrixUniform, false, @mvMatrix)
    
	preRender: () =>
		
		@gl.viewport(0, 0, @gl.viewportWidth, @gl.viewportHeight)
		@gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

		mat4.perspective(45, @gl.viewportWidth / @gl.viewportHeight, 0.1, 100.0, @pMatrix)

		mat4.identity(@mvMatrix)
		
	render: () =>
		setMatrixUniforms()