#!/usr/bin/perl5.8.9

## dvd_stochasitic_runner.pl
## Multi-function, stochastic DVD Processing
## This script takes a number of nodes, the number of states, and the filename for the input file
## Functions can be read from the input file with the possiblity for more than one function per node
## Authored by Jonte Craighead and Franziska Hinkelmann
#
# The all_trajectories_flag set means all possible arrows are drawn in one
# graph, without this option, one update is choosen at random for every
# variables - the program should always be run with the flag turned on, since
# this produces the phase space, the other option produces one possible
# trajectory for each state but not a simulation starting from one state
# 
# update_stochastic_flag set means that we treat the system as an update
# stochastic systems (the udpate schedule is random). This is simulated by
# using a function stochastic system where each function set has two members:
# the local update function and the identity. The probabilities are set such
# that (nodes-1) functions are delayed and only one function is updated. If
# the user gives a family of update functions for one node, an error is
# returned, because a function and update stochastic system is not
# allowed. 

use strict;

use lib '../perl';

use DVDCore;# qw($Clientip $Function_data $Function_file &error_check @Output_array $Pwd &dvd_session &_log $show_probabilities_in_state_space);
use Cwd;

#use Getopt::Std;

my ($debug, $verbose, $help);
my $n_nodes;
my $p_value = 2;
my $all_trajectories_flag = 1;
  # This flag set means all possible arrows are drawn in one
  # graph, without this option, one update is choosen at random for every
  # variables

my $update_stochastic_flag = 0;
 	# if set, an update stochastic system is simulated using
  # random delays

my $file_prefix; #outputfiles
my $statespace_format = "gif"; # state_space format
my $wiring_diagram_format =  "gif"; # wiring_diagram format

my $show_wiring_diagram = 0 ; # on if wiring diagram should be graphed
my $show_statespace = 0; # show_statespace 1 means create picture

my $update_sequential_flag = 0;
  # 1 for sequential update, 0 for synchronous updates

my $update_schedule = 0; # update_schedule
  # has to be set to 0 for random sequential updates (i.e., update_stochastic_flag == 1 )

my $show_probabilities_in_state_space = 0; 	# if set to one, probabilities are included in graph of state space 

my $show_trajectory_from_one_state = 0; # 0 if all transitions, 1 for transitions from one initial state
my $trajectory_initial_state = 0; # initial state if printing just one trajectory

my $input_function_file; 

use Getopt::Long;


GetOptions ( "v" => \$verbose,    # flag
             "h" => \$help,       # flag
             "d" => \$debug,      # flag
             "nodes=i" => \$n_nodes, # numerical
             "pvalue=i" => \$p_value, # numerical
             "all_trajectories" => \$all_trajectories_flag,   # flag
             "update_stochastic" => \$update_stochastic_flag,  # flag
             "file_prefix=s" => \$file_prefix,  # string
             "statespace_format=s" => \$statespace_format, # string
             "wiring_diagram_format=s" => \$wiring_diagram_format, # string
             "show_wiring_diagram" => \$show_wiring_diagram, #flag
             "show_statespace" => \$show_statespace, #flag
             "update_sequential" => \$update_stochastic_flag, 
             "update_schedule=s" => \$update_schedule, #string
             "show_probabilities_in_state_space" => \$show_probabilities_in_state_space, 
             "show_trajectory_from_one_state" => \$show_trajectory_from_one_state,
             "trajectory_initial_state=s" => \$trajectory_initial_state,
             "function_file=s" => \$input_function_file #string
             ) ; 

if ($debug) {
    $verbose = 1;
}

if ($debug) {print getcwd . "<br>\n";}
if ($verbose) {print "Using Minimum Debug output for dvd_stochastic_runner.pl<br>\n";}

die "Usage: Read the source code!
\n" if ($help ||
!$input_function_file || !$n_nodes || !$file_prefix );


if ($verbose) {print "    Debug :$debug: <br>
    Number of nodes $n_nodes <br>
    P_value :$p_value: <br>
    file_prefix :$file_prefix: <br>
    Statespace format :$statespace_format: <br>
    Wiring diagram format :$wiring_diagram_format:<br>
    Show Wiring diagram :$show_wiring_diagram:<br>
    Show Statespace :$show_statespace: <br>
    Functionfile :$input_function_file: <br>
    Update sequential :$update_sequential_flag: <br>
    Update schedule :$update_schedule: <br>
    Update stochastic :$update_stochastic_flag: <br> 
    Show_probabilities_state_space :$show_probabilities_in_state_space: <br>\n";}


open (my $function_file, $input_function_file) or die $!;
print ("Attempted to read from '$input_function_file'\n");

my $Pwd = getcwd();

my @response = DVDCore::dvd_session($n_nodes, $p_value, $file_prefix, 0, $update_sequential_flag, $update_schedule, $all_trajectories_flag, $show_statespace, $statespace_format, $show_wiring_diagram, $wiring_diagram_format, $show_trajectory_from_one_state, $trajectory_initial_state, $update_stochastic_flag, $show_probabilities_in_state_space, $debug, $function_file);

if($response[0] == 1) { # a response code should always be returned by the main DVDCore functions
    my @Output_array = shift(@response);
    _log($_) foreach(@Output_array);
    if ($show_trajectory_from_one_state) {
        print "Number of components $Output_array[2]<br>";
        print "Number of fixed points $Output_array[3]<br>";
        print "$Output_array[5]<br>";
    }
} 
else {
    ### FBH TODO if show_statespace is false, DVD session returns a 0 as
    ### $response[0], what does that mean? should we return a 1 or should we check
    ### for == 0? state_space
    #print "Does this mean error?" .  $_ ."\n" foreach(@response);
}

exit 0;
