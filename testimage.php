<!DOCTYPE html>

<html>
<head>
    <title>Test Canvas</title>

<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js" type="text/javascript"></script>
<script src="image.js?423" type="text/javascript"></script>
<script src="J3DI.js?13213" type="text/javascript"> </script>
<script src="J3DIMath.js" type="text/javascript"> </script>
<script src="BoxOverlay.js" type="text/javascript"> </script>
<script src="Util.js" type="text/javascript"> </script>
<script src="View.js" type="text/javascript"> </script>
<script id="fshader" type="x-shader/x-fragment">
        precision highp float;
	  
	  uniform sampler2D FIRST;
	  uniform sampler2D SDSS;
      uniform float alpha;
	  varying vec2 vTextureCoord;
  	  varying vec2 uTextureCoord;
	   void main(void) {
		    vec4 textureColor = texture2D(FIRST, vec2(vTextureCoord.s, vTextureCoord.t));
		    gl_FragColor = vec4(textureColor.rgb, textureColor.a * alpha);
			//gl_FragColor = texture2D(FIRST, vec2(vTextureCoord.s, vTextureCoord.t));//	vec4(1.0, 1.0, 1.0, 1.0);
			//gl_FragColor += .5*texture2D(SDSS, vec2(uTextureCoord.s, uTextureCoord.t));    
				
		}
</script>

<script id="vshader" type="x-shader/x-vertex">
    
		attribute vec3 aVertexPosition; // 
		attribute vec2 aTextureCoord; // FIRST texture coord
		attribute vec2 sTextureCoord; // SDSS texture coord		

		varying vec2 uTextureCoord; // varying FIRST
    		varying vec2 vTextureCoord; // varying SDSS
		
		uniform mat4 uMVMatrix;
		uniform mat4 uPMatrix;

    void main(void) {
		
  		gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0); 
  
  		vTextureCoord = aTextureCoord; // copy FIRST
		uTextureCoord = sTextureCoord; // copy SDSS

    }

</script>
 
<script type="text/javascript">	
	var currentImage;	
	var width = -1;
  	var height = -1;
  	var width_div_2 = 0;
  	var height_div_2 = 0;
    var overlay;
    var toggle = true;
	var overlays = [];
	var fov = 45.0;

		
	
  function init() {
		
    // Initialize		
   var gl = initWebGL(
        // The id of the Canvas Element
        "skycanvas",
        // The ids of the vertex and fragment shaders
        "vshader", "fshader", 
        // The clear color and depth values
        [ 0, 0, 0, 1 ], 1000);
		
		gl.mvMatrix = new J3DIMatrix4();
		gl.perspectiveMatrix = new J3DIMatrix4();

		gl.enableVertexAttribArray(0);
		gl.enableVertexAttribArray(1);
		gl.alpha = gl.getUniformLocation(gl.program, "alpha");
		gl.uniform1f(gl.alpha, 1);
		gl.u_modelViewMatrix = gl.getUniformLocation(gl.program, "uMVMatrix"); // modelview matrix
		gl.u_projectionMatrix = gl.getUniformLocation(gl.program, "uPMatrix"); // projection matrix
		gl.vertexPosition = gl.getAttribLocation(gl.program, "aVertexPosition"); // vertex position attribute
		gl.texturePosition = gl.getAttribLocation(gl.program, "aTextureCoord"); // vertex position attribute
		/* FIRST grid */
		gl.enable(gl.BLEND);
		gl.disable(gl.DEPTH_TEST);
		gl.blendFunc(gl.SRC_ALPHA, gl.ONE);
		
    return gl;
  }   	  

	function handleLoadedTexture(gl, texture) {
		    gl.bindTexture(gl.TEXTURE_2D, texture);
		    gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
		    try {
		      gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, texture.image);
		      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
		      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST);
		      gl.generateMipmap(gl.TEXTURE_2D);
		      gl.bindTexture(null);
		    } catch (e) {
		      // failure arg 5 -- something strange with Firefox and different domain ? ...
		    }
		  }
	
 
  var gl; 
  function startStuff() {
    var c = document.getElementById("skycanvas");
		c.style.width = "1024px";
		c.style.height = "1024px";
/*	var box = new BoxOverlay("skycanvas2")
	box.onBox = function(box){
		alert(box.start.x);
	}*/
    gl = init();
	gl.width = 1024;
	gl.height = 1024;
    gl.mvMatrix.makeIdentity();
    gl.mvMatrix.translate(0,0,0);
    var canvas = document.getElementById('skycanvas2');
    var ctx = canvas.getContext("2d");
	var view = new View(gl, 'skycanvas2')
	view.display();
	//view.requestFIRST();
	view.requestBox(function(box){
		alert(Util.prototype.pixelSpaceToDegreeSpace(box.start, {'x':0, 'y':0 }, {'x':512, 'y':512 }, 1.8).x);
	});
	if(window.addEventListener)
		document.getElementById('skycanvas').addEventListener('DOMMouseScroll', view.scrolling, false);
	//for IE/OPERA etc
	document.getElementById('skycanvas').onmousewheel = view.scrolling;
    //console.log("{RAMin: "+ bb.RAMin+ ", RAMax: "+bb.RAMax+", DECMax: "+ bb.DecMax+", DECMin: "+bb.DecMin+"}")
	
	    setInterval(function() {
	    	view.display();
						}, 150);
     $("#skycanvas").mousedown(function(event){
        view.md = true;
        view.cx = event.clientX;
        view.cy = event.clientY;
    
        });
      $("#skycanvas").mousemove(function(event){
        if(view.md){
	        view.translate((view.cx - event.clientX)/200.0,0,0);
	        view.translate(0,(-view.cy + event.clientY)/200.0, 0);
	        view.cx = event.clientX;
	        view.cy = event.clientY;

        }
        });
      $("#skycanvas").mouseup(function(){
        view.md = false;
        });
		
  }	
  $(document).ready(function(){
  	startStuff();
  })
</script>
</head>
<body id= "rawr">
	<div style="position: absolute; top: 20px; left: 30px;">
		<canvas id="skycanvas2" width="1024px" height="1024px" style="border: solid 1px black;position: absolute; left: 1px; top: 1px; z-index: 10">Test</canvas>
		<canvas id="skycanvas" width= "1024px" height="1024px" style="border: solid 1px black; position: absolute; left: 1px; top: 1px">Test</canvas>
	</div>

</body>
</html>
