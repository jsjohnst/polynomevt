########################################
# WIRING DIAGRAM SUBROUTINE
########################################

## FBH Create .dot file and picture of wiring diagram as discribed in the
## discretized data file
## return: graph of wiring diagram

use strict;

sub generate_wiring_diagram() {
    my $graph;
    my ( $ref_list_of_datafiles, $p_value, $n_nodes, $file_format, $file_prefix ) = @_;
    my $dot_file = $file_prefix. ".wiring-diagram.dot";
    my @list_of_datafiles = @{$ref_list_of_datafiles};
    my $datafiles_string = make_m2_string_from_array( @list_of_datafiles );

	my $pid = fork();
	if(not defined $pid) {
		print "could not fork!";
	} elsif($pid == 0) {
		# inside child
		`M2 wd.m2 --silent -q -e \"wd( $datafiles_string, \\\"$dot_file\\\",  $p_value, $n_nodes );exit 0;\" > /dev/null 2>&1`;
		exit(0);
	} else {
		waitpid($pid, 0);
	}

    if ( -e $dot_file ) {
        $graph = $file_prefix. ".wiring-diagram." . $file_format;
        `dot -T$file_format -o$graph $dot_file`;
    }
    else {
        print "<font color=red>Problem in generate_wiring_diagram</font><br>";
        die("generate_wiring_diagram unsuccessful");
    }
    `rm -f $dot_file`;
    unless (-e $graph) { 
        print "<font color=red>Problem, .$file_format file was not created,
        check whether apache can call dot</font><br>";
        $graph = "";
    }
    return ($graph);
}

sub minsets_generate_wiring_diagram() {
    my $graph;
    my ( $ref_list_of_datafiles, $p_value, $n_nodes, $file_format, $file_prefix ) = @_;
    my $dot_file = $file_prefix. ".wiring-diagram.dot";
    my @list_of_datafiles = @{$ref_list_of_datafiles};
    my $datafiles_string = make_m2_string_from_array( @list_of_datafiles );
    `M2 minsets-web.m2 --silent -q -e \"minsetsWD( $datafiles_string, \\\"$dot_file\\\",  $p_value, $n_nodes );exit 0;\"`;
    
    if ( -e $dot_file ) {
        $graph = $file_prefix. ".wiring-diagram." . $file_format;
        `dot -T$file_format -o$graph $dot_file`;
    }
    else {
        print "<font color=red>Problem in minsets_generate_wiring_diagram</font><br>";
        die("minsets_generate_wiring_diagram unsuccessful");
    }
    `rm -f $dot_file`;
    unless (-e $graph) { 
        print "<font color=red>Problem, .$file_format file was not created,
        check whether apache can call dot</font><br>";
        $graph = "";
    }
    return ($graph);
}

1

### FBH without this value require wd.pl generates the following error: 
###
### [Tue Jun 30 20:18:53 2009] [error] [client ::1] wd.pl did not return a
### true value at /Users/fhinkel/Sites/polynome/polynome.pl line 33., referer:
### http://localhost/~fhinkel/polynome/polynome.pl
###
### We should check why this is happening

########################################
# end of generate_wiring_diagram
########################################
