#= require WebGL

class SkyView extends WebGL
	
	@HTM = 0
	
	constructor: (options) ->
		super(options)
		@HTM = new HTM(3, @gl)
		this.render()
		
	render: ()=>
		this.preRender() # set up matrices
		@HTM.bind(@gl, @shaderProgram) # bind vertices
		this.postRender() # push matrices to Shader
		@HTM.render(@gl) # render to screen
		