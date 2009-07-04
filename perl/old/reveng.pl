#!/usr/bin/perl

##################################
# Author: Brandy Stigler         #
# Original code: Hussein Vastani #
# Date: May 20, 2005             #
##################################

use CGI qw( :standard );
use Fcntl qw( :flock );

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# html page stuff

print header, start_html( -title=>'D-MAPs Web Interface', -script=>{-language=>'JavaScript',-src=>'reveng.js'});
print start_multipart_form(-name=>'form1', -method =>"POST", -onSubmit=>"return validate()");
print "<div style=\"font-family:Verdana,Arial\"><div id=\"tipDiv\" style=\"position:absolute\; visibility:hidden\; z-index:100\"></div>";

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# start of interface

print "<table bgcolor=\"#ffffff\" width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"10\">";
print "<tr><td align=\"center\" colspan=\"2\"><b><font size=\"5\">Discrete Models using Algebra and Polynomials (D-MAPs)</font></b><p>";
print "</td></tr>";

####################
# Data description #
####################

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Input Data box

print "<tr><td><table align=\"center\" border=\"0\" bgcolor=\"#ffffff\" cellpadding=\"1\" cellspacing=\"0\">";
print "<tr><td><table border=\"1\" bgcolor=\"#FFFFcc\" width=\"100%\" cellspacing=\"0\" cellpadding=\"3\">";
print "<tr><td bgcolor=\"#FF8000\"><strong><font color=\"#FFFFFF\">Input Data</font></strong></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";

print "<tr><td>Enter number of variables: ", textfield(-name=>'n_nodes', -size=>2, -maxlength=>2, -default=>3);
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/visualizer/tutorial.html#N\" onmouseover=\"doTooltip(event,0)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a></td></tr>";

print "<tr><td>Enter number of variable orders: ",textfield(-name=>'var_order', -size=>2, -maxlength=>2, -default=>10),"</td></tr>";

print "<tr><td>Select range of data:";
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/visualizer/tutorial.html#F\" onmouseover=\"doTooltip(event,1)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a><br>";
print radio_group(-name=>'translate_box', -values=>['Continuous','Discrete'], -default=>'Discrete', -linebreak=>'true');
print "&nbsp\;&nbsp\;&nbsp\;&nbsp\;- Enter number of states per variable: ",textfield(-name=>'p_value', -size=>2, -maxlength=>2, -default=>3),"</td></tr>";

print "<tr><td>Upload data file: ",filefield(-name=>'upload_file'),"<br>";
print "<center><b> OR </b></center><br>";

print "Upload data file names: ",filefield(-name=>'upload_filenames'),"<br>";
print "Upload data folder: ",filefield(-name=>'upload_folder'),"<br>";


print "</font></td></tr></table>";

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output Functions box

print "<td><table cellSpacing=\"0\" cellPadding=\"1\" align=\"center\" bgColor=\"#ababab\" border=\"0\"><tr><td><table cellSpacing=\"0\" cellPadding=\"1\" width=\"100%\" bgColor=\"#ffffcc\" border=\"0\">";
print "<tr><td bgColor=\"#ff8000\"><strong><font color=\"#ffffff\">Output Model</font></strong></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";

print "<tr><td>Output functions: ",filefield(-name=>'upload_file');
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/visualizer/tutorial.html#F\" onmouseover=\"doTooltip(event,2)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a>";
print "</td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";
print "</table></td>";




print "<table align=\"center\" border=\"0\" bgcolor=\"#ABABAB\" cellpadding=\"1\" cellspacing=\"0\"><tr><td>";
print"<table border=\"0\" bgcolor=\"#FFFFCC\" width=\"100%\" cellspacing=\"0\" cellpadding=\"1\"><tr>";
print"<td bgcolor=\"#FF8000\"><b><font color=\"#FFFFFF\">Additional Output Specification &nbsp\;<span style=\"background-color:#808080\">(optional)</span></font></b>";

print"&nbsp\;&nbsp\;&nbsp\;</td>";
print"</tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr><tr><td><font size=\"2\">View";
print"&nbsp\;<a href=\"http://dvd.vbi.vt.edu/visualizer/tutorial.html#G\" onmouseover=\"doTooltip(event,6)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a><br>";
print"<font color=\"#006C00\"><i>select graph(s) to view and image format</i></font><br>";
print checkbox_group(-name=>'statespace', -value=>'State space graph', -label=>'State space graph'),"&nbsp\;&nbsp\;&nbsp\;", popup_menu(-name=>'SSformat',-values=>['*.gif','*.jpg','*.png','*.ps']),"<br>";
print checkbox_group(-name=>'regulatory', -value=>'Dependency graph', -label=>'Dependency graph'), "&nbsp\;&nbsp\;&nbsp\;", popup_menu(-name=>'DGformat',-values=>['*.gif','*.jpg','*.png','*.ps']);
print "</font></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr></table></td></tr></table></td></tr>";

print "<tr><td><br></td></tr>";
print "<tr><td align=\"center\" colspan=\"2\">",submit('button_name','Generate')," <br><font color=\"#006C00\"><br><i>Results will be displayed below.</i></font></td></tr></table></div>";


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# end of interface

print "</table>";
print "<hr>";
print end_form;

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# end of html page

print end_html();

