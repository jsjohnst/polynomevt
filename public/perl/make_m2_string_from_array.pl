########################################
# take an array of filenames and create a string in the format that can be
# passed to M2, e.g., {\\\"a.txt\\\",\\\"b.txt\\\"} 
########################################

use strict;

sub make_m2_string_from_array {
    my ( @list_of_filenames )  = @_;
    my $count = 0;
    my $M2_string = "{";
    foreach my $filename (@list_of_filenames) {
	if ($count > 0) {
	    $M2_string = $M2_string . ",";
	}
	$count++;
	$M2_string = $M2_string . "///";
        $M2_string = $M2_string . $filename;
	$M2_string = $M2_string . "///";
    }
    $M2_string = $M2_string . "}";
    return $M2_string;
}

1;    # need to end with a true value

