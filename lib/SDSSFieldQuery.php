<?php

	header("Content-type: text/text");

	$file = "http://astro.cs.pitt.edu/Tim/panickos/astro-demo/lib/db/remote/searchSDSS.php";
		  
	$the_query = "SELECT distinct, n.fieldid, n.distance, f.ra, f.dec, f.rerun, f.camcol, f.field, dbo.fHTMGetString(f.htmid) as htmid FROM dbo.fGetNearbyFrameEq($_GET[ra],$_GET[dec],$_GET[radius],$_GET[scale]) as n JOIN Frame as f on n.fieldid = f.fieldid ORDER by n.distance";
			
	$url = $file;
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_POST, 1);
	$output = curl_exec($ch);
	
	echo $output;
	
?>