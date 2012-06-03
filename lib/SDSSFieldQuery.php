<?php

	header("Content-type: text/html");
	/*
	// Values for testing
	error_reporting(-1);
	$_GET["ra"] = 200;
	$_GET["dec"] = 11;
	$_GET["radius"] = 10;
	$_GET["scale"] = 0; 
	*/
	
	$file = "http://astro.cs.pitt.edu/Tim/panickos/astro-demo/lib/db/remote/searchSDSS.php";
		  
	$the_query = "SELECT distinct n.fieldid, n.distance, f.ra, f.dec, f.rerun, f.camcol, f.field, dbo.fHTMGetString(f.htmid) as htmid FROM dbo.fGetNearbyFrameEq(" . $_GET["ra"] . "," . $_GET["dec"] . "," . $_GET["radius"] . "," . $_GET["scale"] . ") as n JOIN Frame as f on n.fieldid = f.fieldid ORDER by n.distance";
	echo $the_query;		
	$url = $file;
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_POST, 1);
	// Set overlay to 1 if you want the original xml and don't use if want a json object
	$fields_string = array('query' => $the_query, 'overlay' => 1);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $fields_string);
	$output = curl_exec($ch);
	curl_close($ch);
	echo $output;
	
	
?>