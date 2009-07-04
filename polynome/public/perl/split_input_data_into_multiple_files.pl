########################################
# Split the input file into a list of files, use # as delimeter 
########################################

use strict;

sub split_input_data_into_multiple_files {
    my ( $file ) = @_;
    my @list_of_datafiles;
    open FILE, "<$file" or die $!;
    my $line;


    my $counter_of_output_file = 0;
    my $something_was_written = 0;
    my $outputfile;
    while (<FILE>) {
        $line = $_;

        if ($line =~ /^\s*#/ ) {
            if ( $something_was_written ) {
                close (OUTFILE);
            }
            $something_was_written = 0;
        }
        else {
            unless ( $something_was_written ) { 
                $counter_of_output_file++;
                $outputfile = $file;
                $outputfile =~ s/input/input$counter_of_output_file/;
                open (OUTFILE, ">$outputfile") or die $!;
                push( @list_of_datafiles, $outputfile );
            }
            print OUTFILE $line;
            $something_was_written = 1;
        }
    }
    if ( $something_was_written ) {
        close (OUTFILE);
    }
    return ( @list_of_datafiles);
}

1;    # need to end with a true value

