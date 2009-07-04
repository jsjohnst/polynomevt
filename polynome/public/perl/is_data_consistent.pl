########################################
# DATA-CONSISTENT MODULE
########################################

use strict;

sub is_data_consistent()
{
    my ( $ref_list_of_datafiles, $p_value, $n_nodes, $tmp_file ) = @_;
    my @list_of_datafiles = @{$ref_list_of_datafiles};
    my $datafiles_string = make_m2_string_from_array( @list_of_datafiles );

	my $is_consistent = 0;
	
	my $pid = fork();
	if(not defined $pid) {
		print "could not fork!";
	} elsif($pid == 0) {
		# inside child
	    my $ret = system("M2 isConsistent.m2 --silent -q -e \"isConsistent( $datafiles_string, $p_value, $n_nodes); \" > /dev/null 2>&1");
		`echo $ret > $tmp_file`;
		exit(0);
	} else {
		waitpid($pid, 0);
		$is_consistent = `cat $tmp_file`;
	}
	
    #print "\$is_consistent $is_consistent<br>";
    return $is_consistent;
}



1; # need to end with a true value                    
