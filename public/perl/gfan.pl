########################################
# SAMPLED-GFAN MODULE
########################################

use strict; 

sub sgfan() {
    my ( $ref_list_of_datafiles, $p_value, $n_nodes, $file_prefix ) = @_;
    my @list_of_datafiles = @{$ref_list_of_datafiles};
    my $datafiles_string = make_m2_string_from_array( @list_of_datafiles );

 # this function creates a file $function_filename, the functions defining the
 # finite dynamical system, and returns that file.
 # The M2 call creates this file.

    my $functionfile = $file_prefix .".functionfile.txt";
    `M2 func.m2 --silent -q -e \"sgfan( $datafiles_string, \\\"$functionfile\\\", $p_value, $n_nodes); exit 0; \"`;
    my $function_file = "$file_prefix.functionfile.txt";

    unless ( -e $function_file ) {
        $function_file = "";
    }
    return $function_file;
}

sub minsets() {
    my ( $ref_list_of_datafiles, $p_value, $n_nodes, $file_prefix ) = @_;
    my @list_of_datafiles = @{$ref_list_of_datafiles};
    my $datafiles_string = make_m2_string_from_array( @list_of_datafiles );
    
    my $functionfile = $file_prefix .".functionfile.txt";
    `M2 minsets-web.m2 --silent -q -e
    \"minsets( $datafiles_string, \\\"$functionfile\\\", $p_value, $n_nodes); exit 0; \"`;
    my $function_filename = "$file_prefix.functionfile.txt";

    unless ( -e $function_filename ) {
        $function_filename = "";
    }
    return $function_filename;
}

1;    # need to end with a true value

