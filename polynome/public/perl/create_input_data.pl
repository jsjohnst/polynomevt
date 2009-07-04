########################################
# USERINPUT-TO-FILE MODULE
# this function reads one input function from file or text area and writes the
# input data to a file, returning the file name.
# This file can contain multiple time series separated by lines beginning with #
#
########################################

use strict;

sub create_input_datafile() {
    my ( $file_prefix, $file, $data ) = @_;
    my $datafile = "$file_prefix.input.txt";
    open( OUTFILE, ">$datafile" );

    #print ">$datafile" if ($DEBUG);

    if ($file) {
        # user has uploaded a file with data
        my $buffer;
        my $bytesread;
        flock( OUTFILE, LOCK_EX ) or die("Could not get exclusive lock $!");
        while ( $bytesread = read( $file, $buffer, 1024 ) ) {
            print OUTFILE $buffer;
        }
        flock( OUTFILE, LOCK_UN ) or die("Could not unlock file $!");
        close $file;
    }
    else {
        # user has not uploaded any file. so use the textarea value
        if ($data) {

          #read value from editfunctions and print it to outfile
          #flock(OUTFILE, LOCK_EX) or die ("Could not get exclusive lock $!");
            print OUTFILE $data;
            flock( OUTFILE, LOCK_UN ) or die("Could not unlock file $!");
        }
        else {

            # no data provided
            print
                "<font color=\"red\">Error: No data provided. Please upload a data file or enter your data in the edit box.</font><br>";
            close(OUTFILE);
            die("No data file provided by user");
        }
    }
    close(OUTFILE);

    #remove any ^M characters
    `perl -pi -e 's/\r//g' "$datafile"`;
    return ($datafile);
}

1;    # need to end with a true value

