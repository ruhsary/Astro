<?php

	header("Content-type: text/plain");

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
            $imagefields[$i] = array((int)$node, 0);
            $i++;
        }
        
        $i = 0;
        while(list( , $node) = each($out_camcol)) {
            $imagefields[$i][1] = (int)$node;
            $i++;
        }

				$i = 0;
	        while(list( , $node) = each($out_rerun)) {
	            $imagefields[$i][2] = (int)$node;
	            $i++;
	        }
				$i = 0;
	      while(list( , $node) = each($out_field)) {
	          $imagefields[$i][3] = (int)$node;
	          $i++;
	      }
        
        return $imagefields;
  }

/* parse the query and wget images */

	function getImages($output){
		
		echo "before!";
		
		$out = parseSDSS($output);
				
		echo "after!";
				
		foreach($out as $imageFields){
			
			echo "hello!";
			
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
	$output = curl_exec($ch);
	curl_close($ch);

	getImages($output);
	
?>