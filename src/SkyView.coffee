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
		@level = 0
		
		@HTM = new HTM(@level, @gl, @Math)
		@rotation = [0.0, 0.0, 0.0]
		@translation = [0.0, 0.0, -5.0]
		@renderMode = @gl.TRIANGLES
		
		this.render()
	
	getScale: =>
		(180.0 * (1.0-@translation[2]))/2
	getLevel: =>
		180.0/(Math.pow(2,@level+1))
	render: ()=>

		this.preRender() # set up matrices
		@HTM.bind(@gl, @shaderProgram) # bind vertices
		this.postRender(@rotation, @translation) # push matrices to Shader
		@HTM.render(@gl, @renderMode) # render to screen
		
		return
	
	keyPressed: (key) =>

		console.log this.getScale(), this.getLevel()

		switch String.fromCharCode(key.which)
			
			when 'i' then @rotation[0]++
			when 'k' then @rotation[0]-- 
			when 'l' then @rotation[1]++
			when 'j' then @rotation[1]--
			
			when 'w' 
				@translation[2] += 0.1
				if this.getScale() < this.getLevel()
					@level++
					@HTM = new HTM(@level,@gl,@Math)
			when 's'
				@translation[2] -= 0.1
				if this.getScale() > this.getLevel()
					@level--
					@HTM = new HTM(@level,@gl,@Math)
					
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
		near = @Math.unProj(key.x, key.y, 0, matrices[0], matrices[1], matrices[2])
		far = @Math.unProj(key.x, key.y, 1, matrices[0], matrices[1], matrices[2])
		dir = @Math.subtract(near,far)
		tri = @HTM.getTriangles()
		for triangle in tri
			console.log @Math.intersectTri([0,0,0], dir,triangle)
		return