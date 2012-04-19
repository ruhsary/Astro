<!DOCTYPE html>

<html>
<head>
    <title>Test Canvas</title>
<link type="text/css" href="css/custom-theme/jquery-ui-1.8.16.custom.css" rel="stylesheet" />
<link href="css/bootstrap.css" rel="stylesheet">
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

  gl = init();
	gl.width = 512;
	gl.height = 512;
    gl.mvMatrix.makeIdentity();
    gl.mvMatrix.translate(0,0,0);
    var canvas = document.getElementById('skycanvas2');
    
	var ctx = canvas.getContext("2d");
	var view = new View(gl, 'skycanvas2')
	view.display();
	view.requestFIRST();
	view.requestBox(function(box){
		alert(Util.prototype.pixelSpaceToDegreeSpace(box.start, {'x':-view.camera.x*.256, 'y':-view.camera.y*.256 }, {'x':256, 'y':256 },  view.camera.z/2.414213562*1.8).x);
	});

	//for IE/OPERA etc

    //console.log("{RAMin: "+ bb.RAMin+ ", RAMax: "+bb.RAMax+", DECMax: "+ bb.DecMax+", DECMin: "+bb.DecMin+"}")
	$("#radioset").buttonset();
	$('#radioset > input').click(function(){view.changeMode(parseInt(this.value));})
	    setInterval(function() {
	    	view.display();
						}, 150);
  
view.register('translate', function(v){
  	$("#RA").html("RA :"+ (-v.camera.x*.256));
  	$("#DEC").html("DEC :"+(-v.camera.y*.256));
  })
  }	


  $(document).ready(function(){
  	startStuff();

  })
</script>
</head>
<body id= "rawr">

	<div style="width: 512px; height:512px; float:left; display:inline-block; padding:20px">
		<canvas id="skycanvas2" width="512px" height="512px" style="border: solid 1px black;position: absolute; left: 1px; top: 1px; z-index: 10">Test</canvas>
		<canvas id="skycanvas" width= "512px" height="512px" style="border: solid 1px black; position: absolute; left: 1px; top: 1px">Test</canvas>
	</div>
	<div style="display:inline-block">
		<div class="ui-widget">
			<div class="ui-state-highlight ui-corner-all">
			<p><span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span>
			<strong>Hey!</strong> Sample ui-state-highlight style.</p>
			</div>
		</div>
	</div>
	   <div id="radioset">
	   	  <input type="radio" id="radio0" name="radio" value='0'/><label for="radio0">None</label>
          <input type="radio" id="radio1" name="radio" value='2'/><label for="radio1">Pan</label>
          <input type="radio" id="radio2" name="radio" value='1'/><label for="radio2">Box</label>
    	</div>
	<div style="display:inline-block; width:300px; padding-top:20px;">
		<div class="ui-widget">
			<div class="ui-state-default ui-corner-all">
			<p><span class="ui-icon ui-icon-script" style="float: left; margin-right: .3em;"></span>
			<span id="RA">RA: 0</span></p>
			</div>
		</div>
	</div>
	<div style="display:inline-block; width:300px; padding-top:20px;">
		<div class="ui-widget">
			<div class="ui-state-default ui-corner-all">
			<p><span class="ui-icon ui-icon-script" style="float: left; margin-right: .3em;"></span>
			<span id="DEC">DEC: 0</span></p>
			</div>
		</div>
	</div>
	<div style="display:inline-block; width:300px; padding-top:20px;">
		<div class="ui-widget">
			<div class="ui-state-default ui-corner-all">
			<p><span class="ui-icon ui-icon-script" style="float: left; margin-right: .3em;"></span>
			<span id="BOUND">{Bounds}</span></p>
			</div>
		</div>
	</div>
	<!--scripts-->
    <script type="text/javascript" src="js/jquery-1.6.2.min.js"></script>
    <script type="text/javascript" src="js/jquery-ui-1.8.16.custom.min.js"></script>
</body>

</html>
