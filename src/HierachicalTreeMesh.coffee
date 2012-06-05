class HTM
	
	@verts = []
	@VertexPositionBuffer = 0
	@VertexColorBuffer = 0
	
	constructor: (@levels) ->
		createHTM()
		
	createHTM: () =>
		
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
				for verts in triangles # iterate over vertices
					for components in verts #iterate over components
						@verts.push components # add components to list
		
		else
			for triangles in initTriangles
				subdivide(triangles, @levels-1)
			
	subdivide: (v) =>
		
		# new vertex 1
		
		w0 = []
		w0.push(v[1][0] + v[2][0]) / Math.abs(v[1][0] + v[2][0])
		unless(w0[0]?) then w0[0] = 0
		w0.push(v[1][1] + v[2][1]) / Math.abs(v[1][1] + v[2][1])
		unless(w0[1]?) then w0[1] = 0 
		w0.push(v[1][2] + v[2][2]) / Math.abs(v[1][2] + v[2][2])
		unless(w0[2]?) then w0[2] = 0 
		
		# new vertex 2
		
		w1 = [] 
		w1.push(v[0][0] + v[2][0]) / Math.abs(v[0][0] + v[2][0])
		unless(w1[0]?) then w1[0] = 0; 
		w1.push(v[0][1] + v[2][1]) / Math.abs(v[0][1] + v[2][1])
		unless(w1[1]?) then w1[1] = 0;  	
		w1.push(v[0][2] + v[2][2]) / Math.abs(v[0][2] + v[2][2])
		unless(w1[2]?) then w1[2] = 0
			
		# new vertex 3
		
		w2 = []
		w2.push(v[0][0] + v[1][0]) / Math.abs(v[0][0] + v[1][0])
		unless(w2[0]?) then w2[0] = 0
		w2.push(v[0][1] + v[1][1]) / Math.abs(v[0][1] + v[1][1])
		unless(w2[1]?) then w2[1] = 0;  	
		w2.push(v[0][2] + v[1][2]) / Math.abs(v[0][2] + v[1][2])
		unless(w2[2]?) then w2[2] = 0; 
		
		newTriangles = [
		
			[v[0], w2, w1], # 0
			[v[1], w0, w2], # 1
			[v[2], w1, w0], # 2
			[w0, w1, w2]   # 3
		]
		
		if @levels is 0
			for triangles in newTriangles # iterate over triangles
				for verts in triangles # iterate over vertices
					for components in verts #iterate over components
						@verts.push components # add components to list
	
		else
			for triangles in newTriangles # iterate over triangles
				subdivide(newTriangles[i], @levels-1);
	
	bind: (gl, shaderProgram) =>
		gl.bindBuffer(gl.ARRAY_BUFFER, @VertexPositionBuffer)
		gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, @VertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0)

		gl.bindBuffer(gl.ARRAY_BUFFER, @VertexColorBuffer);
		gl.vertexAttribPointer(shaderProgram.vertexColorAttribute, @VertexColorBuffer.itemSize, gl.FLOAT, false, 0, 0)
	
	render: (gl) =>
		gl.drawArrays(gl.TRIANGLES, 0, @VertexPositionBuffer.numItems);
        