#= require WebGL

class SkyView extends WebGL
	
	@HTM = 0
	@rotation = null
	@translation = null
	@renderMode = 0
	@Math = null
	
	constructor: (options) ->
	
		super(options)
		
		@Math = new math()
		
		@HTM = new HTM(0, @gl, @Math)
		@rotation = [0.0, 0.0, 0.0]
		@translation = [0.0, 0.0, -5.0]
		@renderMode = @gl.TRIANGLES
		
		this.render()
		
	render: ()=>

		this.preRender() # set up matrices
		@HTM.bind(@gl, @shaderProgram) # bind vertices
		this.postRender(@rotation, @translation) # push matrices to Shader
		@HTM.render(@gl, @renderMode) # render to screen
		
		return
	
	keyPressed: (key) =>

		switch String.fromCharCode(key.which)
			
			when 'i' then @rotation[0]++
			when 'k' then @rotation[0]-- 
			when 'l' then @rotation[1]++
			when 'j' then @rotation[1]--
			
			when 'w' then @translation[2] += 0.1
			when 's' then @translation[2] -= 0.1
			
			when '0' then @HTM = new HTM(0,@gl,@Math)
			when '1' then @HTM = new HTM(1,@gl,@Math)
			when '2' then @HTM = new HTM(2,@gl,@Math)
			when '3' then @HTM = new HTM(3,@gl,@Math)
			when '4' then @HTM = new HTM(4,@gl,@Math)
			when '5' then @HTM = new HTM(5,@gl,@Math)
			when '6' then @HTM = new HTM(6,@gl,@Math)
			when '7' then @HTM = new HTM(7,@gl,@Math)
			when '8' then @HTM = new HTM(8,@gl,@Math)
			
		this.render()	
		return
	
	mousePress: (key) =>
		matrices = this.getMatrices()
		dir = @Math.unProj(key.x, key.y, 1, matrices[0], matrices[1], matrices[2])
		tri = @HTM.getTriangles()
		for triangle in tri
			@Math.intersectTri([0,0,-1], dir,triangle)
		return