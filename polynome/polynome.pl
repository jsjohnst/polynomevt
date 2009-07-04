#!/usr/bin/perl

## Franziska B Hinkelmann
## Michael Stillman

use CGI qw( :standard );
use Fcntl qw( :flock );

use strict;

sub make_file_prefix () {
    #get the clients ip address
    #$file_prefix = $ENV{'REMOTE_ADDR'};
    my $file_prefix =~ s/\./\-/g;
    my ( $sec, $min, $hr ) = localtime();
    $file_prefix = $file_prefix . '-' . $sec . '-' . $min . '-' . $hr;

    #$file_prefix = $sec.'-'.$min.'-'.$hr;
    $file_prefix = 'files' . $file_prefix;
    return $file_prefix;
    
}

chdir("../perl/");

#include files with subroutines
require "create_input_data.pl";
require "make_m2_string_from_array.pl";
require "discretize_data.pl";
require "is_data_consistent.pl";
require "generate_wiring_diagram.pl";
require "split_input_data_into_multiple_files.pl";
require "concat_files.pl";
require "gfan.pl";
require "run_stochastic_simulation.pl";
require "error_check.pl";


# log user access
open( ACCESS, ">>access" ) or die("Failed to open file for writing");
flock( ACCESS, LOCK_EX ) or die("Could not get exclusive lock $!");
print ACCESS ( $ENV{REMOTE_ADDR} );
system("date >>access");
flock( ACCESS, LOCK_UN ) or die("Could not unlock file $!");
close(ACCESS);

my ($n_nodes) = @ARGV;

my $p_value                = 2;
my $is_deterministic_model = 0;
    # values Deterministic, Stochastic

# to generate the model, synchronuous updates are used, but the user can
# choose to simulate the model using sequential updates
my $has_sequential_update = 0; 
    # "Simulate the state space using an update schedule" if sequential update, otherwise synchronuous update
    # This will be changed once we find out, why value instead of label is
    # printed to html form for check boxes
my $update_schedule = "";
    # if has_sequential_update is true, this is a string
    # of the form e.g. "1 3 4 2 5" (indices start at 1, and should include all 1..$n_nodes values in some order).

my $input_data = "1.2  2.3  3.4
1.1  1.2  1.3
2.2  2.3  2.4
0.1  0.2  0.3";
my $input_file;

my $show_discretized_data = 1;
my $show_wiring_diagram   = 0;
my $wiring_diagram_format = 0;
my $show_statespace       = 0;
    ### FBH for now, the statespace is always created, but only when
    ### $show_statespace is set, the link is reported to the user

my $statespace_format  = ".gif";
my $show_probabilities_in_state_space = 0;
    # if set, probabilities are drawn in state space

my $show_functions = 0;

###my $p_value                = 2;
###my $n_nodes                = param('n_nodes');
###my $is_deterministic_model = param('is_deterministic_model');
###    # values Deterministic, Stochastic
###
#### to generate the model, synchronuous updates are used, but the user can
#### choose to simulate the model using sequential updates
###my $has_sequential_update = param('has_sequential_update');
###    # "Simulate the state space using an update schedule" if sequential update, otherwise synchronuous update
###    # This will be changed once we find out, why value instead of label is
###    # printed to html form for check boxes
###my $update_schedule = param('update_schedule');
###    # if has_sequential_update is true, this is a string
###    # of the form e.g. "1 3 4 2 5" (indices start at 1, and should include all 1..$n_nodes values in some order).
###
###my $input_file = upload('input_file');
###my $input_data = param('input_data');
###
###### FBH I have no idea what this is used for?!
###### $option_box = param('option_box');
###### $trajectory_value = param('trajectory_value');
###
###my $show_discretized_data = param('show_discretized_data');
###my $show_wiring_diagram   = param('show_wiring_diagram');
###my $wiring_diagram_format = param('wiring_diagram_format');
###my $show_statespace       = param('show_statespace');
###    ### FBH for now, the statespace is always created, but only when
###    ### $show_statespace is set, the link is reported to the user
###
###my $statespace_format  = param('statespace_format');
###my $show_probabilities_in_state_space = param('show_probabilities_in_state_space');
###    # if set, probabilities are drawn in state space
###
###my $show_functions = param('show_functions');


#check routines
# p_value, n_nodes: are they numbers and allowed numbers?
# is # of nodes equal to # of columns in data? is data in number format
# print out number of lines in data

# if sequential update is chosen, is the updateschedule valid?
# check for number of elements in schedule
# sort -u the array, then a[1]=1 and a[n]=n
# warning if update schedule but not sequential update


# remove . from file format
$statespace_format     =~ s/\*\.//;
$wiring_diagram_format =~ s/\*\.//;

if ( $p_value && $n_nodes ) {
    my $file_prefix = make_file_prefix();
    $input_file
        = create_input_datafile( $file_prefix, $input_file, $input_data );
        unless (data_has_correct_format( $n_nodes, $input_file ) ) {
            print "<font color=red>Please correct your data.</font><br>";
            print "<font color=red>Exiting.</font><br>";
            exit 1;
        }
    my @list_of_input_files = split_input_data_into_multiple_files( $input_file );
    my @list_of_discretized_datafiles
        = discretize_data( \@list_of_input_files, $p_value, $file_prefix );

    my $discretized_datafile = concat_files( \@list_of_discretized_datafiles,
    $file_prefix. ".input.txt" );
    if ($discretized_datafile ) {
        if ($show_discretized_data) {
            print
                "<A href=\"$discretized_datafile\" target=\"_blank\"><font color=green><i>Discretization was successful.</i></font></A><br><br>";
        }
        else {
            print
                "<font color=green><i>Discretization was successful.</i></font><br><br>";
        }
    }
    else {
        print "<font color=red>Discretization was unsuccessful</font><br>";
        die("Discretization unsuccessful");
    }
    
    


    if ( $show_wiring_diagram && !$show_statespace && !$show_functions ) {
        my $wiring_diagram_filename;

        ## if only the wiring diagram but not the functions are needed, minsets()
        ## is used
        if ( is_data_consistent( \@list_of_discretized_datafiles, $p_value, $n_nodes ) )
        {
            if ( $n_nodes <= 10 ) {
                $wiring_diagram_filename
                    = generate_wiring_diagram( \@list_of_discretized_datafiles,
                    $p_value, $n_nodes, $wiring_diagram_format, $file_prefix );
            }
            else {
                $wiring_diagram_filename
                    = minsets_generate_wiring_diagram( \@list_of_discretized_datafiles,
                    $p_value, $n_nodes, $wiring_diagram_format, $file_prefix );
            }
        }
        else {
            print
                "<font color=red>The data are inconsistent. Please check the input data.</font><br>";
        }
        if ($wiring_diagram_filename) {
            print
                "<A href=\"$wiring_diagram_filename\" target=\"_blank\"><font color=green><i>Wiring diagram.</i></font></A><br><br>";
        }

        # else there's no wiring diagram -> problem

    }
    elsif ( $show_statespace || $show_functions ) {
        ## if the funtions are needed, sgfan() is used

#        if($is_deterministic_model eq "Deterministic")
#        {
#            if($n_nodes <= 10)
#            {
#                ea();
#            }
#            else
#            {
#                if(!is_data_consistent($discretized_datafile,$p_value,$n_nodes))
#                {
#                    make_consistent();
#                }
#                minsets();
#            }
#
#            run_deterministic_simulation();
#        }
#        else
#        {

        if ( $n_nodes <= 10 ) {
    
            if (is_data_consistent( \@list_of_discretized_datafiles, $p_value, $n_nodes))
            {
                my $function_file
                    = sgfan( \@list_of_discretized_datafiles, $p_value,
                    $n_nodes, $file_prefix );
                if ( $function_file && $show_functions ) {
                    print "<A href=\"$function_file\" target=\"_blank\"><font
                    color=green><i>Functions.</i></font></A><br>";
                }
                run_stochastic_simulation(
                    $p_value, $n_nodes, $file_prefix,
                    $show_wiring_diagram, $wiring_diagram_format,
                    $show_statespace,     $statespace_format,
                    $show_probabilities_in_state_space, $function_file
                );
            }
            else {
                # make_consistent();
                print
                    "<font color=red>The data are inconsistent. Please check the input data.</font><br>";
            }
        }
        else {
            print "Cannot have more than 10 nodes at this time.<br>";
        }
    }
}


