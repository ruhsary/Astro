class math
	constructor: ()->
	# | v1 + v2 | 
	magnitude: (v1, v2) =>
		return Math.pow(Math.pow(v1[0] + v2[0], 2) + Math.pow(v1[1] + v2[1], 2) + Math.pow(v1[2] + v2[2], 2), 0.5)
	unProj: (winX, winY, winZ, mod_mat, proj_mat, viewport) =>
		inf []		
		# invert the model view and projection matrices
		
		m = mat4.set(mod_mat, mat4.create())
		mat4.inverse(m,m)
		mat4.multiply(proj_mat, m, m)
		mat4.inverse(m,m)
		
		inf[0] = (winX - viewport[0])/viewport[2] * 2.0 - 1.0
		inf[1] = (winY - viewport[1])/viewport[3] * 2.0 - 1.0
		inf[2] = 2 * winZ - 1.0
		inf[3] = 1.0
		
		out = vec3.create()
		mat4.multiplyVec4(m, inf, out)
		
		if out[3] is 0 then return null
		
		out[3] = 1.0/out[3]
		
		return [out[0]*out[3], out[1]*out[3], out[2]*out[3]]