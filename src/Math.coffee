class math
	constructor: ()->
	# | v1 + v2 | 
	magnitude: (v1, v2) =>
		Math.pow(Math.pow(v1[0] + v2[0], 2) + Math.pow(v1[1] + v2[1], 2) + Math.pow(v1[2] + v2[2], 2), 0.5)
	# | norm v1 |
	norm: (v1) =>
		mag = Math.sqrt(Math.pow(v1[0],2) + Math.pow(v1[1],2) + Math.pow(v1[2],2))
		[v1[0]/mag,v1[1]/mag,v1[2]/mag]
	# v1 - v2
	subtract: (v1, v2)=>
		if v1.length is not v2.length then return null
		else if v1.length is 2
			return [v1[0]-v2[0],v1[1]-v2[1]]
		else if v1.length is 3
			return [v1[0]-v2[0],v1[1]-v2[1],v1[2]-v2[2]]
		else if v1.length is 4
			return [v1[0]-v2[0],v1[1]-v2[1],v1[2]-v2[2],v1[3]-v2[3]]	
	# v1 + v2
	add: (v1, v2)=>
		if v1.length is not v2.length then return null
		else if v1.length is 2
			return [v1[0]+v2[0],v1[1]+v2[1]]
		else if v1.length is 3
			return [v1[0]+v2[0],v1[1]+v2[1],v1[2]+v2[2]]
		else if v1.length is 4
			return [v1[0]+v2[0],v1[1]+v2[1],v1[2]+v2[2],v1[3]+v2[3]]
	# v1 dot v2
	dot: (v1,v2)=>
		if v1.length is not v2.length then return null
		else if v1.length is 2
			return v1[0]*v2[0]+v1[1]*v2[1]
		else if v1.length is 3
			return v1[0]*v2[0]+v1[1]*v2[1]+v1[2]*v2[2]
		else if v1.length is 4
			return v1[0]*v2[0]+v1[1]*v2[1]+v1[2]*v2[2]+v1[3]*v2[3]
	# v1 x v2
	cross: (v1, v2)=>
		[v1[1]*v2[2]-v1[2]*v2[1], v1[2]*v2[0]-v1[0]*v2[2], v1[0]*v2[1]-v1[1]*v2[0]]
	unProj: (winX, winY, winZ, mod_mat, proj_mat, viewport) =>
		inf = []		
		# invert the model view and projection matrices
		m = mat4.set(mod_mat, mat4.create())
		mat4.inverse(m,m)
		mat4.multiply(proj_mat, m, m)
		mat4.inverse(m,m)
				
		inf.push ( (winX - viewport[0])/viewport[2] * 2.0 - 1.0 )
		inf.push ( (winY - viewport[1])/viewport[3] * 2.0 - 1.0 )
		inf.push (2.0 * winZ - 1.0)
		inf.push 1.0
		
		out = [0,0,0,0]
				
		mat4.multiplyVec4(m, inf, out)
							
		if out[3] is 0 then return null
		
		out[3] = 1.0/out[3]
				
		return [out[0]*out[3], out[1]*out[3], out[2]*out[3]]
	
	intersectTri: (position, direction, triangle, near, far) =>
	
		console.log "dir: ",direction

		###
		v_0 = triangle[2]
		v_1 = triangle[1]
		v_2 = triangle[0]
		console.log "vertices: ",v_0,v_1,v_2
		
		E_1 = this.subtract(v_1, v_0)
		E_2 = this.subtract(v_2, v_0)
		console.log "e1,e2: ",E_1,E_2

		T = this.subtract(position, v_0)
		console.log "T: ",T

		Q = this.cross(T, E_1)
		P = this.cross(direction, E_2)
		console.log "q,p: ",Q,P
		
		det = 1.0/this.dot(P,E_1)
		console.log "det: ",det

		t = det * this.dot(Q, E_2)
		u = det * this.dot(P,T)
		v = det * this.dot(Q,direction)
		console.log "t,u,v: ", t, u, v
		###
		
		v_0 = this.subtract(triangle[0], triangle[1])
		v_1 = this.subtract(triangle[2], triangle[1])
		v_2 = this.subtract(direction, triangle[1])

		dot00 = this.dot(v_0,v_0)
		dot01 = this.dot(v_0,v_1)
		dot02 = this.dot(v_0,v_2)
		dot11 = this.dot(v_1,v_1)
		dot12 = this.dot(v_1,v_2)
		
		invDenom = 1.0 / (dot00 * dot11 - dot01 * dot01)
		
		u = (dot11 * dot02 - dot01 * dot12) * invDenom
		v = (dot00 * dot12 - dot01 * dot02) * invDenom
		
		console.log u, v
		
		if u >= 0.0 && v >= 0.0 && (u+v) < 1.0 
			return "Hit!"
		else 
			return "Not intersected!"
		
