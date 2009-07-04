########################################
# DATA-CONSISTENT MODULE
########################################

use strict;

sub is_data_consistent()
{
    my ( $ref_list_of_datafiles, $p_value, $n_nodes ) = @_;
    my @list_of_datafiles = @{$ref_list_of_datafiles};
    my $datafiles_string = make_m2_string_from_array( @list_of_datafiles );

    my $is_consistent = system("M2 isConsistent.m2 --silent -q -e
    \"isConsistent( $datafiles_string, $p_value, $n_nodes); \" ");
    #print "\$is_consistent $is_consistent<br>";
    return $is_consistent;
}



1; # need to end with a true value                    
