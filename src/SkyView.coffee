#= require WebGL

class SkyView extends WebGL
	
	@HTM = 0
	
	constructor: (options) ->
		super(options)
		@HTM = new HTM()
	
	render: ()=>
		preRender() # set up matrices
		@HTM.bind() # bind vertices
		postRender(@gl, @shaderProgram) # push matrices to Shader
		@HTM.render(@gl) # render to screen
		