class math
	constructor: ()->
	# | v1 + v2 | 
	magnitude: (v1, v2) =>
		Math.pow(Math.pow(v1[0] + v2[0], 2) + Math.pow(v1[1] + v2[1], 2) + Math.pow(v1[2] + v2[2], 2), 0.5)
	# v1 - v2
	subtract: (v1, v2)=>
		if v1.length is not v2.length then return null
		else if v1.length is 2
			return [v1[0]-v2[0],v1[1]-v2[1]]
		else if v1.length is 3
			return [v1[0]-v2[0],v1[1]-v2[1],v1[2]-v2[2]]
		else if v1.length is 3
			return [v1[0]-v2[0],v1[1]-v2[1],v1[2]-v2[2],v1[3]-v2[3]]	
	# v1 + v2
	add: (v1, v2)=>
		if v1.length is not v2.length then return null
		else if v1.length is 2
			return [v1[0]+v2[0],v1[1]+v2[1]]
		else if v1.length is 3
			return [v1[0]+v2[0],v1[1]+v2[1],v1[2]+v2[2]]
		else if v1.length is 3
			return [v1[0]+v2[0],v1[1]+v2[1],v1[2]+v2[2],v1[3]+v2[3]]
	# v1 dot v2
	dot: (v1,v2)=>
		if v1.length is not v2.length then return null
		else if v1.length is 2
			return v1[0]*v2[0]+v1[1]*v2[1]
		else if v1.length is 3
			return v1[0]*v2[0]+v1[1]*v2[1]+v1[2]*v2[2]
		else if v1.length is 3
			return v1[0]*v2[0]+v1[1]*v2[1]+v1[2]*v2[2]+v1[3]*v2[3]
	# v1 x v2
	cross: (v1, v2)=>
		[v1[0]*v2[2]-v1[2]*v2[0], v1[2]*v2[0]-v1[0]*v2[2], v1[0]*v2[1]-v1[1]*v2[0]]
	unProj: (winX, winY, winZ, mod_mat, proj_mat, viewport) =>
		inf = []		
		# invert the model view and projection matrices
		m = mat4.set(mod_mat, mat4.create())
		mat4.inverse(m,m)
		mat4.multiply(proj_mat, m, m)
		mat4.inverse(m,m)
				
		inf.push ( (winX - viewport[0])/viewport[2] * 2.0 - 1.0 )
		inf.push ( (winY - viewport[1])/viewport[3] * 2.0 - 1.0 )
		inf.push (2 * winZ - 1.0)
		inf.push 1.0
		
		out = [0,0,0,0]
		mat4.multiplyVec4(m, inf, out)
				
		if out[3] is 0 then return null
		
		out[3] = 1.0/out[3]
				
		return [out[0]*out[3], out[1]*out[3], out[2]*out[3]]
	
	intersectTri: (position, direction, triangle) =>
	
		v_0 = triangle[0]
		v_1 = triangle[1]
		v_2 = triangle[2]
		
		E_1 = this.subtract(v_1, v_0)
		E_2 = this.subtract(v_2, v_0)
		
		T = this.subtract(position, v_0)
		
		Q = this.cross(T, E_1)
		
		return
		
