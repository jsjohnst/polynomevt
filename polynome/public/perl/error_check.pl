########################################
# different routines to validate the user input
########################################

use strict;

# @param: # of nodes, discretized data
# checks whether # of columns in data is correct
# What else should be checked?
# return 0 on error
sub data_has_correct_format() {
    my ( $n_nodes, $file ) = @_;
    open FILE, "<$file" or die $!;
    my $line;

    my $counter = 0;
    while (<FILE>) {
        $counter++;
        $line = $_;
        chomp($line);

        if ($line =~ /^\s*#/ ) {
            # skip ahead to next line
            next;
        }
        my @entries = split( /\ +/, $line );

        ## check whether they are all numbers
        foreach my $entry (@entries) {
            unless ($entry =~ /^[-+]?\d*\.?\d*$/) {
                print "In line $counter of the input data, $entry is not the
                right format. Data in the time courses have to be integers or decimals. 
                <br>";
                return (0);
            }
#            if ($entry =~ /^[-+]?\d*\.?\d*$/) {
#                print "match $entry<br>";
#            }
#            else {
#                print "no match $entry <br>";
#            }
        }

        my $number_of_elements = scalar(@entries);
        if ( $number_of_elements != $n_nodes ) { 
            if ( $number_of_elements == 0 ) {
                print "You entered a blank line. If you want to enter
                multiple time course data sets, please use lines beginning with # as
                delimiter.<br>"
            }
            else {
                print "You specified $n_nodes as number of nodes, but row<br>
                $line <br> 
                in the data has $number_of_elements entries.<br>";
            }
            return (0);
        }
    }
    return (1);
}

1;
