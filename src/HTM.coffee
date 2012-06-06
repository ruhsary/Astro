class HTM
	
	@verts = null
	@VertexPositionBuffer = 0
	
	constructor: (@levels, @gl) ->
		this.createHTM()

	createHTM: () =>
		
		@verts = []
		
		initTriangles = [
			# T0
			[[1.0, 0.0, 0.0],
			[0.0, 0.0, -1.0],
			[0.0, 1.0, 0.0]],
			# T1
			[[0.0, 1.0, 0.0],
			[0.0, 0.0, -1.0],
			[-1.0, 0.0, 0.0]],
			# T2
			[[-1.0, 0.0, 0.0],
			[ 0.0, 0.0, -1.0],
			[ 0.0, -1.0, 0.0]],
			# T4
			[[0.0, -1.0, 0.0],
			[0.0, 0.0, -1.0],
			[1.0, 0.0, 0.0]],
			# T5
			[[1.0, 0.0, 0.0],
			[0.0, 0.0, 1.0],
			[0.0, -1.0, 0.0]],
			# T6
			[[0.0, -1.0, 0.0],
			[0.0, 0.0, 1.0],
			[-1.0, 0.0, 0.0]],
			# T7
			[[-1.0, 0.0, 0.0],
			[0.0, 0.0, 1.0],
			[0.0, 1.0, 0.0 ]],
			# T8
			[[0.0, 1.0, 0.0],
			[0.0, 0.0, 1.0],
			[1.0, 0.0, 0.0 ]]
		]
		
		if @levels is 0
			for triangles in initTriangles # iterate over triangles
				for vert in triangles # iterate over vertices
					for component in vert
						@verts.push component
		else
			for triangles in initTriangles
				this.subdivide(triangles, @levels-1)
				
		@VertexPositionBuffer = @gl.createBuffer()
		@gl.bindBuffer(@gl.ARRAY_BUFFER, @VertexPositionBuffer)

		@gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(@verts), @gl.STATIC_DRAW)
		@VertexPositionBuffer.itemSize = 3
		@VertexPositionBuffer.numItems = 8 * Math.pow(4,@levels) * 3
		return
	
	magnitude: (v1, v2) =>
		mag = Math.sqrt(v1[0]*v2[0]+v1[1]*v2[1]+v1[2]*v2[2])
	subdivide: (v,l) =>
				
		# new vertex 1
		mag = this.magnitude(v[1], v[2])
		
		w0 = []
		w0.push((v[1][0] + v[2][0]) / mag)
		unless(w0[0]?) then w0[0] = 0
		w0.push((v[1][1] + v[2][1]) / mag)
		unless(w0[1]?) then w0[1] = 0 
		w0.push((v[1][2] + v[2][2]) / mag)
		unless(w0[2]?) then w0[2] = 0 
		
		# new vertex 2
		mag = this.magnitude(v[0], v[2])
		
		w1 = [] 
		w1.push((v[0][0] + v[2][0]) / mag)
		unless(w1[0]?) then w1[0] = 0
		w1.push((v[0][1] + v[2][1]) / mag)
		unless(w1[1]?) then w1[1] = 0  	
		w1.push((v[0][2] + v[2][2]) / mag)
		unless(w1[2]?) then w1[2] = 0
			
		# new vertex 3
		mag = this.magnitude(v[0], v[1])
		
		w2 = []
		w2.push((v[0][0] + v[1][0]) / mag)
		unless(w2[0]?) then w2[0] = 0
		w2.push((v[0][1] + v[1][1]) / mag)
		unless(w2[1]?) then w2[1] = 0  	
		w2.push((v[0][2] + v[1][2]) / mag)
		unless(w2[2]?) then w2[2] = 0 
		
		newTriangles = [
		
			[v[0], w2, w1], # 0
			[v[1], w0, w2], # 1
			[v[2], w1, w0], # 2
			[w0, w1, w2]   # 3
		]
		
		if l is 0
			for triangles in newTriangles # iterate over triangles
				for vert in triangles # iterate over vertices
					for component in vert
						@verts.push component
		else
			for triangles in newTriangles # iterate over triangles
				this.subdivide(triangles, l-1);
		return
	bind: (gl, shaderProgram) =>
		gl.bindBuffer(gl.ARRAY_BUFFER, @VertexPositionBuffer)
		gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, @VertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0)
		return
	render: (gl) =>
		gl.drawArrays(gl.TRIANGLES, 0, @VertexPositionBuffer.numItems);
		return