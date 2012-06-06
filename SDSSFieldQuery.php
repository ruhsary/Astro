<?php

	header("Content-type: text/html");

		error_reporting(-1);
		$_GET["ra"] = 200;
		$_GET["dec"] = 11;
		$_GET["radius"] = 10;
		$_GET["scale"] = 0; 
		
/* parse the xml to get the fields to wget with*/

	function parseSDSS($output) {

      $xml = new SimpleXMLElement($output);
        
				$xpath_run = "//field[@col='run']";
        $xpath_camcol  = "//field[@col='camcol']";
				$xpath_rerun = "//field[@col='rerun']";
        $xpath_field  = "//field[@col='field']";

        $out_run = $xml->xpath($xpath_run);
        $out_camcol = $xml->xpath($xpath_camcol);
				$out_rerun = $xml->xpath($xpath_rerun);
        $out_field = $xml->xpath($xpath_field);
        
        $imagefields = array();
        
        $i = 0;
        while(list( , $node) = each($out_run)) {
            $imagefields[$i] = array(trim($node), 0);
            $i++;
        }
        
        $i = 0;
        while(list( , $node) = each($out_camcol)) {
            $imagefields[$i][1] = trim($node);
            $i++;
        }

				$i = 0;
	        while(list( , $node) = each($out_rerun)) {
	            $imagefields[$i][2] = trim($node);
	            $i++;
	        }
				$i = 0;
	      while(list( , $node) = each($out_field)) {
	          $imagefields[$i][3] = trim($node);
	          $i++;
	      }
        
        return $imagefields;
  }

/* parse the query and wget images */

	function getImages($output){
		$out = parseSDSS($output);
	
		// Construct a file with a list of the jpeg urls, one on each line
		foreach($out as $imageFields){
			/*
			* $url = http://das.sdss.org/imaging/$run/$rerun/Zoom/$camcol/$filename
			*	$filename = fpC-$run-$camcol-$rerun-$field-z00.jpeg (z00 = zoom in 00,10,15,20,30)
			* In $filename, run is padded to a total of 6 digits and field is padded to a total of 4 digits
			* $imageFields = array(run, camcol, rerun, field) 
			*/
			$url = "http://das.sdss.org/imaging/" . $imageFields[0] . "/" . $imageFields[2] . "/Zoom/" . $imageFields[1] . "/fpC-" . str_pad($imageFields[0],6,"0",STR_PAD_LEFT) . "-" . $imageFields[1] . "-" . $imageFields[2] . "-" . str_pad($imageFields[3],4,"0",STR_PAD_LEFT) . "-z00.jpeg";
			
			// Testing - prints out each url as a link
			echo "<a href='$url'/> $url </a> <br />";
		}
		/*
		$inputfile = "sdss-wget.lis";
		$cmd = "wget -nd -nH -q -i $inputfile";
		exec($cmd);
		*/
	}
	
	$file = "http://astro.cs.pitt.edu/Tim/panickos/astro-demo/lib/db/remote/searchSDSS.php";
		  
	$the_query = "SELECT distinct n.fieldid, n.distance, f.ra, f.dec, f.run, f.rerun, f.camcol, f.field, dbo.fHTMGetString(f.htmid) as htmid FROM dbo.fGetNearbyFrameEq(" . $_GET["ra"] . "," . $_GET["dec"] . "," . $_GET["radius"] . "," . $_GET["scale"] . ") as n JOIN Frame as f on n.fieldid = f.fieldid ORDER by n.distance";
//	echo $the_query;		
	$url = $file;
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_POST, 1);
	// Set overlay to 1 if you want the original xml and don't use if want a json object
	$fields_string = array('query' => $the_query, 'overlay' => 1);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $fields_string);
	// Return the output as a string instead of printing it out
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
	$output = curl_exec($ch);
	curl_close($ch);
	getImages($output);
	
?>