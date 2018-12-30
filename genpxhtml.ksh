#!/bin/bash

DIR=$1
#HTML header
cat << headerend
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<style>
body {background-color:#fff8ee;}
table, th, td {
    border: 1px solid #000080;
    border-collapse: collapse;
    padding: 2px;
}

div.urls {
	position: fixed;  
	width:650px; 
	right: 0px; 
	top: 50px; 
	left: 400px;
	display:none;
	overflow: auto;
	max-height: 100%;
}
</style>

<script>

var active;
var prev_ip;

function hidediv(x) {
	x.style.display="none";
}

function showdiv(px,ip,curr_ip) {
        id=px+"_"+ip;
        if ( document.getElementById(active) && id != active ) { 
                document.getElementById(active).style.display = "none"; 
                prev_ip.style.color = "black";
        }
        if ( document.getElementById(id).style.display == "inline" ) {
                document.getElementById(id).style.display = "none";
                curr_ip.style.color = "black";
                } else {
                document.getElementById(id).style.display = "inline";
                curr_ip.style.color = "red";
                }
        active=id;
        prev_ip = curr_ip;
}


</script>

<title>Traffic statistics</title>
</head>
<body>
<h1>Content</h1>
<ul>
headerend

for i in `ls -l $DIR | grep '^d' | awk '{print $NF}' `
do
		line=`fgrep $i $DIR/$DIR.stat`
        echo "<li><a href=#$i>$line</a></li>"
done
echo "</ul><br break=all/>"

for prx in `ls -l $DIR | grep '^d' | awk '{print $NF}' `
do
    echo '<div style="width:20%;" id='$prx'><h2>'$prx'</h2>'
    echo "<table><tr><th>Count</th><th>Source</th></tr>"
    awk -v proxy=$prx '{printf ("<tr><td>%s</td><td onclick=\042showdiv(\047%s\047,\047%s\047, this)\042>%s</td></tr>\n",$1,proxy,$2,$2); }' < $DIR/$prx.ip
    echo "</table></div>"
	
	for file in $DIR/$prx/*
	do
		ip=`echo $file | sed -e 's%.*/%%'`
        echo '<div class=urls onclick=hidediv(this) id='${prx}_${ip}'>'
        echo "<h3>$prx $ip</h3>"
        echo "<table><tr><th>Count</th><th>User</th><th>URL</th></tr>"
        cat $file | sed -e 's/</#/g' -e 's/>/#/g' | awk '{print "<tr><td>",$1,"</td><td>",$2,"</td><td>",$3,"</td></tr>"}'
    	echo "</table></div>"
    done    	

#        echo "</div>"
        echo "<br break=all/>"

done


echo "</body> </html>"
