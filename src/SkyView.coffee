class SkyView extends webGL
	
	@HTM = 0
	
	constructor: () ->
		super()
		@HTM = new HTM()
	
	render: ()=>
		preRender() # set up matrices
		@HTM.bind() # bind vertices
		postRender(@gl, @shaderProgram) # push matrices to Shader
		@HTM.render(@gl) # render to screen
		