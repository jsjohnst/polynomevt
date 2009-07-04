########################################
# DISCRETIZATION MODULE
########################################

use strict;
require "make_m2_string_from_array.pl";

sub discretize_data() {
    my ( $ref_list_of_datafiles, $p_value, $file_prefix ) = @_;
    my @list_of_datafiles = @{$ref_list_of_datafiles};

    my @list_of_discretized_datafiles; 
    foreach my $datafile (@list_of_datafiles) {
        my $new_filename = $datafile; 
        $new_filename =~ s/input/discretized-input/;
        push( @list_of_discretized_datafiles, $new_filename );
    }
    
    my $datafile_string = make_m2_string_from_array( @list_of_datafiles );
    my $discretized_datafile_string = make_m2_string_from_array( @list_of_discretized_datafiles );
   
    `M2 Discretize.m2 --silent -q -e \"discretize( $datafile_string,
    $discretized_datafile_string, $p_value ); exit 0; \" > out.txt`;

    
    foreach my $discretized_datafile (@list_of_discretized_datafiles) {
        unless (-e $discretized_datafile) { 
            print "<font color=red>Problem, $discretized_datafile was not created, </font><br>";

            @list_of_discretized_datafiles = "";
            next;
        }
    }
    return @list_of_discretized_datafiles;
}

# remove_repeated_states();

1;    # need to end with a true value

