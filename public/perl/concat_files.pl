########################################
# concatenate files in list into one large file $outfilename, put # as delimeter in between 
########################################

use strict;

sub concat_files {
    my ( $ref_list_of_files, $outfilename ) = @_;
    my @list_of_files = @{$ref_list_of_files};
    open OUTFILE, ">$outfilename" or die $!;

    my $filecounter = 0;
    foreach my $inputfile ( @list_of_files ) {
        open INFILE, "<$inputfile" or die $1;
        $filecounter++;
        while (<INFILE>) {
            print OUTFILE $_;
        }
        unless ( $filecounter == @list_of_files ) {
            print OUTFILE "#\n";
        }
    }
    close OUTFILE;

    return ( $outfilename );
}

1;    # need to end with a true value

